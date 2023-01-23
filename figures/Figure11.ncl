load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code creates plots for Figure 11
 year1            = ispan(1980,2019,1)
 p95_yy           = new((/dimsizes(year1),299,424/),"float")
 var              = "RAIN"
do yy             = 0, dimsizes(year1)-1

 f1               = addfile("/global/cfs/cdirs/m2702/im3-climtask/TGW-Paper/Figure-R2/test/p95_WRF_CONUS_"+year1(yy)+".nc","r")
 p95_yy(yy,:,:)   = f1->RAIN

end do

 p95              = dim_avg_n_Wrap(p95_yy,0)

;Path to monthly WRF output, PRISM and ERA5 data
 dir              = "/global/cfs/cdirs/m2702/im3-climtask/wrf-QAQC/"
 dirHI            = dir+"/Historical_TGW/"

 dir_HOT585_F1    = dir+"/SSP585_HOT_NEARFUTURE_TGW/"
 dir_HOT585_F2    = dir+"/SSP585_HOT_FARFUTURE_TGW/"

 dir_COLD585_F1   = dir+"/SSP585_COLD_NEARFUTURE_TGW/"
 dir_COLD585_F2   = dir+"/SSP585_COLD_FARFUTURE_TGW/"

 dir_COLD245_F1   = dir+"/SSP245_COLD_NEARFUTURE_TGW/"
 dir_COLD245_F2   = dir+"/SSP245_COLD_FARFUTURE_TGW/"

 dir_HOT245_F1    = dir+"/SSP245_HOT_NEARFUTURE_TGW/"
 dir_HOT245_F2    = dir+"/SSP245_HOT_FARFUTURE_TGW/"

 year             = ispan(2015,2015,1)

 prW              = new((/dimsizes(year),299,424/),"float")
 prE              = new((/dimsizes(year),721,1440/),"float")
 prP              = new((/dimsizes(year),621,1405/),"float")

