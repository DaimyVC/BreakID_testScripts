#!/bin/bash

#SBATCH --job-name=BID
#SBATCH --time=100:05:00
#SBATCH --ntasks=20
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=6144

module purge
module load parallel/20210622-GCCcore-10.3.0
module load CMake/3.20.1-GCCcore-10.3.0
module load make/4.3-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

instances=$VSC_SCRATCH/instances
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")
mkdir running_scripts

for filename in $(ls "$instances")
do
    sed "s/TIME_L/1800/g" single.sh > running_scripts/${filename}.sh
    sed -i "s/MEM_L/512/g" running_scripts/${filename}.sh
    sed -i "s/FILENAME/$filename/g" running_scripts/${filename}.sh
    sed -i "s/INSTANCES/$instances_escaped/g" running_scripts/${filename}.sh
    chmod +x running_scripts/${filename}.sh
done

srun="srun -N1 -n1 -c1 --exclusive"
parallel="parallel -j $SLURM_NTASKS"

#$parallel "$srun" ::: $(ls -1 ./running_scripts/*sh)
wait
