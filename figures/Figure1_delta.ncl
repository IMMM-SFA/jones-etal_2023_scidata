load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;Selecting a year in historical
;Selecting corresponding years in future1 and future2
 year   = 2010
 yearf1 = year+40
 yearf2 = year+80

;Read Deltas for July
 fdelta  = "~/delta/"
 f1delta = addfile(fdelta+"tas_Amon_HotModelMean_ssp585_"+yearf1+".minus."+year+"_ensAvg.MovingAvg.delta.1deg.nc","r")
 f2delta = addfile(fdelta+"tas_Amon_HotModelMean_ssp585_"+yearf2+".minus."+year+"_ensAvg.MovingAvg.delta.1deg.nc","r")
 v1delta = f1delta->tas(6,:,:)
 v2delta = f2delta->tas(6,:,:)

;Plot deltas
 pdfname = "Figure1-delta"
 wks     = gsn_open_wks ("pdf",pdfname)

 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues

 plot                       = new ( 36, "graphic" )

 gsn_define_colormap (wks, "MPL_Oranges")

 res                        = True               ; plot mods desired

;Read WRF grid file
 f1                         = addfile("../geo_em.d01.nc","r")
 res                        = wrf_map_resources(f1,res)
 lat                        = f1->XLAT_M(0,:,0)
 lon                        = f1->XLONG_M(0,0,:)
 lat@units                  = "degrees_N"
 lon@units                  = "degrees_E"
 xlat                       = f1->XLAT_M(0,:,:)
 xlon                       = f1->XLONG_M(0,:,:)
 msk                        = f1->LANDMASK(0,:,:)

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

 ilon = dimsizes(lon)
 jlat = dimsizes(lat)
 res@mpLimitMode            = "Corners"            ; choose range of map
 res@mpLeftCornerLatF       = xlat(0,0)
 res@mpLeftCornerLonF       = xlon(0,0)
 res@mpRightCornerLatF      = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF      = xlon(jlat-1,ilon-1)
 res@cnLevelSpacingF        = 0.2
 res@cnMinLevelValF         = 0
 res@cnMaxLevelValF         = 10
 res@lbLabelStride          = 4

;Interpolate delta to WRF grid for plotting

 v1deltaFlip                = lonFlip(v1delta)
 v2deltaFlip                = lonFlip(v2delta)
 v1deltaFlipwgrid           = rgrid2rcm_Wrap(v1deltaFlip&lat,v1deltaFlip&lon,v1deltaFlip,xlat,xlon,1)
 v2deltaFlipwgrid           = rgrid2rcm_Wrap(v2deltaFlip&lat,v2deltaFlip&lon,v2deltaFlip,xlat,xlon,1)
 v1deltaFlipwgrid           = where(msk.eq.1,v1deltaFlipwgrid,v1deltaFlipwgrid@_FillValue)
 v2deltaFlipwgrid           = where(msk.eq.1,v2deltaFlipwgrid,v2deltaFlipwgrid@_FillValue)
 res@tiMainString           = "July (2050 minus 2010)"
 plot(0)                    = gsn_csm_contour_map(wks,v1deltaFlipwgrid(:,:),res)
 res@tiMainString           = "July (2090 minus 2010)"
 plot(1)                    = gsn_csm_contour_map(wks,v2deltaFlipwgrid(:,:),res)

 pres                       = True
 pres@gsnPanelMainString    = "Thermodynamic Change Signal Derived from GCMs"
 gsn_panel(wks,(/plot/),(/2,1/),pres)


end
