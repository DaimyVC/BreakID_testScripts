#!/bin/bash
#
#SBATCH --job-name=single_solve
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=16g

module purge
module load CMake/3.20.1-GCCcore-10.3.0
module load make/4.3-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

cd ..

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
OUTPUT_CODE_ROUNDINGSAT="NA"

writeback() {
  echo "${filename}, ${config}, $RUNTIME_ROUNDINGSAT, $STATUS, $FOUND_OPT, $OUTPUT_CODE_ROUNDINGSAT"   >> "$results"/"$filename"_"$config"_result.csv

  FOUND_OPT="NA"
  RUNTIME_ROUNDINGSAT="NA"
  STATUS="NA"
  OUTPUT_CODE_ROUNDINGSAT="NA"
}

if [ "$config" = "no_symm_breaking" ]
then
  ##BASE CASE, NO SYMM BREAKING
  { time cat $instances/${filename}.${extension} | $home/roundingsat 1>$TMPDIR/${filename}_${config}_rs.txt ; } 2>$TMPDIR/${filename}_${config}_rstime.txt
  
  OUTPUT_CODE_ROUNDINGSAT=$(echo $?)
  FOUND_OPT=$(grep '^o ' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[+-]?[0-9]{1,}');
  STATUS=$(grep '^s ' $TMPDIR/${filename}_${config}_rs.txt | grep -Po 's\s\K.*')
  RUNTIME_ROUNDINGSAT=$(grep 'real' $TMPDIR/${filename}_${config}_rstime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')

  echo "$filename $config:"
  echo "RUNTIME_ROUNDINGSAT: $RUNTIME_ROUNDINGSAT"
  echo "status: $STATUS"
  echo "found optimum: $FOUND_OPT"
  echo "output code: $OUTPUT_CODE_ROUNDINGSAT"

  writeback $config

else
  { time cat $TMPDIR/${filename}_${config}_opb.opb | $home/roundingsat 1>$TMPDIR/${filename}_${config}_rs.txt ; } 2>$TMPDIR/${filename}_${config}_rstime.txt
  
  OUTPUT_CODE_ROUNDINGSAT=$(echo $?)
  FOUND_OPT=$(grep '^o ' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[+-]?[0-9]{1,}')
  RUNTIME_ROUNDINGSAT=$(grep 'real' $TMPDIR/${filename}_${config}_rstime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')
  STATUS=$(grep '^s ' $TMPDIR/${filename}_${config}_rs.txt | grep -Po 's\s\K.*')

  echo "$filename with $config"
  echo "roundingsat status: $STATUS"
  echo "found optimum: $FOUND_OPT"
  echo "total runtime Roundingsat: $RUNTIME_ROUNDINGSAT"

  writeback $config
fi