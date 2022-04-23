#!/bin/bash
#
#SBATCH --job-name=make_scripts
#SBATCH --time=03:00:00
#SBATCH --ntasks=20
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=16g

module purge
module load parallel/20210622-GCCcore-10.3.0
module load CMake/3.20.1-GCCcore-10.3.0
module load make/4.3-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

SHORTPB="-pb 0"
LONGPB="-pb 28"
NOOPT="-no-bin -no-small -no-row"
WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG0="no_symm_breaking"
A0=""
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

ALLCONFIGS=("$CONFIG0" "$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4" "$CONFIG5" "$CONFIG6" "$CONFIG7" "$CONFIG8" "$CONFIG9" "$CONFIG10" "$CONFIG11" "$CONFIG12")
ALLARGS=("$A0" "$A1" "$A2" "$A3" "$A4" "$A5" "$A6" "$A7" "$A8" "$A9" "$A10" "$A11" "$A12")

home=$(pwd)
instances=$VSC_SCRATCH/instances2011
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")

mkdir $home/running_scripts
mkdir $home/tmp
mkdir $home/results
mkdir $home/results/roundingsat
mkdir $home/results/breakid

for filename in $(ls "$instances")
do
    for i in "${!ALLCONFIGS[@]}"; do
        
        mkdir $home/running_scripts/"${filename}_${ALLCONFIGS[$i]}"
        script=$home/running_scripts/"${filename}_${ALLCONFIGS[$i]}"
        
        if [ "${ALLCONFIGS[$i]}" = "no_symm_breaking" ]
        then
            sed "s/FILENAME/$filename/g" $home/singleSolve.sh > $script/${filename}_solve.sh
            sed -i "s/INSTANCES/$instances_escaped/g" $script/${filename}_solve.sh
            sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $script/${filename}_solve.sh
            chmod +x $script/${filename}_solve.sh
            srun --job-name=${filename}_${config}_solve --mem-per-cpu=16g --time=1800 -N1 -n1 --partition=skylake --exclusive $script/${filename}_solve.sh
            
        else
            sed "s/FILENAME/$filename/g" $home/singleBreak.sh > $script/${filename}_break.sh
            sed -i "s/INSTANCES/$instances_escaped/g" $script/${filename}_break.sh
            sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $script/${filename}_break.sh
            sed -i "s/ARGS/${ALLARGS[$i]}/g" $script/${filename}_break.sh
            chmod +x $script/${filename}_break.sh
            jid=$(srun --job-name=${filename}_${config}_solve --mem-per-cpu=16g --time=1800 -N1 -n1 --partition=skylake --exclusive $script/${filename}_break.sh)

            sed "s/FILENAME/$filename/g" $home/singleSolve.sh > $script/${filename}_solve.sh
            sed -i "s/INSTANCES/$instances_escaped/g" $script/${filename}_solve.sh
            sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $script/${filename}_solve.sh
            chmod +x $script/${filename}_solve.sh
            srun --job-name=${filename}_${config}_break --mem-per-cpu=16g --dependency=afterok:$jid --partition=skylake --time=200 -N1 -n1 --exclusive $script/${filename}_solve.sh
        fi
    done
done
