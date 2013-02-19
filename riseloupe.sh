#!/bin/bash


##
## riseloupe
## get images to given coordinates/icerise
##

# boxlength
WINDOW=10000

## gmtset #############################################################
gmtset PAPER_MEDIA a4+
gmtset PAGE_ORIENTATION portrait 
gmtset ANNOT_FONT_SIZE 16

gmtset ANNOT_FONT_PRIMARY  Helvetica
gmtset ANNOT_OFFSET_PRIMARY 0.2c
gmtset LABEL_FONT Helvetica
gmtset LABEL_FONT_SIZE 16
gmtset LABEL_OFFSET 0.4c
gmtset OBLIQUE_ANNOTATION 34
gmtset PLOT_DEGREE_FORMAT ddd:mm:ssF
#gmtset OBLIQUE_ANNOTATION 1 # reset to default
gmtset HEADER_FONT_SIZE 18

gmtset COLOR_NAN 170/170/170
gmtset COLOR_FOREGROUND 70/0/0

########################################################################
data_sets=/scratch/clisap/landice/data_sets

output="./output"

# set region
./make_window.sh $1 $2 $WINDOW
source reg.sh

HANDLE=$3

mamm_velo_loc="MAG_reg5.grd"

## colors
coastcolor="grey"
groundcolor="grey"
rgroundcolor="232/124/26"


## MAKE CPT
cpt1="_dem.cpt"
cpt2="_velo.cpt"
cpt3="cont.cpt"
cpt4="_gray.cpt"

makecpt -Crainbow -T0/100/5 -Z > $cpt1


## LINES
coastline="$data_sets/MOA/MOA_lines/raw_data/coastlines/moa_coastline.gmt"
groundingline="$data_sets/MOA/MOA_lines/raw_data/coastlines/moa_groundingline.gmt"
islands="$data_sets/MOA/MOA_lines/raw_data/coastlines/moa_islands.gmt"

## BASEMAP GRIDS
polargrid_10_50km="psbasemap $REGION_pro_XY $REGION_reg_XY_km "-Bg10a50/g10a50eSnW" -O -K"


## scalebars
ypos=`echo $REGION_sy/2 | bc`
xpos=20.5
scaleann="-Bf5a10:::,:/f5a10:m::,::.:ws"
width=0.35

## output
eps_rignot=$output/${HANDLE}_rignot.eps
eps_mamm=$output/${HANDLE}_mamm.eps


## RIGNOT VELOCITY
DATA="RIGNOT VELOCITY"
echo $DATA

makecpt -Crainbow -T10/350/3 -Qo -Z -M > $cpt2
psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_rignot
grdimage /scratch/clisap/landice/data_sets/Rignot_velocities/MAG.grd $REGION_pro_XY $REGION_reg_XY -C$cpt2 -Q -O -K >> $eps_rignot

## arrows
#awk 'NR%5==0' /scratch/clisap/landice/data_sets/Rignot_velocities/arrow_dir.xyz | \
#  psxy $REGION_pro_XY $REGION_reg_XY -SV0.003i/0.06i/0.05i -Gblack -O -K >> $eps_rignot

## scale
psscale -D$xpos/$ypos/$REGION_sy/$width -C$cpt2 -Ef -L  \
        -B/:'m a@+-1@+':  -O -K >> $eps_rignot

## lines
psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_rignot
psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_rignot
psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_rignot

## grid
$polargrid_10_50km >> $eps_rignot

## finish
psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_rignot
echo "done"

## MAMM VELOCITY
DATA="MAMM VELOCITY"
echo $DATA

makecpt -Crainbow -T0/3/1 -Qi -Z -M > $cpt2
psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_mamm
grdimage $data_sets/MAMM/work/$mamm_velo_loc $REGION_pro_XY $REGION_reg_XY -C$cpt2 -Q -O -K >> $eps_mamm

psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_mamm
psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_mamm
psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_mamm

## grid
$polargrid_10_50km >> $eps_mamm
psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_mamm
echo "done"








## clean

rm *.cpt








