#!/bin/bash

home=$(pwd)
instances=$VSC_SCRATCH/instances2011
instances_escaped=$(sed 's;/;\\/;g' <<< "$instances")

SHORTPB="-pb 0"
LONGPB="-pb 28"
NOOPT="-no-bin -no-small -no-row"
WEAKSYMM="-ws"
NORELAX="-no-relaxed"

CONFIG1="strongsymm_shortpbconstr_noopt"
A1="$SHORTPB $NOOPT"
CONFIG2="strongsymm_shortpbconstr_opt"
A2="$SHORTPB"
CONFIG3="strongsymm_longpbconstr_noopt"
A3="$LONGPB $NOOPT"
CONFIG4="strongsymm_longpbconstr_opt"
A4="$LONGPB"
CONFIG5="weaksymm_shortpbconstr_noopt_relaxed"
A5="$WEAKSYMM $SHORTPB $NOOPT"
CONFIG6="weaksymm_shortpbconstr_noopt_notrelaxed"
A6="$WEAKSYMM $SHORTPB $NOOPT $NORELAX"
CONFIG7="weaksymm_shortpbconst_opt_relaxed"
A7="$WEAKSYMM $SHORTPB"
CONFIG8="weaksymm_shortpbconst_opt_notrelaxed"
A8="$WEAKSYMM $SHORTPB $NORELAX"
CONFIG9="weaksymm_longpbconstr_noopt_relaxed"
A9="$WEAKSYMM $LONGPB $NOOPT"
CONFIG10="weaksymm_longpbconstr_noopt_notrelaxed"
A10="$WEAKSYMM $LONGPB $NOOPT $NORELAX"
CONFIG11="weaksymm_longpbconstr_opt_relaxed"
A11="$WEAKSYMM $LONGPB"
CONFIG12="weaksymm_longpbconstr_opt_notrelaxed"
A12="$WEAKSYMM $LONGPB $NORELAX"

ALLCONFIGS=("$CONFIG1" "$CONFIG2" "$CONFIG3" "$CONFIG4" "$CONFIG5" "$CONFIG6" "$CONFIG7" "$CONFIG8" "$CONFIG9" "$CONFIG10" "$CONFIG11" "$CONFIG12")
ALLARGS=("$A1" "$A2" "$A3" "$A4" "$A5" "$A6" "$A7" "$A8" "$A9" "$A10" "$A11" "$A12")

rm -r $home/running_scripts
mkdir $home/running_scripts/
scripts=$home/running_scripts/

for filename in $(ls "$instances"); do
    for i in "${!ALLCONFIGS[@]}"; do
        sed "s/FILENAME/$filename/g" $home/singleBreak.sh > $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/INSTANCES/$instances_escaped/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/CONFIG/${ALLCONFIGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sed -i "s/ARGS/${ALLARGS[$i]}/g" $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        chmod +x $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh
        sbatch $scripts/${filename}_${ALLCONFIGS[$i]}_break.sh &
    done
done
