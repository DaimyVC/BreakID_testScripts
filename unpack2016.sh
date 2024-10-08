#!/bin/bash

cd $VSC_SCRATCH

wget http://www.cril.univ-artois.fr/PB16/bench/PB16-used.tar
tar -xvf PB16-used.tar

mv PB06/final/normalized-PB06/ instances06
rm -r PB06

mv PB07/normalized-PB07/ instances07
rm -r PB07

mv PB09/normalized-PB09/ instances09
rm -r PB09

mv PB10/normalized-PB10/ instances10
rm -r PB10

mv PB11/normalized-PB11/ instances11
rm -r PB11

mv PB12/normalized-PB12/ instances12
rm -r PB12

mv PB15eval/normalized-PB15eval/ instances15
rm -r PB15eval

mv PB16/normalized-PB16/ instances16
rm -r PB16

for dir in instances*/ ; do
    find "$dir" -type d -name *NLC* -exec rm -rf {} \;
    find "$dir" -type d -name *BIGINT* -exec rm -rf {} \;
    find "$dir" -type d -name *MEDINT* -exec rm -rf {} \;
    find "$dir" -type d -name *SOFT* -exec rm -rf {} \;
    find "$dir" -type d -name *PARTIAL* -exec rm -rf {} \;
done

mkdir inst-OPT
mkdir inst-DEC

for dir in instances*/ ; do
    find "$dir" -type f -name '*OPT*' -exec mv -i {} inst-OPT/  \;
    find "$dir" -type f -name '*DEC*' -exec mv -i {} inst-DEC/  \;
    find "$dir" -type f -name '*SATUNSAT*' -exec mv -i {} inst-DEC/  \;
done


