#!/bin/bash


##
## riseloupe
## get images to given coordinates/icerise
##

## defaults
do_rignot=false
do_mamm=false
do_ramp=false
do_bamber=false
do_rampdem=false
do_icesat=false
do_icetrack=false

while getopts x:y:h:rmpbRit o
do    case "$o" in
      x)    X="$OPTARG";;
      y)    Y="$OPTARG";;
      h)    HANDLE="$OPTARG";;
      r)    do_rignot=true;;
      m)    do_mamm=true;;
      p)    do_ramp=true;;
      b)    do_bamber=true;;
      R)    do_rampdem=true;;
      i)    do_icesat=true;;
      t)    do_icetrack=true;;
      [?])  echo -e >&2 `cat usage.txt`
            exit 1;;
      esac
done


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
./make_window.sh $X $Y $WINDOW
source reg.sh


mamm_velo_loc="MAG_reg5.grd"

## colors
coastcolor="grey"
groundcolor="grey"
rgroundcolor="232/124/26"
## ramp colors
rampcoast="80/148/209"
rampground="96/132/170"
rampisland="243/208/0"


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
eps_ramp=$output/${HANDLE}_ramp.eps
eps_bamber=$output/${HANDLE}_bamber.eps
eps_rampdem=$output/${HANDLE}_rampdem.eps
eps_icesat=$output/${HANDLE}_icesat.eps
eps_icetrack=$output/${HANDLE}_icetrack.eps


## RIGNOT VELOCITY
if [ "$do_rignot" = true ]; then
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
fi

## MAMM VELOCITY
if [ "$do_mamm" = true ]; then
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
fi

## RAMP
if [ "$do_ramp" = true ]; then
  DATA="RAMP"
  echo $data
  
  makecpt -Cgray -T0/255/1 > $cpt4
  psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_ramp
  grdimage $data_sets/RAMP/geoTIF_V2/amm125m_v2_200m.grd $REGION_pro_XY $REGION_reg_XY -C$cpt4 -Q -O -K >> $eps_ramp
  
  psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$rampcoast  -O -K >> $eps_ramp
  psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$rampground  -O -K >> $eps_ramp
  psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,$rampisland  -O -K >> $eps_ramp
  
  ## grid
  $polargrid_10_50km >> $eps_ramp
  psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_ramp
  echo "done"
fi

## BAMBER DEM
if [ "$do_bamber" = true ]; then
  DATA="BAMBER DEM"
  echo $DATA
  
  psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_bamber
  grdimage $data_sets/Bamber_et_al_2009_1kmDEM/krigged_dem_nsidc.grd $REGION_pro_XY $REGION_reg_XY -C$cpt1 -Q -O -K >> $eps_bamber
  
  psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_bamber
  psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_bamber
  psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_bamber
  
  psscale -D$xpos/$ypos/$REGION_sy/$width -C$cpt1 -Ef  \
         "$scaleann"  -O -K >> $eps_bamber
  
  $polargrid_10_50km >> $eps_ramp
  psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_ramp
  echo "done"
fi

## RAMP DEM
if [ "$do_rampdem" = true ]; then
  DATA="RAMP DEM"
  echo $data
  
  psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_rampdem
  grdimage $data_sets/RAMP/RAMP200m_dem_v2/ramp200dem_wgs_v2.bin.grd $REGION_pro_XY $REGION_reg_XY -C$cpt1 -Q -O -K >> $eps_rampdem
  
  psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_rampdem
  psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_rampdem
  psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_rampdem
  
  psscale -D$xpos/$ypos/$REGION_sy/$width -C$cpt1 -Ef  \
          "$scaleann"  -O -K >> $eps_rampdem
  
  $polargrid_10_50km >> $eps_rampdem
  psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_rampdem
  echo "done"
fi

## ICESAT DEM
if [ "$do_icesat" = true ]; then
  DATA="ICESAT DEM"
  echo $DATA
  
  psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_icesat
  grdimage $data_sets/nsidc0304_icesat_antarctic_dem/NSIDC_Ant500m_wgs84_elev_m_S71.grd $REGION_pro_XY $REGION_reg_XY -C$cpt1 -Q -O -K >> $eps_icesat
  
  psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_icesat
  psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_icesat
  psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_icesat
  
  psscale -D$xpos/$ypos/$REGION_sy/$width -C$cpt1 -Ef  \
          "$scaleann"  -O -K >> $eps_icesat
  
  $polargrid_10_50km >> $eps_icesat
  psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_icesat
  echo "done"
fi

## ICESAT TRACKS
if [ "$do_icetrack" = true ]; then
  DATA="ICESAT TRACKS"
  echo $DATA
  
  psbasemap $REGION_pro_XY $REGION_reg_XY -B0:."$HANDLE - $DATA": -K  > $eps_icetrack
  # ramp background
  grdimage $data_sets/RAMP/geoTIF_V2/amm125m_v2_200m.grd $REGION_pro_XY $REGION_reg_XY -C$cpt4 -Q -O -K >> $eps_icetrack
  
  # tracks
  cat $data_sets/ICESat/ICESat_v33/GLAS_elev_shelf.asci | \
      gmtconvert -F0,1,2 | \
      psxy $REGION_pro_XY $REGION_reg_XY $reg_XY -Sp3p -C$cpt1 -O -K >> $eps_icetrack
  
  psxy $coastline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$coastcolor  -O -K >> $eps_icetrack
  psxy $groundingline -M $REGION_pro_XY $REGION_reg_XY  -W2p,$groundcolor  -O -K >> $eps_icetrack
  psxy $islands -M $REGION_pro_XY $REGION_reg_XY  -W1p,black  -O -K >> $eps_icetrack
  
  psscale -D$xpos/$ypos/$REGION_sy/$width -C$cpt1 -Ef  \
          "$scaleann"  -O -K >> $eps_icetrack
  
  $polargrid_10_50km >> $eps_icetrack
  psxy -R0/1/0/1 -JX1 -O /dev/null >> $eps_icetrack
  echo "done"
fi





## clean

rm *.cpt









