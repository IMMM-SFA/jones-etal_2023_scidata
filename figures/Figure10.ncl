load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code creates plots for Figure 10
 var            = "tmax"

;Path to monthly WRF output, PRISM and ERA5 data
 dir            = "~/data/"
 dirHI          = dir+"/Historical_TGW/"

 dir_HOT585_F1  = dir+"/SSP585_HOT_NEARFUTURE_TGW/"
 dir_HOT585_F2  = dir+"/SSP585_HOT_FARFUTURE_TGW/"

 dir_COLD585_F1 = dir+"/SSP585_COLD_NEARFUTURE_TGW/"
 dir_COLD585_F2 = dir+"/SSP585_COLD_FARFUTURE_TGW/"

 dir_COLD245_F1 = dir+"/SSP245_COLD_NEARFUTURE_TGW/"
 dir_COLD245_F2 = dir+"/SSP245_COLD_FARFUTURE_TGW/"

 dir_HOT245_F1  = dir+"/SSP245_HOT_NEARFUTURE_TGW/"
 dir_HOT245_F2  = dir+"/SSP245_HOT_FARFUTURE_TGW/"

 year           = ispan(2012,2012,1)
 prW            = new((/dimsizes(year),299,424/),"float")
 prE            = new((/dimsizes(year),721,1440/),"float")
 prP            = new((/dimsizes(year),621,1405/),"float")

