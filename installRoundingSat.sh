#!/bin/bash

module purge
module load GCC/10.3.0
module load CMake/3.20.1-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

cd ../roundingsat
cd build

cmake -DCMAKE_BUILD_TYPE=Release -Dsoplex=ON ..
make
