#!/bin/csh
module load cdo
module load nco
#This script calculate moving averages
#The following deltails need to be changed for different scenarios and sensitivity
set ssp_dir  = ../WRF-TGW-Delta/delta_calc/data/ssp245/
set var      = (hur hurs ta tas tos ts)
set var2d    = (hurs tas tos ts)
set var3d    = (hur ta)
set UNDERSCORE = _
set FNAME1     = _Amon_ColdModelMean
set FNAME11    = _Omon_ColdModelMean
set his        = _historical_
set ssp        = _ssp245_
set FNAME2     = r1i1p1f1_gn_
set ensAvg     = ensAvg
set year       = 1978
while($year < 2100)
@ year_m5 = $year - 5
@ year_m4 = $year - 4
@ year_m3 = $year - 3
@ year_m2 = $year - 2
@ year_m1 = $year - 1
@ year_p1 = $year + 1
@ year_p2 = $year + 2
@ year_p3 = $year + 3
@ year_p4 = $year + 4
@ year_p5 = $year + 5
echo $year
foreach i ($var3d)
echo $i

if ($year > 1977 && $year < 2096) then
#11 Years Moving Average

ncea ${ssp_dir}$i$FNAME1$ssp$year_m5.era5.level$UNDERSCORE$ensAvg.1deg.nc   ${ssp_dir}$i$FNAME1$ssp$year_m4.era5.level$UNDERSCORE$ensAvg.1deg.nc   ${ssp_dir}$i$FNAME1$ssp$year_m3.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year_m2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_m1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p3.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year_p4.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p5.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc

else if ($year == 2096) then
#9 Years Moving Average

ncea ${ssp_dir}$i$FNAME1$ssp$year_m4.era5.level$UNDERSCORE$ensAvg.1deg.nc   ${ssp_dir}$i$FNAME1$ssp$year_m3.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year_m2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_m1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p3.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year_p4.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc

else if ($year == 2097) then
#7 Years Moving Average

ncea ${ssp_dir}$i$FNAME1$ssp$year_m3.era5.level$UNDERSCORE$ensAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$year_m2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_m1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p3.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc

else if ($year == 2098) then
#5 Years Moving Average

ncea ${ssp_dir}$i$FNAME1$ssp$year_m2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_m1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p2.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc

else if ($year == 2099) then
#3 Years Moving Average

ncea ${ssp_dir}$i$FNAME1$ssp$year_m1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year_p1.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$year.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc

endif


end
@ year++


end
