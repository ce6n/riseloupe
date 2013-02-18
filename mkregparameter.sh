#!/bin/bash
########################################################################
##
## mkreg.sh 
##
## Time-stamp: <2011-01-21 10:54:26 (u290047)>
##
########################################################################

########################################################################
## PROJECTION base is WGS84 71S
##
## Image files are generated projected in the WGS 84 / Antarctic Polar 
## Stereographic (EPSG:3031) projection. This is a Polar Stereographic 
## projection centred on the South Pole, with a Latitude of True Scale 
## at 71°S. The datum is WGS 84.
##
########################################################################
projargs_S70="+proj=stere +units=m +ellps=WGS84 +lat_0=-90 +lon_0=0 +lat_ts=-70"
projargs_S71="+proj=stere +units=m +ellps=WGS84 +lat_0=-90 +lon_0=0 +lat_ts=-71"

projargs_utm33="+proj=utm +zone=33 +north +units=m +ellps=WGS84"




########################################################################
## Functions
########################################################################

# call with to_reg_XY llx lly urx ury
to_reg_XY () {
  echo "$1 $2 $3 $4" | \
	awk '{print "-R"$1"/"$2"/"$3"/"$4"r"}'
}

# call with to_reg_XY_km llx lly urx ury
to_reg_XY_km () {
  echo "$1 $2 $3 $4" | \
	awk '{print "-R"$1/1000"/"$2/1000"/"$3/1000"/"$4/1000"r"}'
}

# call with to_reg_ll llx lly urx ury
to_reg_ll () {
  cat <<EOF | invproj -f "%.8f" $projargs_S71 | tr '\n' ' ' | awk '{print "-Rd"$1"/"$2"/"$3"/"$4"r"}'
$1 $2
$3 $4
EOF
}

# call with sx2sy llx lly urx ury sx
sx2sy () {
  sx=$5
  sy=$(echo "scale=3; $sx * ($4 - $2)/($3 - $1) " | bc)
  echo "$sy"
}

########################################################################
## DEFAULT REGIONS
########################################################################
##
## 
##
REGION_llx=$1
REGION_lly=$2
REGION_urx=$3
REGION_ury=$4

REGION_reg_XY=$(to_reg_XY $REGION_llx $REGION_lly $REGION_urx $REGION_ury)
REGION_reg_XY_km=$(to_reg_XY_km $REGION_llx $REGION_lly $REGION_urx $REGION_ury)
REGION_reg_ll=$(to_reg_ll $REGION_llx $REGION_lly $REGION_urx $REGION_ury)
REGION_sx=20
REGION_sy=$(sx2sy $REGION_llx $REGION_lly $REGION_urx $REGION_ury $REGION_sx)
REGION_pro_XY=-JX${REGION_sx}c/${REGION_sy}c
REGION_pro_ll=-JS360/-90/${REGION_sx}

##
## output bash
##
cat <<EOF > reg.sh
## usage: source reg.sh
## Time-stamp: $(date)
##
REGION_llx=$REGION_llx
REGION_lly=$REGION_lly
REGION_urx=$REGION_urx
REGION_ury=$REGION_ury
REGION_reg_XY=$REGION_reg_XY
REGION_reg_XY_km=$REGION_reg_XY_km
REGION_reg_ll=$REGION_reg_ll
REGION_sx=$REGION_sx
REGION_sy=$REGION_sy
REGION_pro_XY=$REGION_pro_XY
REGION_pro_ll=$REGION_pro_ll
##

EOF

##
## output csh
##
#cat <<EOF > reg.csh
### usage: source reg.csh
### Time-stamp: $(date)
###
#set REGION_llx = $REGION_llx
#set REGION_lly = $REGION_lly
#set REGION_urx = $REGION_urx
#set REGION_ury = $REGION_ury
#set REGION_reg_XY = $REGION_reg_XY
#set REGION_reg_XY_km = $REGION_reg_XY_km
#set REGION_reg_ll = $REGION_reg_ll
#set REGION_sx = $REGION_sx
#set REGION_sy = $REGION_sy
#set REGION_pro_XY = $REGION_pro_XY
#set REGION_pro_ll = $REGION_pro_ll
###

#EOF






