#!/bin/csh
module load cdo
# This script performs data preprocessing for delta calculations 
# 1) Reads the raw combined CMIP6 output and writes separate yearly files
# 2) Regrids data to a common 1 degree grid
# 3) Interpolates levels to ERA5 levels for 3d data

set var  = (hur hurs ta tas tos ts)
set UNDERSCORE = _
# The following lines needs to be changed according to the CMIP6 GCM,time period, scenario and number of ensemble members
set EXTENSION1 = 195001-201412.nc
set EXTENSION2 = 197001-201412.nc
set ens    = (r1i1p1f1 r2i1p1f1 r3i1p1f1 r4i1p1f1 r5i1p1f1)
set gn     = _gn
set input_dir = ../WRF-TGW-Delta/CMIP6/ACCESS-ESM1-5
set FNAME1 = _Amon_ACCESS-ESM1-5_historical_
set FNAME2 = _Omon_ACCESS-ESM1-5_historical_
set output_dir = ../WRF-TGW-Delta/delta_calc/data/historical
foreach e ($ens)
echo $FNAME1

foreach i ($var)
echo $i
if ($i == "tos")then

# Extract 1970 to 2014 period
cdo seldate,1970-01-01,2014-12-31 ${input_dir}/$i$FNAME2$e$gn$UNDERSCORE$EXTENSION1 ${output_dir}/$i$FNAME2$e$gn$UNDERSCORE$EXTENSION2

# Spilt data into separate files
cdo splityear ${output_dir}/$i$FNAME2$e$gn$UNDERSCORE$EXTENSION2 ${output_dir}/$i$FNAME2$e$gn$UNDERSCORE

echo ${output_dir}/$i$FNAME2$e$gn$UNDERSCORE$EXTENSION2
echo ${output_dir}/$i$FNAME2$e$gn$UNDERSCORE

else
echo ${input_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION1 
echo ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION2

# Extract 1970 to 2014 period
cdo seldate,1970-01-01,2014-12-31 ${input_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION1 ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION2
echo ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION2
echo ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE

# Spilt data into separate files
cdo splityear ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE$EXTENSION2 ${output_dir}/$i$FNAME1$e$gn$UNDERSCORE
endif

end

set year  = 1970
set var3d = (hur ta)
set var2d = (hurs tas tos ts)

while($year < 2015)
echo $year

foreach i2d ($var2d)
if ($i2d == "tos")then
echo ${output_dir}/$i2d$FNAME2$e$gn$UNDERSCORE$year.nc
# Regrid to common 1 degree grid
cdo remapbil,r360x180 ${output_dir}/$i2d$FNAME2$e$gn$UNDERSCORE$year.nc ${output_dir}/$i2d$FNAME2$e$gn$UNDERSCORE$year.1deg.nc

else
echo ${output_dir}/$i2d$FNAME1$e$gn$UNDERSCORE$year.nc
# Regrid to common 1 degree grid
cdo remapbil,r360x180 ${output_dir}/$i2d$FNAME1$e$gn$UNDERSCORE$year.nc ${output_dir}/$i2d$FNAME1$e$gn$UNDERSCORE$year.1deg.nc
endif
end

foreach i3d ($var3d)

echo ${output_dir}/$i3d$FNAME1$e$gn$UNDERSCORE$year.nc

# Regrid to common 1 degree grid
cdo remapbil,r360x180 ${output_dir}/$i3d$FNAME1$e$gn$UNDERSCORE$year.nc ${output_dir}/$i3d$FNAME1$e$gn$UNDERSCORE$year.1deg.nc

# Interpolate to ERA5 level
cdo intlevel,100000,97500,95000,92500,90000,87500,85000,82500,80000,77500,75000,70000,65000,60000,55000,50000,45000,40000,35000,30000,25000,22500,20000,17500,15000,12500,10000,7000,5000,3000,2000,1000,700,500,300,200,100 ${output_dir}/$i3d$FNAME1$e$gn$UNDERSCORE$year.1deg.nc ${output_dir}/$i3d$FNAME1$e$gn$UNDERSCORE$year.era5.level.1deg.nc
end 
@ year++

end
end
