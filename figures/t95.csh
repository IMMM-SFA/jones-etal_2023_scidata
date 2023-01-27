#!/bin/csh -f

set year = 1980
while ( $year <2020)
echo $year
cdo selvar,tmax  ../Historical_TGW/tmax_daily_WRF_CONUS_$year.nc tmax.nc
cdo yearmin tmax.nc  min.nc
cdo yearmax tmax.nc max.nc
cdo yearpctl,95 tmax.nc min.nc max.nc ./netcdf/tmax95_WRF_CONUS_$year.nc
rm tmax.nc min.nc max.nc temp.nc
@ year = $year + 1
end

