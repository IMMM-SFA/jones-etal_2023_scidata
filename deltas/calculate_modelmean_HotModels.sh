#!/bin/csh
module load cdo
module load nco
#This script calculates mean based on model sensitivity
set ssp_dir    = ../WRF-TGW-Delta/delta_calc/data/ssp245/
set var        = (hur ta)
set var2d      = (hurs tas tos ts)
set var3d      = (hur ta)
set UNDERSCORE = _
set FNAME1     = _Amon_CanESM5
set FNAME11    = _Omon_CanESM5
set FNAME2     = _Amon_UKESM1-0-LL
set FNAME22    = _Omon_UKESM1-0-LL
set FNAME3     = _Amon_HadGEM3-GC31-LL
set FNAME33    = _Omon_HadGEM3-GC31-LL
set FNAME4     = _Amon_CNRM-CM6-1-HR
set FNAME44    = _Omon_CNRM-CM6-1-HR
set FNAMEmm1   = _Amon_HotModelMean
set FNAMEmm11  = _Omon_HotModelMean

set his        = _historical_
#Scenario should be changed accordingly
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
