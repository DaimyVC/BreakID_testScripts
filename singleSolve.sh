#!/bin/bash
#
#SBATCH --job-name=single_solve
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=skylake,skylake_mpi
#SBATCH --mem-per-cpu=16g

module purge
module load Boost/1.76.0-GCC-10.3.0
module load GCC/10.3.0

cd ..

TMPDIR=$VSC_SCRATCH_VO_USER
home=$VSC_DATA/BreakID_testScripts

results=$home/LOC
instances=INSTANCES
filename=FILENAME
config=CONFIG

extension="${filename##*.}"
filename="${filename%.*}"

FOUND_OPT="NA"
RUNTIME_ROUNDINGSAT="NA"
CONFLICTS="NA"
STATUS="NA"
OUTPUT_CODE_ROUNDINGSAT="NA"

writeback() {
  echo "${filename}, ${config}, $RUNTIME_ROUNDINGSAT, $STATUS, $FOUND_OPT, $CONFLICTS, $OUTPUT_CODE_ROUNDINGSAT"   >> "$results"/"$filename"_"$config"_result.csv

  FOUND_OPT="NA"
  RUNTIME_ROUNDINGSAT="NA"
  STATUS="NA"
  CONFLICTS="NA"
  OUTPUT_CODE_ROUNDINGSAT="NA"
}

{ time cat $TMPDIR/${filename}_${config}_opb.opb | $home/roundingsatV1 --lp=0 --opt-mode=linear 1>$TMPDIR/${filename}_${config}_rs.txt ; } 2>$TMPDIR/${filename}_${config}_rstime.txt

OUTPUT_CODE_ROUNDINGSAT=$(echo $?)
FOUND_OPT=$(grep '^o ' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[+-]?[0-9]{1,}')
RUNTIME_ROUNDINGSAT=$(grep 'real' $TMPDIR/${filename}_${config}_rstime.txt | grep -Eo '[0-9]{1,}[m][0-9]{1,}[.][0-9]{1,}')
CONFLICTS=$(grep '^c conflicts' $TMPDIR/${filename}_${config}_rs.txt | grep -Eo '[0-9]{1,}')
STATUS=$(grep '^s ' $TMPDIR/${filename}_${config}_rs.txt | grep -Po 's\s\K.*')

echo "$filename with $config"
echo "conflicts: $CONFLICTS"
echo "roundingsat status: $STATUS"
echo "found optimum: $FOUND_OPT"
echo "total runtime Roundingsat: $RUNTIME_ROUNDINGSAT"

writeback $config

rm $TMPDIR/${filename}_${config}_rs.txt
rm $TMPDIR/${filename}_${config}_rstime.txt
#rm $TMPDIR/${filename}_${config}_opb.opb

cd $VSC_DATA
rm core.*
