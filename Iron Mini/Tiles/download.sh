#!/bin/bash

# Sicily map
# https://oms.wff.ch/calc.htm
# (71235-70059+1)*(51200-50410+1
# 1177 * 791 = 931007

mkdir 17
for (( xTile=70059; xTile<=71235; xTile++ ))
do
    mkdir 17/$xTile
    for (( yTile=50410; yTile<=51200; yTile++ ))
    do
        curl 'http://mt1.google.com/vt/lyrs=r&x='"$xTile"'&y='"$yTile"'&z=17&apistyle=s.e%3Al.i%7Cp.v%3Aoff&s=Galileo&style=api%7Csmartmaps' --output 17/$xTile/$yTile.png
    done
done
