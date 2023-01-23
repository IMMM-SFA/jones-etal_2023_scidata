load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code plots spatial maps for Figure 5
var = "RAIN"

;Path to monthly WRF output, PRISM and ERA5 data
 dirW = "~/data/"
 dirP = "~/data/"
 dirE = "~/data/"

 year = ispan(1981,2019,1)

;Create new variables to read in monthly data for all years
 prW  = new((/dimsizes(year),12,299,424/),"float")
 prE  = new((/dimsizes(year),12,721,1440/),"float")
 prP  = new((/dimsizes(year),12,621,1405/),"float")

do yy = 0,dimsizes(year)-1
 print(year(yy))

;Read WRF output
 fW              = addfile(dirW+"RAIN_TOT_monthly_WRF_CONUS_"+year(yy)+".nc","r")
 prW(yy,:,:,:)   = fW->RAIN

;Read ERA5 data
 fE              = addfile(dirE+"tp/ERA5_tp_daily_"+year(yy)+"_monthly.nc","r")
 prE(yy,:,:,:)   = fE->tp(:,::-1,:)

;Read PRISM data
 fP              = addfile(dirP+"PRISM_ppt_stable_4kmD2_"+year(yy)+"_monthly.nc","r")
 prP(yy,:,:,:)   = fP->ppt

end do

;Calculate climatology
 prWclim          = dim_avg_n_Wrap(prW,0)
 prEclim          = dim_avg_n_Wrap(prE,0)

 ;convert m to mm
 prEclim          = prEclim*1000.0

 prPclim          = dim_avg_n_Wrap(prP,0)

;Read WRF grid information
 f1               = addfile("geo_em.d01.nc","r")
 lat              = f1->XLAT_M(0,:,0)
 lon              = f1->XLONG_M(0,0,:)
 lat@units        = "degrees_N"
 lon@units        = "degrees_E"
 xlat             = f1->XLAT_M(0,:,:)
 xlon             = f1->XLONG_M(0,:,:)
 msk              = f1->LANDMASK(0,:,:)

;Regrid ERA5 climatology to WRF grid
 prEclimFlip      = lonFlip(prEclim)
 prEclimR         = rgrid2rcm_Wrap (prEclimFlip&latitude,prEclimFlip&longitude,prEclimFlip,xlat,xlon,1)

;Regrid PRISM climatology to WRF grid
 prPclimR         = rgrid2rcm_Wrap (prPclim&lat,prPclim&lon,prPclim,xlat,xlon,1)

 prEclimR!1       = "lat"
 prEclimR!2       = "lon"
 prEclimR&lat     = lat
 prEclimR&lon     = lon

 prPclimR!1       = "lat"
 prPclimR!2       = "lon"
 prPclimR&lat     = lat
 prPclimR&lon     = lon

;Calculate seasonal averages
 WRF_DJF          = (prWclim(11,:,:)+prWclim(0,:,:)+prWclim(1,:,:))/3
 ERA5_DJF         = (prEclimR(11,:,:)+prEclimR(0,:,:)+prEclimR(1,:,:))/3
 PRISM_DJF        = (prPclimR(11,:,:)+prPclimR(0,:,:)+prPclimR(1,:,:))/3


 WRF_MAM          = dim_avg_n_Wrap(prWclim(2:4,:,:),0)
 ERA5_MAM         = dim_avg_n_Wrap(prEclimR(2:4,:,:),0)
 PRISM_MAM        = dim_avg_n_Wrap(prPclimR(2:4,:,:),0)


 WRF_JJA          = dim_avg_n_Wrap(prWclim(5:7,:,:),0)
 ERA5_JJA         = dim_avg_n_Wrap(prEclimR(5:7,:,:),0)
 PRISM_JJA        = dim_avg_n_Wrap(prPclimR(5:7,:,:),0)

 WRF_SON          = dim_avg_n_Wrap(prWclim(8:10,:,:),0)
 ERA5_SON         = dim_avg_n_Wrap(prEclimR(8:10,:,:),0)
 PRISM_SON        = dim_avg_n_Wrap(prPclimR(8:10,:,:),0)

