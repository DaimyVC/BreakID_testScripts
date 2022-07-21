#!/bin/bash

home=$(pwd)
instances=$VSC_SCRATCH/inst06
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")
config0="no_symm_breaking"

mkdir $home/results_roundingsat_NS
results=$home/results_roundingsat_NS

mkdir $home/running_scripts_nosymm
scripts=$home/running_scripts_nosymm/

for filename in $(ls "$instances"); do
    sed "s/FILENAME/$filename/g" $home/singleSolveNS.sh > $scripts/${filename}.sh
    sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}.sh
    sed -i "s/CONFIG/$config0/g" $scripts/${filename}.sh
    chmod +x $scripts/${filename}.sh
    sbatch --job-name=${filename}_simpleSolve $scripts/${filename}.sh
	sleep 0.5
done
