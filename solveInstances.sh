#!/bin/bash

home=$(pwd)
bench=instOPT
instances=$VSC_SCRATCH/$bench
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")

results=results_roundingsat_$bench
mkdir $home/$results

mkdir $VSC_SCRATCH_VO_USER/running_scripts_$bench/
scripts=$VSC_SCRATCH_VO_USER/running_scripts_$bench/

CONFIG1="strongsymm_shortpb_noopt"

CONFIG2="strongsymm_shortpb_opt"

#CONFIG3="strongsymm_longpb_noopt"

#CONFIG4="strongsymm_longpb_opt"

CONFIG5="weaksymm_shortpb_noopt"

CONFIG6="weaksymm_shortpb_opt"

#CONFIG7="weaksymm_longpb_noopt"

#CONFIG8="weaksymm_longpb_opt"

ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG5" "$CONFIG6")

#ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4")

for filename in $(ls "$instances"); do
    for i in "${!ALLCONFIGS[@]}"; do
        sed "s/FILENAME/$filename/g" $home/singleSolve.sh > $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sed -i "s/LOC/$results/g" $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        chmod +x $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sbatch --job-name=solve_${filename}_${ALLCONFIGS[$i]} $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
	sleep 0.5
    done
done
