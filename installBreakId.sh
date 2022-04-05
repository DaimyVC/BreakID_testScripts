#!/bin/bash

ROOT_DIR=$(pwd)

cd ..
cd breakid/src

make

mv BreakID $ROOT_DIR

make clean
