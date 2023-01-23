load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code plots spatial map for Figure 4
;Read WRF grid file
 f1        = addfile("../geo_em.d01.nc","r")

;Read elevation
 var       = f1->HGT_M(0,:,:)
 lat       = f1->XLAT_M(0,:,0)
 lon       = f1->XLONG_M(0,0,:)
 msk       = f1->LANDMASK(0,:,:)
 var       = where(msk.eq.1,var,var@_FillValue)
 lat@units = "degrees_N"
 lon@units = "degrees_E"
 var!0     = "lat"
 var!1     = "lon"
 var&lat   = lat
 var&lon   = lon

;Plot figure
 pdfname                     = "Figure4"
 wks                         = gsn_open_wks ("pdf",pdfname)
 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues
 plot                        = new ( 1, "graphic" )

 gsn_define_colormap (wks, "WhiteBlueGreenYellowRed")
 res                         = True               ; plot mods desired
 res = wrf_map_resources(f1,res)
 res@gsnDraw                 = False
 res@gsnFrame                = False
 res@cnFillOn                = True
 res@cnLinesOn               = False
 res@cnLineLabelsOn          = False
 res@gsnSpreadColors         = True               ; use total colormap
 res@cnInfoLabelOn           = False
 res@pmTickMarkDisplayMode   = "Always"
 res@tiMainFontHeightF       = 0.020
 res@gsnAddCyclic            = False
 res@tiMainOffsetYF          = 0.
 res@mpGridAndLimbOn         = True
 res@mpGridLatSpacingF       = 10
 res@mpGridLonSpacingF       =  5
 res@cnLevelSelectionMode    = "ExplicitLevels"
 res@cnLevelSelectionMode    = "AutomaticLevels"
 res@cnLevelSelectionMode    = "ManualLevels"
 res@mpPerimOn               = True
 res@tfDoNDCOverlay          = True ; do not transform data
 res@mpLandFillColor         = "white"
 res@mpOutlineBoundarySets   = "Geophysical"
 res@mpOutlineBoundarySets   = "National"
 res@mpGeophysicalLineColor  = "Black"
 xlat                        = f1->XLAT_M(0,:,:)
 xlon                        = f1->XLONG_M(0,:,:)
 ilon                        = dimsizes(lon)
 jlat                        = dimsizes(lat)
 res@mpLimitMode             = "Corners"            ; choose range of map
 res@mpLeftCornerLatF        = xlat(0,0)
 res@mpLeftCornerLonF        = xlon(0,0)
 res@mpRightCornerLatF       = xlat(jlat-1,ilon-1)
 res@mpRightCornerLonF       = xlon(jlat-1,ilon-1)
 plot(0)                     = gsn_csm_contour_map(wks,var(:,:),res)
 gsn_panel(wks,(/plot/),(/1,1/),False)
 end
