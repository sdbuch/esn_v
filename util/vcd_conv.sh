#!/bin/bash

# Simple script to convert a ModelSim .vcd file, which has
# all nets listed (even buses) as separate 1 bit values, into a better
# format which keeps buses declared as such in the raw module files
# in the bus format in the .vcd file.
#
# Call with one argument, the .vcd filename (with or without extension)
# that should be converted.
#
# Utilities called by this script require gtkwave to be installed.

args=("$@")
path=${args[0]}

filename=$(basename "$path")
extension="${filename##*.}"
filename="${filename%.*}"

a='vcd2vzt '
b='.vcd '
c='_tmp.vzt '
d=$a$filename$b$filename$c
eval $d

e='vzt2vcd '
f='-c > '
g='_new.vcd'
h=$e$filename$c$f$filename$g
eval $h

k='rm -f '
m=$k$filename$c
eval $m

#echo `vcd2vzt $filename.vcd $filename_tmp.vzt`
#echo `vzt2vcd $filename_tmp.vzt $filename_new.vcd`
