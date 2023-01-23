load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code reads ERA5 and WRF data and plots tas panels for Figure 1
;Selecting a year in historical
;Selecting corresponding years in future1 and future2
 year              = 2010
 yearf1            = year+40
 yearf2            = year+80

;Selecting July 1, 2010 as an example
 timstp            = 182 ;July 1, 2010

;Path to ERA5 data
 dirE              = "~/data/"

;Read ERA5 data files and read the data for the selected day
 ftmax             = addfile(dirE+"/tmax/ERA5_tmax_daily_"+year+".nc","r")
 ftmin             = addfile(dirE+"/tmin/ERA5_tmin_daily_"+year+".nc","r")
 tmax              = ftmax->tmax(timstp,::-1,:)
 tmin              = ftmin->tmin(timstp,::-1,:)
 tas               = (tmax+tmin)/2
 tas               = tas-273.15

;Read latitude longitude from ERA5
 latE              = ftmax->latitude(::-1)
 lonE              = ftmax->longitude
 latE@units        = "degrees_N"
 lonE@units        = "degrees_E"
 tas!0             = "latitude"
 tas!1             = "longitude"
 tas&latitude      = latE
 tas&longitude     = lonE

;Path to historical and future WRF data
 dirHI             = "~/data/Historical_TGW/"
 dir_HOT585_F1     = "~/data/SSP585_HOT_NEARFUTURE_TGW/"
 dir_HOT585_F2     = "~/data/SSP585_HOT_FARFUTURE_TGW/"

;Read WRF output
 hi_tmax_HOT585    = addfile(dirHI+"tmax_daily_WRF_CONUS_"+year+".nc","r")
 hi_tmin_HOT585    = addfile(dirHI+"tmin_daily_WRF_CONUS_"+year+".nc","r")
 ff1_tmax_HOT585   = addfile(dir_HOT585_F1+"tmax_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff1_tmin_HOT585   = addfile(dir_HOT585_F1+"tmin_daily_WRF_CONUS_"+yearf1+".nc","r")
 ff2_tmax_HOT585   = addfile(dir_HOT585_F2+"tmax_daily_WRF_CONUS_"+yearf2+".nc","r")
 ff2_tmin_HOT585   = addfile(dir_HOT585_F2+"tmin_daily_WRF_CONUS_"+yearf2+".nc","r")

 vhtmax            = hi_tmax_HOT585->tmax(timstp,:,:)
 vhtmin            = hi_tmin_HOT585->tmin(timstp,:,:)

 v1tmax_HOT585     = ff1_tmax_HOT585->tmax(timstp,:,:)
 v1tmin_HOT585     = ff1_tmin_HOT585->tmin(timstp,:,:)

 v2tmax_HOT585     = ff2_tmax_HOT585->tmax(timstp,:,:)
 v2tmin_HOT585     = ff2_tmin_HOT585->tmin(timstp,:,:)

 vhtas             = (vhtmax+vhtmin)/2
 v1tas_HOT585      = (v1tmax_HOT585+v1tmin_HOT585)/2
 v2tas_HOT585      = (v2tmax_HOT585+v2tmin_HOT585)/2

 copy_VarCoords(vhtmax,vhtas)
 copy_VarCoords(v1tmax_HOT585,v1tas_HOT585)
 copy_VarCoords(v1tmax_HOT585,v2tas_HOT585)

 pdfname                    = "Figure1-tas"
 wks                        = gsn_open_wks ("pdf",pdfname)
 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues

 plot                       = new ( 36, "graphic" )
 gsn_define_colormap (wks, "BlAqGrYeOrRevi200"); Temperature
 res                        = True               ; plot mods desired
 f1                         = addfile("../geo_em.d01.nc","r")
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
 lat                        = f1->XLAT_M(0,:,0)
 lon                        = f1->XLONG_M(0,0,:)
 lat@units                  = "degrees_N"
 lon@units                  = "degrees_E"
 xlat                       = f1->XLAT_M(0,:,:)
 xlon                       = f1->XLONG_M(0,:,:)
 msk                        = f1->LANDMASK(0,:,:)
 ilon                       = dimsizes(lon)
 jlat                       = dimsizes(lat)
 res@mpLimitMode            = "Corners"            ; choose range of map
 res@mpLeftCornerLatF       = xlat(0,0)
 res@mpLeftCornerLonF       = xlon(0,0)
 res@mpRightCornerLatF      = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF      = xlon(jlat-1,ilon-1)
 res@cnLevelSpacingF        = 2.0;0
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 40
 res@lbLabelStride          = 2

;Mask Ocean
 vhtas                      = where(msk.eq.1,vhtas,vhtas@_FillValue)
 v1tas_HOT585               = where(msk.eq.1,v1tas_HOT585,v1tas_HOT585@_FillValue)
 v2tas_HOT585               = where(msk.eq.1,v2tas_HOT585,v2tas_HOT585@_FillValue)

 tasFlip                    = lonFlip(tas)
 tasFlipwgrid               = rgrid2rcm_Wrap(tasFlip&latitude,tasFlip&longitude,tasFlip,xlat,xlon,1)
 tasFlipwgrid               = where(ismissing(vhtas),tasFlipwgrid@_FillValue,tasFlipwgrid) 

 res@tiMainString           = "ERA5 July 1, 2010";+months(mm)
 plot(0)                    = gsn_csm_contour_map(wks,tasFlipwgrid(:,:),res)
 res@tiMainString           = "WRF 12km, July 1, 2010";
 plot(1)                    = gsn_csm_contour_map(wks,vhtas(:,:),res)

 res@tiMainString           = "ERA5 July 1, 2010";+months(mm)
 plot(2)                    = gsn_csm_contour_map(wks,tasFlipwgrid(:,:),res)
 res@tiMainString           = "WRF 12km, July 1, 2050, High Sensitivity SSP585";
 plot(3)                    = gsn_csm_contour_map(wks,v1tas_HOT585(:,:),res)

 res@tiMainString           = "ERA5 July 1, 2010";+months(mm)
 plot(4)                    = gsn_csm_contour_map(wks,tasFlipwgrid(:,:),res)
 res@tiMainString           = "WRF 12km, July 1, 2090";
 plot(5)                    = gsn_csm_contour_map(wks,v2tas_HOT585(:,:),res)
 pres                       = True
 pres@gsnPanelMainString    = "Tas Figure1"
 gsn_panel(wks,(/plot/),(/3,2/),pres)


end
