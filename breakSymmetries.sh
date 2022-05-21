#!/bin/bash

home=$(pwd)
instances=$VSC_SCRATCH/instances16/OPT-SMALLINT-LIN
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")

mkdir $home/results_breakid16_OPT
res=$home/results_breakid16_OPT

SHORTPB="-pb 0"
LONGPB="-pb 28"
NOOPT="-no-bin -no-small -no-row"
WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG1="strongsymm_shortpbconstr_noopt"
A1="$SHORTPB $NOOPT $NORELAX"
CONFIG2="strongsymm_shortpbconstr_opt"
A2="$SHORTPB $NORELAX"
CONFIG3="weaksymm_shortpb_opt"
A3="$WEAKSYMM $SHORTPB $NORELAX"
CONFIG4="weaksymm_longpb_opt"
A4="$WEAKSYMM $LONGPB $NORELAX"


ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4")
ALLARGS=("$A1" "$A2" "$A3" "$A4")

mkdir $home/running_scripts_break/
scripts=$home/running_scripts_break/

for filename in $(ls "$instances"); do
    for i in "${!ALLCONFIGS[@]}"; do
        sed "s/FILENAME/$filename/g" $home/singleBreak.sh > $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/RESULTS/$res/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/ARGS/${ALLARGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        chmod +x $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sbatch --job-name=$break_${filename}_{ALLCONFIGS[$i]} $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh &
    done
done
