#!/bin/bash

cd $VSC_SCRATCH

tar -xvf all_instances.tar.gz

cd ALL
mv * $VSC_SCRATCH
cd ..
rmdir ALL

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


