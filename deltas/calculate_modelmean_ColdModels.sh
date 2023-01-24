#!/bin/csh
module load cdo
module load nco
#This script calculates mean based on model sensitivity
set ssp_dir    = ../WRF-TGW-Delta/delta_calc/data/ssp245/
set var        = (hur ta)
set var2d      = (hurs tas tos ts)
set var3d      = (hur ta)
set UNDERSCORE = _
set FNAME1     = _Amon_GFDL-ESM4
set FNAME11    = _Omon_GFDL-ESM4
set FNAME2     = _Amon_NorESM2-MM
set FNAME22    = _Omon_NorESM2-MM
set FNAME3     = _Amon_ACCESS-ESM1-5
set FNAME33    = _Omon_ACCESS-ESM1-5
set FNAME4     = _Amon_GISS-E2-1-G
set FNAME44    = _Omon_GISS-E2-1-G
set FNAMEmm1   = _Amon_ColdModelMean
set FNAMEmm11  = _Omon_ColdModelMean

set his        = _historical_
set ssp        = _ssp245_
set ensAvg     = ensAvg
set yearssp    = 1970
while($yearssp < 2101)
echo $yearssp 
foreach i ($var2d)
echo $i

if ($i == "tos")then


ncea ${ssp_dir}$i$FNAME11$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME22$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME33$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME44$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAMEmm11$ssp$yearssp$UNDERSCORE$ensAvg.1deg.nc

else

ncea ${ssp_dir}$i$FNAME1$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME2$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME3$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME4$UNDERSCORE$yearssp$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAMEmm1$ssp$yearssp$UNDERSCORE$ensAvg.1deg.nc

endif
end

foreach i ($var3d)
echo $i

ncea ${ssp_dir}$i$FNAME1$UNDERSCORE$yearssp.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME2$UNDERSCORE$yearssp.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME3$UNDERSCORE$yearssp.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAME4$UNDERSCORE$yearssp.era5.level$UNDERSCORE$ensAvg.1deg.nc ${ssp_dir}$i$FNAMEmm1$ssp$yearssp.era5.level$UNDERSCORE$ensAvg.1deg.nc
end
@ yearssp++


end
