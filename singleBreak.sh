#!/bin/bash
#
#SBATCH --job-name=single_break
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=16g

module purge
module load CMake/3.20.1-GCCcore-10.3.0
module load make/4.3-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

cd ../..

TMPDIR=$VSC_SCRATCH
results=$VSC_DATA/BreakID_testScripts/results/breakid
home=$VSC_DATA/BreakID_testScripts

instances=INSTANCES
filename=FILENAME
config=CONFIG
arguments="ARGS"

extension="${filename##*.}"
filename="${filename%.*}"

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
  

{ time cat $instances/${filename}.${extension} | $home/BreakID $arguments -v 1 -t 300 -s 100 2>$TMPDIR/${filename}_${config}_breakinfo.txt 1>$TMPDIR/${filename}_${config}_opb.opb ; } 2>$TMPDIR/${filename}_${config}_brtime.txt

RUNTIME_BREAKID=$(grep 'real' $TMPDIR/${filename}_${config}_brtime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')
SYMM_GENS=$(grep '**** symmetry generators detected:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
SYMM_GROUPS=$(grep '**** subgroups detected:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
TOTAL_CONSTR_BEGIN=$(grep '* #variable= ' $instances/${filename}.${extension} | grep -Eo '#constraint= [0-9]{1,}' | grep -Eo '[0-9]{1,}')
TOTAL_VARS_BEGIN=$(grep '* #variable= [0-9]{1,}' $instances/${filename}.${extension} | grep -Eo '[0-9]{1,}')
REG_CONSTR_ADDED=$(grep '**** regular symmetry breaking clauses added:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
BIN_CONSTR_ADDED=$(grep '**** extra binary symmetry breaking clauses added:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
ROW_SWAPS=$(grep '**** row swaps detected:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
MATRICES=$(cat $TMPDIR/${filename}_${config}_breakinfo.txt | grep '**** matrices detected:' | grep -Eo '[0-9]{1,}')
ROW_CONSTR_ADDED=$(grep '**** row interchangeability breaking clauses added:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
TOTAL_CONSTR_ADDED=$(($REG_CONSTR_ADDED + $BIN_CONSTR_ADDED + $ROW_CONSTR_ADDED))
TOTAL_VARS_ADDED=$(grep '**** auxiliary variables introduced:' $TMPDIR/${filename}_${config}_breakinfo.txt | grep -Eo '[0-9]{1,}')
OUTPUT_CODE_BREAKID="NA" ##TOE TE VOEGEN

echo "$filename with $config"
echo "total variables beginning: $TOTAL_VARS_BEGIN"
echo "total constraints beginning: $TOTAL_CONSTR_BEGIN"
echo "symmetry generators found: $SYMM_GENS"
echo "symmetry subgroups found: $SYMM_GROUPS"
echo "regular constraints added: $REG_CONSTR_ADDED"
echo "binary constraints added: $BIN_CONSTR_ADDED"
echo "row swaps added: $ROW_SWAPS"
echo "matrices found: $MATRICES"
echo "total row interchangeability breaking constraints added: $ROW_CONSTR_ADDED"
echo "total constraints added: $TOTAL_CONSTR_ADDED"
echo "total auxiliary variables added: $TOTAL_VARS_ADDED"
echo "total runtime BreakID: $RUNTIME_BREAKID"

echo "${filename}, ${config}, $RUNTIME_BREAKID, $TOTAL_CONSTR_BEGIN, $TOTAL_VARS_BEGIN, $SYMM_GENS, $SYMM_GROUPS, $MATRICES, $ROW_SWAPS, $REG_CONSTR_ADDED, $BIN_CONSTR_ADDED, $ROW_CONSTR_ADDED, $TOTAL_VARS_ADDED, $TOTAL_CONSTR_ADDED"   >> "$results"/"$filename"_"$config"_result.csv