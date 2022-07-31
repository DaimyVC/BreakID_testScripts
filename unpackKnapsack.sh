#!/bin/bash

cd $VSC_SCRATCH

tar -xf knapsack.tar

for dir in ./KNAP/* ; do
    dir=${dir%*/}
    for instance in "$dir"/*.bz2 ; do
        echo $instance
        bzip2 -d "$instance"
    done
done


