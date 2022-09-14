#!/bin/bash
#SBATCH --job-name=solveInstancesNS
#SBATCH --time=24:00:00
#SBATCH --ntasks=20

home=$(pwd)
bench=instOPT
instances=$VSC_SCRATCH/$bench
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")
config0="no_symm_breaking"
results=results_roundingsat_noBreak_$bench
mkdir $home/$results

mkdir $VSC_SCRATCH_VO_USER/running_scripts_nosymm_$bench
scripts=$VSC_SCRATCH_VO_USER/running_scripts_nosymm_$bench/

for filename in $(ls "$instances"); do
    sed "s/FILENAME/$filename/g" $home/singleSolveNS.sh > $scripts/${filename}.sh
    sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}.sh
    sed -i "s/CONFIG/$config0/g" $scripts/${filename}.sh
    sed -i "s/LOC/$results/g" $scripts/${filename}.sh
    chmod +x $scripts/${filename}.sh
    #sbatch --job-name=${filename}_simpleSolve $scripts/${filename}.sh
	#sleep 0.5
done

parallel -j $SLURM_NTASKS --joblog joblog.txt srun -N 1 -n 1 -c 1 --exact ::: $scripts/*.sh