do yy             = 0,dimsizes(year)-1

 print(year(yy))
 yearf1           = year(yy)+40
 yearf2           = year(yy)+80

 fhi              = addfile(dirHI+"RAIN_TOT_daily_WRF_CONUS_"+year(yy)+".nc","r")

 ff1_HOT585       = addfile(dir_HOT585_F1+"RAIN_TOT_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_HOT585       = addfile(dir_HOT585_F2+"RAIN_TOT_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_COLD585      = addfile(dir_COLD585_F1+"RAIN_TOT_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_COLD585      = addfile(dir_COLD585_F2+"RAIN_TOT_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_COLD245      = addfile(dir_COLD245_F1+"RAIN_TOT_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_COLD245      = addfile(dir_COLD245_F2+"RAIN_TOT_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_HOT245       = addfile(dir_HOT245_F1+"RAIN_TOT_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_HOT245       = addfile(dir_HOT245_F2+"RAIN_TOT_daily_WRF_CONUS_"+yearf2+".nc","r")


 preciphi         = fhi->$var$

 precipf1_HOT585  = ff1_HOT585->$var$
 precipf2_HOT585  = ff2_HOT585->$var$

 precipf1_COLD585 = ff1_COLD585->$var$
 precipf2_COLD585 = ff2_COLD585->$var$

 precipf1_COLD245 = ff1_COLD245->$var$
 precipf2_COLD245 = ff2_COLD245->$var$

 precipf1_HOT245  = ff1_HOT245->$var$
 precipf2_HOT245  = ff2_HOT245->$var$


end do

;Read WRF grid information
 f1                         = addfile("../geo_em.d01.nc","r")
 lat                        = f1->XLAT_M(0,:,0)
 lon                        = f1->XLONG_M(0,0,:)
 lat@units                  = "degrees_N"
 lon@units                  = "degrees_E"
 xlat                       = f1->XLAT_M(0,:,:)
 xlon                       = f1->XLONG_M(0,:,:)
 msk                        = f1->LANDMASK(0,:,:)
 mskC                       = conform(preciphi,msk,(/1,2/))

 preciphi                   = where(mskC.eq.1,preciphi,preciphi@_FillValue)

 precipf1_HOT585            = where(mskC.eq.1,precipf1_HOT585,precipf1_HOT585@_FillValue)
 precipf2_HOT585            = where(mskC.eq.1,precipf2_HOT585,precipf2_HOT585@_FillValue)

 precipf1_COLD585           = where(mskC.eq.1,precipf1_COLD585,precipf1_COLD585@_FillValue)
 precipf2_COLD585           = where(mskC.eq.1,precipf2_COLD585,precipf2_COLD585@_FillValue)

 precipf1_COLD245           = where(mskC.eq.1,precipf1_COLD245,precipf1_COLD245@_FillValue)
 precipf2_COLD245           = where(mskC.eq.1,precipf2_COLD245,precipf2_COLD245@_FillValue)

 precipf1_HOT245            = where(mskC.eq.1,precipf1_HOT245,precipf1_HOT245@_FillValue)
 precipf2_HOT245            = where(mskC.eq.1,precipf2_HOT245,precipf2_HOT245@_FillValue)

 p95C                       = conform(preciphi,p95,(/1,2/))
 storm                      = preciphi
 storm                      = where(preciphi.gt.p95C,1,0)
 storm                      = where(storm.eq.0,storm@_FillValue,storm)

 precipf1_HOT585            = where(precipf1_HOT585.eq.0,precipf1_HOT585@_FillValue,precipf1_HOT585)
 precipf2_HOT585            = where(precipf2_HOT585.eq.0,precipf2_HOT585@_FillValue,precipf2_HOT585)
 
 precipf1_COLD585           = where(precipf1_COLD585.eq.0,precipf1_COLD585@_FillValue,precipf1_COLD585)
 precipf2_COLD585           = where(precipf2_COLD585.eq.0,precipf2_COLD585@_FillValue,precipf2_COLD585)

 precipf1_COLD245           = where(precipf1_COLD245.eq.0,precipf1_COLD245@_FillValue,precipf1_COLD245)
 precipf2_COLD245           = where(precipf2_COLD245.eq.0,precipf2_COLD245@_FillValue,precipf2_COLD245)

 precipf1_HOT245            = where(precipf1_HOT245.eq.0,precipf1_HOT245@_FillValue,precipf1_HOT245)
 precipf2_HOT245            = where(precipf2_HOT245.eq.0,precipf2_HOT245@_FillValue,precipf2_HOT245)

 preciphi                   = where(preciphi.eq.0,preciphi@_FillValue,preciphi)


 pdfname                    = "Figure11"
 wks                        = gsn_open_wks ("pdf",pdfname)
 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues
 plot                       = new ( 36, "graphic" )
 gsn_define_colormap (wks, "BlAqGrYeOrRevi200"); Temperature
 res                        = True               ; plot mods desired
 cmap                       = gsn_retrieve_colormap(wks)
 cmap(2:,:)                 = cmap(2::-1,:)
 gsn_define_colormap(wks,cmap)
 res                        = wrf_map_resources(f1,res)
 res@gsnDraw                = False
 res@gsnFrame               = False
 res@cnRasterModeOn         = True
 res@cnFillOn               = True
 res@cnLinesOn              = False
 res@cnLineLabelsOn         = False
 res@cnConstFEnableFill     = True
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
 xlat                       = f1->XLAT_M(0,:,:)
 xlon                       = f1->XLONG_M(0,:,:)
 ilon                       = dimsizes(lon)
 jlat                       = dimsizes(lat)
 res@mpLimitMode            = "Corners"            ; choose range of map
 res@mpLeftCornerLatF       = xlat(0,0)
 res@mpLeftCornerLonF       = xlon(0,0)
 res@mpRightCornerLatF      = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF      = xlon(jlat-1,ilon-1)
 tt                         = 330
 res@tiMainString           = "Grid cells with Precipitation above P95";+months(mm)
 res@cnLevelSpacingF        = 1.0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 1
 res@lbLabelStride          = 1
 plot(0)                    = gsn_csm_contour_map(wks,storm(tt,:,:),res)
 res@cnLevelSpacingF        = 2.0;0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 30
 res@lbLabelStride          = 1

 res@tiMainString           = "Near Future, Low Sensitivity, SSP245"
 plot(1)                    = gsn_csm_contour_map(wks,precipf1_COLD245(tt,:,:),res)

 res@tiMainString           = "Far Future, Low Sensitivity, SSP245"
 plot(2)                    = gsn_csm_contour_map(wks,precipf2_COLD245(tt,:,:),res)

 res@tiMainString           = "Historical"
 plot(3)                    = gsn_csm_contour_map(wks,preciphi(tt,:,:),res)

 res@tiMainString           = "Near Future, Low Sensitivity, SSP585"
 plot(4)                    = gsn_csm_contour_map(wks,precipf1_COLD585(tt,:,:),res)

 res@tiMainString           = "Far Future, Low Sensitivity, SSP585"
 plot(5)                    = gsn_csm_contour_map(wks,precipf2_COLD585(tt,:,:),res)

 res@tiMainString           = "Near Future, High Sensitivity, SSP585"
 plot(7)                    = gsn_csm_contour_map(wks,precipf1_HOT585(tt,:,:),res)

 res@tiMainString           = "Far Future, High Sensivitiy, SSP585"
 plot(8)                    = gsn_csm_contour_map(wks,precipf2_HOT585(tt,:,:),res)

 res@tiMainString           = "Near Future, High Sensitivity, SSP245"
 plot(10)                   = gsn_csm_contour_map(wks,precipf1_HOT245(tt,:,:),res)

 res@tiMainString           = "Far Future, High Sensitivity, SSP245"
 plot(11)                   = gsn_csm_contour_map(wks,precipf2_HOT245(tt,:,:),res)

 pres = True
 pres@gsnPanelMainString = "November 27"
 gsn_panel(wks,(/plot/),(/4,3/),pres)


end
