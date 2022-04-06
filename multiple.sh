#!/bin/bash

#SBATCH --job-name=CMS
#SBATCH --time=100:05:00
#SBATCH --ntasks=20
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=6144

#module load CMake/3.20.1-GCCcore-10.3.0
#module load Python/3.9.5-GCCcore-10.3.0
#module load parallel/20210622-GCCcore-10.3.0
#module load boost/.....

instances=instances2011
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
#parallel -j $SLURM_NTASKS srun -N1 -n1 -c1 --exclusive ::: $(ls -1 ./running_scripts2010/*.sh)
#wait