#!/bin/bash

cd ..
home=$(pwd)
instances=$VSC_SCRATCH/instances16/DEC-SMALLINT-LIN
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")
config="no_symm_breaking"

mkdir $home/results/
mkdir $home/results/roundingsat
mkdir $home/results/breakid

mkdir $home/running_scripts/
scripts=$home/running_scripts/

for filename in $(ls "$instances"); do
    sed "s/FILENAME/$filename/g" $home/singleSolve.sh > $scripts/${filename}.sh
    sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}.sh
    sed -i "s/CONFIG/$config/g" $scripts/${filename}.sh
    chmod +x $scripts/${filename}.sh
    sbatch --job-name=${filename}_simpleSolve $scripts/${filename}.sh &
done
