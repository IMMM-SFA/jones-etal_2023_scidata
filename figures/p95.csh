#!/bin/csh -f

set year = 1980
while ( $year <2020)
echo $year
cdo selvar,RAIN  ../Historical_TGW/RAIN_TOT_daily_WRF_CONUS_$year.nc  temp.nc
cp temp.nc rain.nc
cdo yearmin rain.nc  min.nc
cdo yearmax rain.nc max.nc
cdo yearpctl,95 rain.nc min.nc max.nc ./data/p95_WRF_CONUS_$year.nc
rm rain.nc min.nc max.nc temp.nc
@ year = $year + 1
end

