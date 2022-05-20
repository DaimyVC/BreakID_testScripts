#!/bin/bash
#
#SBATCH --job-name=single_break
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=skylake
#SBATCH --mem-per-cpu=16g

ROOT_DIR=$(pwd)
scratch=$VSC_SCRATCH
instance=$scratch/instances16/OPT-SMALLINT-LIN/instances16-OPT-SMALLINT-LIN-normalized-single-obj-f18-AC1Loss.seq-B-3-1-irEDCBA.opb

cat $instance | $ROOT_DIR/BreakID -pb 0 -ws -v 7 -no-row -no-bin -no-small 1> opb.opb 2> result.txt