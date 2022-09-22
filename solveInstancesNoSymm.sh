#!/bin/bash
#SBATCH --job-name=solveInstancesNS
#SBATCH --time=5-00:00:00
#SBATCH --ntasks=20
#SBATCH --mem-per-cpu=16g
#SBATCH --partition=skylake,skylake_mpi

module load parallel/20210622-GCCcore-10.3.0

home=$(pwd)
bench=MIPOPT
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

parallel --delay 0.2 -j $SLURM_NTASKS --joblog joblog.txt --resume srun --time=1:00:00 -N 1 -n 1 -c 1 --exact ::: $(ls -1 $scripts/*.sh)
wait
