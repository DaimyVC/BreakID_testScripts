#!/bin/bash

#module purge
#module load CMake/3.20.1-GCCcore-10.3.0
#module load make/4.3-GCCcore-10.3.0
#module load Boost/1.76.0-GCC-10.3.0

cd ../..

TMPDIR=$VSC_SCRATCH
results=$VSC_DATA/BreakID_testScripts/results/roundingsat
home=$VSC_DATA/BreakID_testScripts

instances=INSTANCES
filename=FILENAME
config=CONFIG

extension="${filename##*.}"
filename="${filename%.*}"

FOUND_OPT="NA"
RUNTIME_ROUNDINGSAT="NA"
STATUS="NA"
OUTPUT_CODE_ROUNDINGSAT="NA" ##TOE TE VOEGEN

writeback() {
  echo "${filename}, ${config}, $RUNTIME_ROUNDINGSAT, $STATUS, $FOUND_OPT, $RUNTIME_BREAKID, $TOTAL_CONSTR_BEGIN, $TOTAL_VARS_BEGIN, $SYMM_GENS, $SYMM_GROUPS, $MATRICES, $ROW_SWAPS, $REG_CONSTR_ADDED, $BIN_CONSTR_ADDED, $ROW_CONSTR_ADDED, $TOTAL_VARS_ADDED, $TOTAL_CONSTR_ADDED"   >> "$results"/"$filename"_"$config"_result.csv

  FOUND_OPT="NA"
  RUNTIME_ROUNDINGSAT="NA"
  STATUS="NA"
  OUTPUT_CODE_ROUNDINGSAT="NA" ##TOE TE VOEGEN

  RUNTIME_BREAKID="NA" 
  SYMM_GENS="NA"
  SYMM_GROUPS="NA"
  TOTAL_CONSTR_BEGIN="NA" 
  TOTAL_VARS_BEGIN="NA" 
  TOTAL_VARS_ADDED="NA" 
  TOTAL_CONSTR_ADDED="NA" 
  REG_CONSTR_ADDED="NA"
  BIN_CONSTR_ADDED="NA"
  ROW_CONSTR_ADDED="NA"
  MATRICES="NA"
  ROW_SWAPS="NA"
  OUTPUT_CODE_BREAKID="NA" ##TOE TE VOEGEN
}

if [ "$config" = "no_symm_breaking" ]
then
  ##BASE CASE, NO SYMM BREAKING
  { time cat $instances/${filename}.${extension} | $home/roundingsat 1>$TMPDIR/${filename}_${config}_rs.txt ; } >$TMPDIR/${filename}_${config}_rstime.txt

  FOUND_OPT=$(grep '^o ' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[+-]?[0-9]{1,}');
  STATUS=$(grep '^s ' $TMPDIR/${filename}_${config}_rs.txt | grep -Po 's\s\K.*')
  RUNTIME_ROUNDINGSAT=$(grep 'real' $TMPDIR/${filename}_${config}_rstime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')
  OUTPUT_CODE_ROUNDINGSAT="NA" ##TOE TE VOEGEN

  echo "$filename $config:"
  echo "RUNTIME_ROUNDINGSAT: $RUNTIME_ROUNDINGSAT"
  echo "status: $STATUS"
  echo "found optimum: $FOUND_OPT"
  echo "output code: $OUTPUT_CODE_ROUNDINGSAT"

  writeback $config

else
  { time cat $TMPDIR/${filename}_${config}_opb.opb | $home/roundingsat 1>$TMPDIR/${filename}_${config}_rs.txt ; } 2>$TMPDIR/${filename}_${config}_rstime.txt

  FOUND_OPT=$(grep '^o ' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[+-]?[0-9]{1,}')
  RUNTIME_ROUNDINGSAT=$(grep 'real' $TMPDIR/${filename}_${config}_rstime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')
  STATUS=$(grep '^s ' $TMPDIR/${filename}_${config}_rs.txt | grep -Po 's\s\K.*')
  OUTPUT_CODE_ROUNDINGSAT="NA" ##TOE TE VOEGEN

  echo "$filename with $config"
  echo "roundingsat status: $STATUS"
  echo "found optimum: $FOUND_OPT"
  echo "total runtime Roundingsat: $RUNTIME_ROUNDINGSAT"

  writeback $config
fi
