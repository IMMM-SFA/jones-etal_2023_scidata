#!/bin/csh
module load cdo
module load nco
#This script calculates delta
#Following details needs to be changed for different scenarios and sensitivity
set his_dir    = ../WRF-TGW-Delta/delta_calc/data/historical/
set ssp_dir    = ../WRF-TGW-Delta/delta_calc/data/ssp245/
set var2d      = (hurs tas tos ts)
set var3d      = (hur ta)
set UNDERSCORE = _
set FNAME1     = _Amon_ColdModelMean
set FNAME11    = _Omon_ColdModelMean
set FNAME1a    = _Amon_ColdModelMean
set FNAME11a   = _Omon_ColdModelMean
set his        = _historical_
set ssp        = _ssp245_
set FNAME2     = r1i1p1f1_gn_
set ensAvg     = ensAvg

set yearhis = 1978
set yearssp = 2018
while($yearhis < 2020 & $yearssp < 2060)
echo $yearhis
echo $yearssp
foreach i ($var2d)
echo $i

if ($i == "tos")then
ncdiff ${ssp_dir}$i$FNAME11$ssp$yearssp$UNDERSCORE$ensAvg.MovingAvg.1deg.nc  ${ssp_dir}$i$FNAME11$ssp$yearhis$UNDERSCORE$ensAvg.MovingAvg.1deg.nc ${ssp_dir}$i$FNAME11a$ssp$yearssp.minus.$yearhis$UNDERSCORE$ensAvg.MovingAvg.delta.1deg.nc

else

ncdiff ${ssp_dir}$i$FNAME1$ssp$yearssp$UNDERSCORE$ensAvg.MovingAvg.1deg.nc  ${ssp_dir}$i$FNAME1$ssp$yearhis$UNDERSCORE$ensAvg.MovingAvg.1deg.nc ${ssp_dir}$i$FNAME1a$ssp$yearssp.minus.$yearhis$UNDERSCORE$ensAvg.MovingAvg.delta.1deg.nc


endif


end


foreach i ($var3d)
ncdiff ${ssp_dir}$i$FNAME1$ssp$yearssp.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc ${ssp_dir}$i$FNAME1$ssp$yearhis.era5.level$UNDERSCORE$ensAvg.MovingAvg.1deg.nc ${ssp_dir}$i$FNAME1a$ssp$yearssp.minus.$yearhis.era5.level$UNDERSCORE$ensAvg.MovingAvg.delta.1deg.nc
end

@ yearssp++
@ yearhis++


end
