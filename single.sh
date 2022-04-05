#!/bin/bash

cd ..

mkdir tmp
TMPDIR="tmp"

instances=INSTANCES
filename=FILENAME
extension="${filename##*.}"
filename="${filename%.*}"

TIMEOUT_SOLVER=TIME_L
TIMEOUT_SOLVER_PL=$TIMEOUT_SOLVER
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
cat $instances/${filename}.${extension} | ./roundingsat 1>$TMPDIR/${filename}.txt

FOUND_OPT=$(cat $TMPDIR/${filename}.txt | grep '^o ' | grep -Eo '[+-][0-9]{1,}');
RUNTIME=$(cat $TMPDIR/${filename}.txt | grep 'cpu time ' | grep -Eo '[0-9]{1,}[.][0-9]{1,}');
STATUS=$(cat $TMPDIR/${filename}.txt | grep '^s ' | grep -Po 's\s\K.*')

echo "$filename without symmetry breaking:"
echo "runtime: $RUNTIME"
echo "status: $STATUS"
echo "found optimum: $FOUND_OPT"

echo ", RUNTIME, STATUS, FOUND_OPT, SYMM_GENS, SYMM_GROUPS, TOTAL_CONSTR, REG_CONSTR, BIN_CONSTR, MATRICES, ROW_SWAPS"  >> ./results/"$filename"_result.csv

writeback() {
  echo "${filename}_${1}, $RUNTIME, $STATUS, $FOUND_OPT, $SYMM_GENS, $SYMM_GROUPS, $TOTAL_CONSTR, $REG_CONSTR, $BIN_CONSTR, $MATRICES, $ROW_SWAPS"  >> ./results/"$filename"_result.csv
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
  cat $instances/${filename}.${extension} | ./BreakID ${ALLARGS[$i]} -v 7 2>./$TMPDIR/breakinfo.txt 1>./$TMPDIR/opb.opb
  SYMM_GENS=$(cat $TMPDIR/breakinfo.txt | grep '**** symmetry generators detected:' | grep -Eo '[0-9]{1,}')
  SYMM_GROUPS=$(cat $TMPDIR/breakinfo.txt | grep '**** subgroups detected:' | grep -Eo '[0-9]{1,}')
  TOTAL_CONSTR=$(cat $TMPDIR/opb.opb | grep '* #variable= ' | grep -Eo '#constraint= [0-9]{1,}' | grep -Eo '[0-9]{1,}')
  REG_CONSTR=$(cat $TMPDIR/breakinfo.txt | grep '**** regular symmetry breaking clauses added:' | grep -Eo '[0-9]{1,}')
  BIN_CONSTR=$(cat $TMPDIR/breakinfo.txt | grep '**** extra binary symmetry breaking clauses added:' | grep -Eo '[0-9]{1,}')
  MATRICES=$(cat $TMPDIR/breakinfo.txt | grep '**** matrices detected:' | grep -Eo '[0-9]{1,}')
  ROW_SWAPS=$(cat $TMPDIR/breakinfo.txt | grep '**** row swaps detected:' | grep -Eo '[0-9]{1,}')
  cat $TMPDIR/opb.opb | ./roundingsat 1>$TMPDIR/${filename}.txt
  FOUND_OPT=$(cat $TMPDIR/${filename}.txt | grep '^o ' | grep -Eo '[+-][0-9]{1,}');
  RUNTIME=$(cat $TMPDIR/${filename}.txt | grep 'cpu time ' | grep -Eo '[0-9]{1,}[.][0-9]{1,}');
  STATUS=$(cat $TMPDIR/${filename}.txt | grep '^s ' | grep -Po 's\s\K.*')
  writeback ${ALLCONFIGS[$i]}
done

rm -r $TMPDIR