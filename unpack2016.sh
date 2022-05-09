#!/bin/bash

cd $VSC_SCRATCH

wget http://www.cril.univ-artois.fr/PB16/bench/PB16-used.tar

tar -xvf PB16-used.tar

mv PB06/final/normalized-PB06/ instances06
rm -r PB06

mv PB07/normalized-PB07/ instances07
rm -r PB07

mv PB09//normalized-PB09/ instances09
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

rm PB16-used.tar

for dir in instances*/ ; do
    find "$dir" -type d -name *NLC* -exec rm -rf {} \;
    find "$dir" -type d -name *BIGINT* -exec rm -rf {} \;
    find "$dir" -type d -name *MEDINT* -exec rm -rf {} \;
    find "$dir" -type d -name *SOFT* -exec rm -rf {} \;
    find "$dir" -type d -name *PARTIAL* -exec rm -rf {} \;
done

for dir in instances*/ ; do
    dir=${dir%*/}
    for family in "$dir"/*/ ; do
        family=${family%*/}
        find "$family" -mindepth 2 -type f -exec mv -t "$family" -f '{}' +
        rm -r "$family"/*/
    done
done

for dir in instances*/ ; do
    dir=${dir%*/}
    for family in "$dir"/*/ ; do
        family=${family%*/}
        for instance in "$family"/* ; do
            instance=${instance%*/}
            new=$(echo "$instance" | tr "/" "-" | tr " " "_")
            mv "$instance" "$family/$new"
        done
    done
done

for dir in instances*/ ; do
    dir=${dir%*/}
    for family in "$dir"/*/ ; do
        family=${family%*/}
        for instance in "$family"/*.bz2 ; do
            echo $instance
            bzip2 -d "$instance"
        done
    done
done


