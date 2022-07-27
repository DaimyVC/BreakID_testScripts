#!/bin/bash

home=$(pwd)
instances=$VSC_SCRATCH/06_doubles
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")

mkdir $home/results_breakid

SHORTPB="-pb 0"
LONGPB="-pb 16"
NOOPT="-no-bin -no-small -no-row"
#WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG1="strongsymm_shortpb_noopt"
A1="$SHORTPB $NOOPT $NORELAX"

CONFIG2="strongsymm_shortpb_opt"
A2="$SHORTPB $NORELAX"

CONFIG3="strongsymm_longpb_noopt"
A3="$LONGPB $NOOPT $NORELAX"

CONFIG4="strongsymm_longpb_opt"
A4="$LONGPB $NORELAX"

#CONFIG5="weaksymm_shortpb_noopt"
#A5="$WEAKSYMM $SHORTPB $NOOPT $NORELAX"

#CONFIG6="weaksymm_shortpb_opt"
#A6="$WEAKSYMM $SHORTPB $NORELAX"

#CONFIG7="weaksymm_longpb_noopt"
#A7="$WEAKSYMM $LONGPB $NOOPT $NORELAX"

#CONFIG8="weaksymm_longpb_opt"
#A8="$WEAKSYMM $LONGPB $NORELAX"

ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4")
ALLARGS=("$A1" "$A2" "$A3" "$A4")

mkdir $home/running_scripts_break06d/
scripts=$home/running_scripts_break06d/

for filename in $(ls "$instances"); do
    for i in "${!ALLCONFIGS[@]}"; do
        sed "s/FILENAME/$filename/g" $home/singleBreak.sh > $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/ARGS/${ALLARGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        chmod +x $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sbatch --job-name=$break_${filename}_{ALLCONFIGS[$i]} $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
	sleep 0.5
    done
done
