#!/bin/bash

for dir in ./MIPLIB01/*/*/ ; do
    dir=${dir%*/}
    for instance in "$dir"/*.bz2 ; do
        echo $instance
        bzip2 -d "$instance"
    done
done


