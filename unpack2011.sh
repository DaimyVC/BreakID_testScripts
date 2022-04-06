#!/bin/bash

cd $VSC_SCRATCH

wget http://www.cril.univ-artois.fr/PB11/benchs/PB11-BIGINT.tar
wget http://www.cril.univ-artois.fr/PB11/benchs/PB11-SMALLINT.tar

mkdir instances2011

tar -xvf PB11-BIGINT.tar
mv PB11/normalized-PB11/OPT-BIGINT-LIN/ instances2011
rm -r PB11

tar -xvf PB11-SMALLINT.tar
mv PB11/normalized-PB11/OPT-SMALLINT-LIN/ instances2011
rm -r PB11

rm PB11-BIGINT.tar
rm PB11-SMALLINT.tar

for family in instances2011/ ; do
   find "$family" -type f -exec sh -c 'new=$(echo "{}" | tr "/" "-" | tr " " "_"); mv "{}" instances2011/"$new"' \;
done

rm -rf instances2011/*/

for instance in instances2011/*.bz2 ; do
    bzip2 -d "$instance"
done
