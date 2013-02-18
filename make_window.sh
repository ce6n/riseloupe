#!/bin/bash

##
## make_window.sh
## get window coordinates from center coordinate
## sebastian 2013-02-18

# center coordinates in polarstereographic projection
# default window

WINDOWLENGTH=100000

# center
X=$1
Y=$2
WINDOW=$3


llx=`echo $X | awk -v "window=$WINDOWLENGTH" '{print $1-window/2}'`
lly=`echo $Y | awk -v "window=$WINDOWLENGTH" '{print $1-window/2}'`

urx=`echo $X | awk -v "window=$WINDOWLENGTH" '{print $1+window/2}'`
ury=`echo $Y | awk -v "window=$WINDOWLENGTH" '{print $1+window/2}'`


# call script to make region
./mkregparameter.sh $llx $lly $urx $ury