;Calculate seasonal bias
 PRISM_DJFbias    = WRF_DJF - PRISM_DJF
 ERA5_DJFbias     = WRF_DJF - ERA5_DJF

 PRISM_MAMbias    = WRF_MAM - PRISM_MAM
 ERA5_MAMbias     = WRF_MAM - ERA5_MAM

 PRISM_JJAbias    = WRF_JJA - PRISM_JJA
 ERA5_JJAbias     = WRF_JJA - ERA5_JJA

 PRISM_SONbias    = WRF_SON - PRISM_SON
 ERA5_SONbias     = WRF_SON - ERA5_SON

 PRISM_DJFbias!0  = "lat"
 PRISM_DJFbias!1  = "lon"
 PRISM_DJFbias&lat = lat
 PRISM_DJFbias&lon = lon

 ERA5_DJFbias!0   = "lat"
 ERA5_DJFbias!1   = "lon"
 ERA5_DJFbias&lat = lat
 ERA5_DJFbias&lon = lon

 copy_VarCoords(PRISM_DJFbias,PRISM_MAMbias)
 copy_VarCoords(PRISM_DJFbias,PRISM_JJAbias)
 copy_VarCoords(PRISM_DJFbias,PRISM_SONbias)

 copy_VarCoords(ERA5_DJFbias,ERA5_MAMbias)
 copy_VarCoords(ERA5_DJFbias,ERA5_JJAbias)
 copy_VarCoords(ERA5_DJFbias,ERA5_SONbias)

;Plotting
 pdfname          = "Figure5_pr"

 wks              = gsn_open_wks ("pdf",pdfname)
 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues

 plot             = new ( 8, "graphic" )
 gsn_define_colormap (wks,"BrownBlue12")
 res                        = True               ; plot mods desired
 res = wrf_map_resources(f1,res)
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
 res@mpOutlineBoundarySets  ="Geophysical"
 res@mpGeophysicalLineColor = "Black"
 xlat                       = f1->XLAT_M(0,:,:)
 xlon                       = f1->XLONG_M(0,:,:)
 ilon                       = dimsizes(lon)
 jlat                       = dimsizes(lat)
 res@mpLimitMode            = "Corners"            ; choose range of map
 res@mpLeftCornerLatF       = xlat(0,0)
 res@mpLeftCornerLonF       = xlon(0,0)
 res@mpRightCornerLatF      = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF      = xlon(jlat-1,ilon-1)
 res@cnLevelSpacingF        = 0.2;0
 res@cnMinLevelValF         = -2
 res@cnMaxLevelValF         = 2
 res@lbLabelStride          = 2

;Mask over ocean
 ERA5_DJFbias               = where(msk.eq.1,ERA5_DJFbias,ERA5_DJFbias@_FillValue)
 PRISM_DJFbias              = where(msk.eq.1,PRISM_DJFbias,PRISM_DJFbias@_FillValue)

 ERA5_MAMbias               = where(msk.eq.1,ERA5_MAMbias,ERA5_MAMbias@_FillValue)
 PRISM_MAMbias              = where(msk.eq.1,PRISM_MAMbias,PRISM_MAMbias@_FillValue)

 ERA5_JJAbias               = where(msk.eq.1,ERA5_JJAbias,ERA5_JJAbias@_FillValue)
 PRISM_JJAbias              = where(msk.eq.1,PRISM_JJAbias,PRISM_JJAbias@_FillValue)

 ERA5_SONbias               = where(msk.eq.1,ERA5_SONbias,ERA5_SONbias@_FillValue)
 PRISM_SONbias              = where(msk.eq.1,PRISM_SONbias,PRISM_SONbias@_FillValue)

 res@tiMainString           = "WRF minus ERA5, Winter (DJF) (1981-2019)"
 plot(0)                    = gsn_csm_contour_map(wks,ERA5_DJFbias(:,:),res)

 res@tiMainString           = "WRF minus PRISM, Winter (DJF) (1981-2019)"
 plot(1)                    = gsn_csm_contour_map(wks,PRISM_DJFbias(:,:),res)

 res@tiMainString           = "WRF minus ERA5, Spring (MAM)"
 plot(2)                    = gsn_csm_contour_map(wks,ERA5_MAMbias(:,:),res)

 res@tiMainString           = "WRF minus PRISM, Spring (MAM)"
 plot(3)                    = gsn_csm_contour_map(wks,PRISM_MAMbias(:,:),res)

 res@tiMainString           = "WRF minus ERA5, Summer (JJA)"
 plot(4)                    = gsn_csm_contour_map(wks,ERA5_JJAbias(:,:),res)

 res@tiMainString           = "WRF minus PRISM, Summer (JJA)"
 plot(5)                    = gsn_csm_contour_map(wks,PRISM_JJAbias(:,:),res)

 res@tiMainString           = "WRF minus ERA5, Fall (SON)"
 plot(6)                    = gsn_csm_contour_map(wks,ERA5_SONbias(:,:),res)

 res@tiMainString           = "WRF minus PRISM, Fall (SON)"
 plot(7)                    = gsn_csm_contour_map(wks,PRISM_SONbias(:,:),res)

 pres                       = True
 pres@gsnPanelMainString    = "Daily Precipitation"
 gsn_panel(wks,(/plot/),(/4,2/),pres)

end
