#!/bin/bash

home=$(pwd)
instances=$VSC_SCRATCH/inst06
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")
config0="no_symm_breaking"

mkdir $home/results_roundingsat
results=$home/results_roundingsat

mkdir $home/running_scripts06/
scripts=$home/running_scripts06/

SHORTPB="-pb 0"
LONGPB="-pb 8"
NOOPT="-no-bin -no-small -no-row"
WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG1="strongsymm_shortpb_noopt"
A1="$SHORTPB $NOOPT $NORELAX"
CONFIG2="strongsymm_shortpb_opt"
A2="$SHORTPB $NORELAX"
CONFIG3="weaksymm_shortpb_opt"
A3="$WEAKSYMM $SHORTPB $NORELAX"
CONFIG4="weaksymm_longpb_opt"
A4="$WEAKSYMM $LONGPB $NORELAX"
CONFIG5="weaksymm_longpb_noopt"
A5="$WEAKSYMM $LONGPB $NOOPT $NORELAX"
CONFIG6="weaksymm_shortpb_noopt"
A6="$WEAKSYMM $SHORTPB $NOOPT $NORELAX"
CONFIG7="strongsymm_longpb_noopt"
A7="$LONGPB $NOOPT $NORELAX"
CONFIG8="strongsymm_longpb_opt"
A8="$LONGPB $NORELAX"

ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4" "$CONFIG5" "$CONFIG6" "$CONFIG7" "$CONFIG8")
ALLARGS=("$A1" "$A2" "$A3" "$A4" "$A5" "$A6" "$A7" "$A8")

for filename in $(ls "$instances"); do
    for i in "${!ALLCONFIGS[@]}"; do
        sed "s/FILENAME/$filename/g" $home/singleSolve.sh > $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        chmod +x $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
        sbatch --job-name=solve_${filename}_${ALLCONFIGS[$i]} $scripts/${filename}_${ALLCONFIGS[$i]}_solve.sh
	sleep 0.5
    done
done