;Read data
do yy = 0,dimsizes(year)-1
 print(year(yy))
 yearf1 =year(yy)+40
 yearf2 =year(yy)+80

 fW            = addfile("./netcdf/hw_min3days_abovet95_JJA_"+year(yy)+"-WRF_Historical.nc","r")
 hw            = fW->hw_present

 fhi           = addfile(dirHI+var+"_daily_WRF_CONUS_"+year(yy)+".nc","r")

 ff1_HOT585    = addfile(dir_HOT585_F1+var+"_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_HOT585    = addfile(dir_HOT585_F2+var+"_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_COLD585   = addfile(dir_COLD585_F1+var+"_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_COLD585   = addfile(dir_COLD585_F2+var+"_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_COLD245   = addfile(dir_COLD245_F1+var+"_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_COLD245   = addfile(dir_COLD245_F2+var+"_daily_WRF_CONUS_"+yearf2+".nc","r")

 ff1_HOT245    = addfile(dir_HOT245_F1+var+"_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_HOT245    = addfile(dir_HOT245_F2+var+"_daily_WRF_CONUS_"+yearf2+".nc","r")


 tmaxhi         = fhi->$var$(152:243,:,:)

 tmaxf1_HOT585  = ff1_HOT585->$var$(152:243,:,:)
 tmaxf2_HOT585  = ff2_HOT585->$var$(152:243,:,:)

 tmaxf1_COLD585 = ff1_COLD585->$var$(152:243,:,:)
 tmaxf2_COLD585 = ff2_COLD585->$var$(152:243,:,:)

 tmaxf1_COLD245 = ff1_COLD245->$var$(152:243,:,:)
 tmaxf2_COLD245 = ff2_COLD245->$var$(152:243,:,:)

 tmaxf1_HOT245  = ff1_HOT245->$var$(152:243,:,:)
 tmaxf2_HOT245  = ff2_HOT245->$var$(152:243,:,:)


end do

;Read WRF grid information
 f1        = addfile("../geo_em.d01.nc","r")
 lat       = f1->XLAT_M(0,:,0)
 lon       = f1->XLONG_M(0,0,:)
 lat@units = "degrees_N"
 lon@units = "degrees_E"
 xlat      = f1->XLAT_M(0,:,:)
 xlon      = f1->XLONG_M(0,:,:)
 msk       = f1->LANDMASK(0,:,:)

;
;Mask the ocean
 mskC           = conform(tmaxhi,msk,(/1,2/))
 hw             = where(mskC.eq.1,hw,hw@_FillValue)
 tmaxhi         = where(mskC.eq.1,tmaxhi,tmaxhi@_FillValue)
 tmaxf1_HOT585  = where(mskC.eq.1,tmaxf1_HOT585,tmaxf1_HOT585@_FillValue)
 tmaxf2_HOT585  = where(mskC.eq.1,tmaxf2_HOT585,tmaxf2_HOT585@_FillValue)

 tmaxf1_COLD585 = where(mskC.eq.1,tmaxf1_COLD585,tmaxf1_COLD585@_FillValue)
 tmaxf2_COLD585 = where(mskC.eq.1,tmaxf2_COLD585,tmaxf2_COLD585@_FillValue)

 tmaxf1_COLD245 = where(mskC.eq.1,tmaxf1_COLD245,tmaxf1_COLD245@_FillValue)
 tmaxf2_COLD245 = where(mskC.eq.1,tmaxf2_COLD245,tmaxf2_COLD245@_FillValue)

 tmaxf1_HOT245  = where(mskC.eq.1,tmaxf1_HOT245,tmaxf1_HOT245@_FillValue)
 tmaxf2_HOT245  = where(mskC.eq.1,tmaxf2_HOT245,tmaxf2_HOT245@_FillValue)

;Plotting
 pdfname        = "Figure10"
 wks            = gsn_open_wks ("pdf",pdfname)
 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues
 plot           = new ( 36, "graphic" )
 gsn_define_colormap (wks, "BlAqGrYeOrRevi200"); Temperature
 res                       = True               ; plot mods desired
 res                       = wrf_map_resources(f1,res)
 res@gsnDraw               = False
 res@gsnFrame              = False
 res@cnRasterModeOn        = True
 res@cnFillOn              = True
 res@cnLinesOn             = False
 res@cnLineLabelsOn        = False
 res@cnConstFEnableFill    = True
 res@gsnSpreadColors       = True               ; use total colormap
 res@cnInfoLabelOn         =False
 res@pmTickMarkDisplayMode ="Always"
 res@tiMainFontHeightF     =0.020
 res@gsnAddCyclic          = False
 res@tiMainOffsetYF        =0.
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
 res@mpUSStateLineColor     = "Black"
 res@mpNationalLineColor    = "Black"
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
 res@cnLevelSpacingF        = 1.0;0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 1
 res@lbLabelStride          = 1

 tt = 29

 res@tiMainString           = "Grid celss with an ongoing heatwave"
 res@cnLevelSpacingF        = 1.0;0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 1
 res@lbLabelStride          = 1
 hw                         = where(hw.eq.0,hw@_FillValue,hw)

 plot(0)                    = gsn_csm_contour_map(wks,hw(tt,:,:),res)
 res@cnLevelSpacingF        = 2.0;0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 44
 res@lbLabelStride          = 1

 res@tiMainString           = "Near Future, Low Sensitivity, SSP245"
 plot(1)                    = gsn_csm_contour_map(wks,tmaxf1_COLD245(tt,:,:),res)

 res@tiMainString           = "Far Future, Low Sensitivity, SSP245"
 plot(2)                    = gsn_csm_contour_map(wks,tmaxf2_COLD245(tt,:,:),res)

 res@tiMainString           = "Historical"
 plot(3)                    = gsn_csm_contour_map(wks,tmaxhi(tt,:,:),res)

 res@tiMainString           = "Near Future, Low Sensitivity, SSP585"
 plot(4)                    = gsn_csm_contour_map(wks,tmaxf1_COLD585(tt,:,:),res)

 res@tiMainString           = "Far Future, Low Sensitivity, SSP585"
 plot(5)                    = gsn_csm_contour_map(wks,tmaxf2_COLD585(tt,:,:),res)

 res@tiMainString           = "Near Future, High Sensitivity, SSP585"
 plot(7)                    = gsn_csm_contour_map(wks,tmaxf1_HOT585(tt,:,:),res)

 res@tiMainString           = "Far Future, High Sensitivity, SSP585"
 plot(8)                    = gsn_csm_contour_map(wks,tmaxf2_HOT585(tt,:,:),res)

 res@tiMainString           = "Near Future, High Sensitivity, SSP245"
 plot(10)                   = gsn_csm_contour_map(wks,tmaxf1_HOT245(tt,:,:),res)

 res@tiMainString           = "Far Future, High Sensitivity, SSP245"
 plot(11)                   = gsn_csm_contour_map(wks,tmaxf2_HOT245(tt,:,:),res)

 pres                       = True
 pres@gsnPanelMainString    = " "
 gsn_panel(wks,(/plot/),(/4,3/),pres)

end
