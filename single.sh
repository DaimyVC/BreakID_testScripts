#!/bin/bash

module purge
module load CMake/3.20.1-GCCcore-10.3.0
module load make/4.3-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

cd ..

TMPDIR=$VSC_SCRATCH

instances=INSTANCES
filename=FILENAME
extension="${filename##*.}"
filename="${filename%.*}"
results=$VSC_DATA/results
home=$VSC_DATA/BreakID_testScripts

TIMEOUT_SOLVER=TIME_L
TIMEOUT_BREAKID=$(echo 10*$TIMEOUT_SOLVER / 1 | bc)
MEMORY_LIMIT=MEM_L

FOUND_OPT="NA"
RUNTIME="NA"
STATUS="NA"
MEM_USAGE="NA"

SYMM_GENS="NA"
SYMM_GROUPS="NA"
TOTAL_CONSTR="NA"
REG_CONSTR="NA"
BIN_CONSTR="NA"
MATRICES="NA"
ROW_SWAPS="NA"

SHORTPB="-pb 0"
LONGPB="-pb 70"
NOOPT="-no-bin -no-small -no-row"
WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG0="no_symm_breaking"
CONFIG1="strongsymm_shortpbconstr_noopt"
A1="$SHORTPB $NOOPT"
CONFIG2="strongsymm_shortpbconstr_opt"
A2="$SHORTPB"
CONFIG3="strongsymm_longpbconstr_noopt"
A3="$LONGPB $NOOPT"
CONFIG4="strongsymm_longpbconstr_opt"
A4="$LONGPB"
CONFIG5="weaksymm_shortpbconstr_noopt_relaxed"
A5="$WEAKSYMM $SHORTPB $NOOPT"
CONFIG6="weaksymm_shortpbconstr_noopt_notrelaxed"
A6="$WEAKSYMM $SHORTPB $NOOPT $NORELAX"
CONFIG7="weaksymm_shortpbconst_opt_relaxed"
A7="$WEAKSYMM $SHORTPB"
CONFIG8="weaksymm_shortpbconst_opt_notrelaxed"
A8="$WEAKSYMM $SHORTPB $NORELAX"
CONFIG9="weaksymm_longpbconstr_noopt_relaxed"
A9="$WEAKSYMM $LONGPB $NOOPT"
CONFIG10="weaksymm_longpbconstr_noopt_notrelaxed"
A10="$WEAKSYMM $LONGPB $NOOPT $NORELAX"
CONFIG11="weaksymm_longpbconstr_opt_relaxed"
A11="$WEAKSYMM $LONGPB"
CONFIG12="weaksymm_longpbconstr_opt_notrelaxed"
A12="$WEAKSYMM $LONGPB $NORELAX"

ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4" "$CONFIG5" "$CONFIG6" "$CONFIG7" "$CONFIG8" "$CONFIG9" "$CONFIG10" "$CONFIG11" "$CONFIG12")
ALLARGS=("$A1" "$A2" "$A3" "$A4" "$A5" "$A6" "$A7" "$A8" "$A9" "$A10" "$A11" "$A12")

##BASE CASE, NO SYMM BREAKING
timeout $TIMEOUT_SOLVER cat $instances/${filename}.${extension} | $home/roundingsat 1>$TMPDIR/${filename}.txt

FOUND_OPT=$(cat $TMPDIR/${filename}.txt | grep '^o ' | grep -Eo '[+-]?[0-9]{1,}');
RUNTIME=$(cat $TMPDIR/${filename}.txt | grep 'cpu time ' | grep -Eo '[0-9]{1,}[.]?[0-9]?{1,}');
STATUS=$(cat $TMPDIR/${filename}.txt | grep '^s ' | grep -Po 's\s\K.*')

echo "$filename without symmetry breaking:"
echo "runtime: $RUNTIME s"
echo "status: $STATUS"
echo "found optimum: $FOUND_OPT"

echo ", RUNTIME, STATUS, FOUND_OPT, SYMM_GENS, SYMM_GROUPS, TOTAL_CONSTR, REG_CONSTR, BIN_CONSTR, MATRICES, ROW_SWAPS"  >> "$results"/"$filename"_result.csv

writeback() {
  echo "${filename}_${1}, $RUNTIME s, $STATUS, $FOUND_OPT, $SYMM_GENS, $SYMM_GROUPS, $TOTAL_CONSTR, $REG_CONSTR, $BIN_CONSTR, $MATRICES, $ROW_SWAPS"  >> "$results"/"$filename"_result.csv
  RUNTIME="NA"
  STATUS="NA"
  FOUND_OPT="NA"
  SYMM_GENS="NA"
  SYMM_GROUPS="NA"
  TOTAL_CONSTR="NA"
  REG_CONSTR="NA"
  BIN_CONSTR="NA"
  MATRICES="NA"
  ROW_SWAPS="NA"
}

writeback $CONFIG0

for i in "${!ALLCONFIGS[@]}"; do
  timeout $TIMEOUT_BREAKID cat $instances/${filename}.${extension} | $home/BreakID ${ALLARGS[$i]} -v 7 2>$TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt 1>$TMPDIR/${filename}_opb_${ALLCONFIGS[$i]}.opb

  SYMM_GENS=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** symmetry generators detected:' | grep -Eo '[0-9]{1,}')
  SYMM_GROUPS=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** subgroups detected:' | grep -Eo '[0-9]{1,}')
  TOTAL_CONSTR=$(cat $TMPDIR/${filename}_opb_${ALLCONFIGS[$i]}.opb | grep '* #variable= ' | grep -Eo '#constraint= [0-9]{1,}' | grep -Eo '[0-9]{1,}')
  REG_CONSTR=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** regular symmetry breaking clauses added:' | grep -Eo '[0-9]{1,}')
  BIN_CONSTR=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** extra binary symmetry breaking clauses added:' | grep -Eo '[0-9]{1,}')
  MATRICES=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** matrices detected:' | grep -Eo '[0-9]{1,}')
  ROW_SWAPS=$(cat $TMPDIR/${filename}_breakinfo_${ALLCONFIGS[$i]}.txt | grep '**** row swaps detected:' | grep -Eo '[0-9]{1,}')

  timeout $TIMEOUT_SOLVER cat $TMPDIR/${filename}_opb_${ALLCONFIGS[$i]}.opb | $home/roundingsat 1>$TMPDIR/${filename}_${ALLCONFIGS[$i]}.txt
  FOUND_OPT=$(cat $TMPDIR/${filename}_${ALLCONFIGS[$i]}.txt | grep '^o ' | grep -Eo '[+-]?[0-9]{1,}');
  RUNTIME=$(cat $TMPDIR/${filename}_${ALLCONFIGS[$i]}.txt | grep 'cpu time ' | grep -Eo '[0-9]{1,}[.]?[0-9]?{1,}');
  STATUS=$(cat $TMPDIR/${filename}_${ALLCONFIGS[$i]}.txt | grep '^s ' | grep -Po 's\s\K.*')


  echo "$filename with ${ALLCONFIGS[$i]}"
  echo "symmetry generators found: $SYMM_GENS"
  echo "symmetry subgroups found: $SYMM_GROUPS"
  echo "total constraints added: $TOTAL_CONSTR"
  echo "regular constraints added: $REG_CONSTR"
  echo "binary constraints added: $BIN_CONSTR"
  echo "row swaps added: $ROW_SWAPS"
  echo "matrices found: $MATRICES"
  echo "status: $STATUS"
  echo "found optimum: $FOUND_OPT"
  echo "total runtime: $RUNTIME"

  writeback ${ALLCONFIGS[$i]}
done
