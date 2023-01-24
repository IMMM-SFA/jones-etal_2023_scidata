#!/bin/csh
module load cdo
module load nco
#This scripts create ensemble mean for each CMIP6 GCM used for delta calculation
set his_dir    = ../WRF-TGW-Delta/delta_calc/data/historical/
set ssp_dir1   = ../WRF-TGW-Delta/delta_calc/data/ssp585/
set ssp_dir2   = ../WRF-TGW-Delta/delta_calc/data/ssp245
set var        = (hur ta)
set var2d      = (hurs tas tos ts)
set var3d      = (hur ta)
set UNDERSCORE = _
# The following lines needs to be changed according to the CMIP6 GCM,time period, scenario and number of ensemble members
set FNAME1     = _Amon_ACCESS-ESM1-5
set FNAME11    = _Omon_ACCESS-ESM1-5
set his        = _historical_
set ssp        = _ssp585_
set ens1       = r1i1p1f1_gn_
set ens2       = r2i1p1f1_gn_
set ens3       = r3i1p1f1_gn_
set ens4       = r4i1p1f1_gn_
set ens5       = r5i1p1f1_gn_
set ensAvg     = ensAvg
set yearhis    = 1970
while($yearhis < 2015)
echo $yearhis
foreach i ($var2d)
echo $i

if ($i == "tos")then

ncea ${his_dir}$i$FNAME11$his$ens1$yearhis.1deg.nc ${his_dir}$i$FNAME11$his$ens2$yearhis.1deg.nc ${his_dir}$i$FNAME11$his$ens3$yearhis.1deg.nc ${his_dir}$i$FNAME11$his$ens4$yearhis.1deg.nc ${his_dir}$i$FNAME11$his$ens5$yearhis.1deg.nc ${his_dir}$i$FNAME11$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc

cp ${his_dir}$i$FNAME11$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc $ssp_dir1
cp ${his_dir}$i$FNAME11$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc $ssp_dir2

else

ncea ${his_dir}$i$FNAME1$his$ens1$yearhis.1deg.nc ${his_dir}$i$FNAME1$his$ens2$yearhis.1deg.nc ${his_dir}$i$FNAME1$his$ens3$yearhis.1deg.nc ${his_dir}$i$FNAME1$his$ens4$yearhis.1deg.nc ${his_dir}$i$FNAME1$his$ens5$yearhis.1deg.nc ${his_dir}$i$FNAME1$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc

cp ${his_dir}$i$FNAME1$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc $ssp_dir1
cp ${his_dir}$i$FNAME1$UNDERSCORE$yearhis$UNDERSCORE$ensAvg.1deg.nc $ssp_dir2

endif
end

foreach i ($var3d)
echo $i
ncea ${his_dir}$i$FNAME1$his$ens1$yearhis.era5.level.1deg.nc ${his_dir}$i$FNAME1$his$ens2$yearhis.era5.level.1deg.nc ${his_dir}$i$FNAME1$his$ens3$yearhis.era5.level.1deg.nc ${his_dir}$i$FNAME1$his$ens4$yearhis.era5.level.1deg.nc ${his_dir}$i$FNAME1$his$ens5$yearhis.era5.level.1deg.nc ${his_dir}$i$FNAME1$UNDERSCORE$yearhis.era5.level$UNDERSCORE$ensAvg.1deg.nc

cp ${his_dir}$i$FNAME1$UNDERSCORE$yearhis.era5.level$UNDERSCORE$ensAvg.1deg.nc $ssp_dir1
cp ${his_dir}$i$FNAME1$UNDERSCORE$yearhis.era5.level$UNDERSCORE$ensAvg.1deg.nc $ssp_dir2
end
@ yearhis++


end
