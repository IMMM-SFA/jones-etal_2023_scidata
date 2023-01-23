load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code plots spatial map for figure 6
;Path to data
 dir   = "./test/"

 year  = ispan(1981,2019,1)

;Create variables to store data
 prW   = new((/dimsizes(year),299,424/),"float")
 prE   = new((/dimsizes(year),721,1440/),"float")
 prP   = new((/dimsizes(year),621,1405/),"float")

;Read yearly data
do yy  = 0,dimsizes(year)-1
 print(year(yy))
 fW          = addfile(dirW+"p95_WRF_CONUS_"+year(yy)+".nc","r")
 prW(yy,:,:) = fW->RAIN

 fE          = addfile(dirE+"p95_ERA5_"+year(yy)+".nc","r")
 prE(yy,:,:) = fE->tp(:,::-1,:)

 fP          = addfile(dirW+"p95_PRISM_"+year(yy)+".nc","r")
 prP(yy,:,:) = fP->ppt

end do

;Calculate climatology
 prWclim     = dim_avg_n_Wrap(prW,0)
 prEclim     = dim_avg_n_Wrap(prE,0)
 prPclim     = dim_avg_n_Wrap(prP,0)

;Read WRF grid information
 f1          = addfile("../geo_em.d01.nc","r")
 lat         = f1->XLAT_M(0,:,0)
 lon         = f1->XLONG_M(0,0,:)
 lat@units   = "degrees_N"
 lon@units   = "degrees_E"
 xlat        = f1->XLAT_M(0,:,:)
 xlon        = f1->XLONG_M(0,:,:)
 msk         = f1->LANDMASK(0,:,:)



;Regrid ERA5 climatology to WRF grid
 prEclimFlip  = lonFlip(prEclim)
 prEclimR     = rgrid2rcm_Wrap (prEclimFlip&latitude,prEclimFlip&longitude,prEclimFlip,xlat,xlon,1)

;Regrid PRISM climatology to WRF grid
 prPclimR     = rgrid2rcm_Wrap (prPclim&lat,prPclim&lon,prPclim,xlat,xlon,1)

 prEclimR!0   = "lat"
 prEclimR!1   = "lon"
 prEclimR&lat = lat
 prEclimR&lon = lon

 prPclimR!0   = "lat"
 prPclimR!1   = "lon"
 prPclimR&lat = lat
 prPclimR&lon = lon
 system("rm PRISM_onWRFgrid.nc")
 fout = addfile("PRISM_onWRFgrid.nc","c")
 fout->prism = prPclimR

;Mask ocean
 prPclimR     = where(msk.eq.1,prPclimR,prPclimR@_FillValue)
 prEclimR     = where(msk.eq.1,prEclimR,prEclimR@_FillValue)
 prWclim      = where(msk.eq.1,prWclim,prWclim@_FillValue)

;Calculate bias
 PRISM_bias   = prWclim - prPclimR
 ERA5_bias    = prWclim - prEclimR


 ERA5_bias!0   = "lat"
 ERA5_bias!1   = "lon"
 ERA5_bias&lat = lat
 ERA5_bias&lon = lon

 copy_VarCoords(ERA5_bias,PRISM_bias)
 pdfname = "Figure6_p95bias"
 wks     = gsn_open_wks ("pdf",pdfname)

 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues

 plot    = new ( 3, "graphic" )
 gsn_define_colormap (wks,"BrownBlue12")
 res                        = True               ; plot mods desired
 res                        = wrf_map_resources(f1,res)
 res@gsnDraw                = False
 res@gsnFrame               = False
 res@cnRasterModeOn         = True
 res@cnFillOn               = True
 res@cnLinesOn              = False
 res@cnLineLabelsOn         = False
 res@gsnSpreadColors        = True               ; use total colormap
 res@cnInfoLabelOn          = False
 res@pmTickMarkDisplayMode  = "Always"
 res@tiMainFontHeightF      = 0.020
 res@gsnAddCyclic           = False
 res@tiMainOffsetYF         = 0.
 res@mpGridAndLimbOn        = True
 res@mpGridLatSpacingF      = 10
 res@mpGridLonSpacingF      =  5
 res@cnLevelSelectionMode   = "ExplicitLevels"
 res@cnLevelSelectionMode   = "AutomaticLevels"
 res@cnLevelSelectionMode   = "ManualLevels"
 res@mpPerimOn              = True
 res@tfDoNDCOverlay         = True ; do not transform data
 res@mpLandFillColor        = "white"
 res@mpOutlineBoundarySets  = "Geophysical"
 res@mpGeophysicalLineColor = "Black"
 xlat =f1->XLAT_M(0,:,:)
 xlon =f1->XLONG_M(0,:,:)
 ilon = dimsizes(lon)
 jlat = dimsizes(lat)
 res@mpLimitMode            = "Corners"            ; choose range of map
 res@mpLeftCornerLatF       = xlat(0,0)
 res@mpLeftCornerLonF       = xlon(0,0)
 res@mpRightCornerLatF      = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF      = xlon(jlat-1,ilon-1)
 res@cnLevelSpacingF        = 0.5;0
 res@cnMinLevelValF         = -8
 res@cnMaxLevelValF         = 8
 res@lbLabelStride          = 2

 res@tiMainString           = "WRF minus ERA5"
 plot(0)                    = gsn_csm_contour_map(wks,ERA5_bias(:,:),res)
 
 res@tiMainString           = "WRF minus PRISM"
 plot(1)                    = gsn_csm_contour_map(wks,PRISM_bias(:,:),res)

 pres                       = True
 pres@gsnPanelMainString    = "95th percentile of daily precipitation (1981-2019)"
 gsn_panel(wks,(/plot/),(/1,3/),pres)


end
