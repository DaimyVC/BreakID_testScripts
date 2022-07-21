#!/bin/bash

module purge
module load GCC/10.3.0
module load CMake/3.20.1-GCCcore-10.3.0
module load Boost/1.76.0-GCC-10.3.0

ROOT_DIR=$(pwd)

wget https://gitlab.com/MIAOresearch/roundingsat/-/archive/master/roundingsat-master.tar.gz
tar -xf roundingsat-master.tar.gz

cd roundingsat-master
cd build

cmake -DCMAKE_BUILD_TYPE=Release ..
make

mv roundingsat ../..
cd $ROOT_DIR
rm -rf roundingsat-master
rm -rf roundingsat-master.tar.gz
