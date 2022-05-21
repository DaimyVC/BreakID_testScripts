#!/bin/bash

module purge
module load GCC/9.3.0

ROOT_DIR=$(pwd)

cd ..
cd breakid/src

make

mv BreakID $ROOT_DIR

make clean
