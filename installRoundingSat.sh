#!/bin/bash

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
