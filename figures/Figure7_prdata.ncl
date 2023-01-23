load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code reads WRF output and creates precipitation data for Figure 7
;Path to daily WRF output, PRISM and ERA5 data
 dirW       = "~/data/"
 dirP       = "~/data/"
 dirE       = "~/data/"

;latitude longitude for cities
 latitudes  = (/29.76,38.63,47.61,36.17,40.71,25.76/)
 longitudes = (/-95.37,-90.20,-122.33,-115.14,-74.01,-80.19/)
 cities     = (/"Houston","StLouis","Seattle","LasVegas","NewYork","Miami"/)
 ii         = (/56,139,242,128,176,33/)
 jj         = (/226,261,55,79,371,354/)


;Loop over the cities
do ci       = 0, dimsizes(cities)-1
 latc       = latitudes(ci)
 lonc       = longitudes(ci)
 city       = cities(ci)
 year       = ispan(1981,2019,1)
 prW        = new((/dimsizes(year),365/),"float")
 prE        = new((/dimsizes(year),365/),"float")
 prP        = new((/dimsizes(year),365/),"float")

;Read yearly data for each city
do yy      = 0,dimsizes(year)-1
 print(year(yy))
 fW         = addfile(dirW+"RAIN_TOT_daily_WRF_CONUS_"+year(yy)+".nc","r")
 prW(yy,:)  = fW->RAIN(0:364,ii(ci),jj(ci))

 fE         = addfile(dirE+"tp/ERA5_tp_daily_"+year(yy)+".nc","r")
 prE_temp   = fE->tp(0:364,::-1,:)
 prE_temp1  = lonFlip(prE_temp)
 prE(yy,:)  = prE_temp1(:,{latc},{lonc})

 fP         = addfile(dirP+"PRISM_ppt_stable_4kmD2_"+year(yy)+".nc","r")
 prP(yy,:)  = fP->ppt(0:364,{latc},{lonc})

end do

 prW!0      = "year"
 prW!1      = "days"

 prE!0      = "year"
 prE!1      = "days"

 prP!0      = "year"
 prP!1      = "days"

;Write output in netcdf files
 fout       = precipitation_over_"+cities(ci)+".nc"
 system("rm "+fout)
 fout       = addfile(fout,"c")
 fout->prW  = prW
 fout->prE  = prE
 fout->prP  = prP

end
