#!/bin/bash

cd $VSC_SCRATCH

tar -xvf ALL.tar

rm ALL.tar

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


