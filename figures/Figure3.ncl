load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code creates scatter plot for figure 3
;Future scenario
 scenario     = "ssp585"

;Path to data
 dir          = "~/data/"

;Read CONUS mask
 fmask        = addfile("PRISM_1deg.nc","r")
 mask1        = fmask->tmax(0,:,:)

 year         = ispan(1980,2099,1)

;GCM names
 gcm          = (/"ACCESS-ESM1-5","CanESM5","CNRM-CM6-1-HR","GFDL-ESM4","GISS-E2-1-G","HadGEM3-GC31-LL","NorESM2-MM","UKESM1-0-LL"/)

;Create new variables to store values
 tas_gg       = new((/dimsizes(gcm),6,dimsizes(year),180,360/),"float")
 hurs_gg      = new((/dimsizes(gcm),6,dimsizes(year),180,360/),"float")

;Read and Process data
do gg         = 0,dimsizes(gcm)-1
 print(gg)

if(gcm(gg).eq."ACCESS-CM2") then
 variant      = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."ACCESS-ESM1-5") then
 variant      = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1","r4i1p1f1","r5i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."CanESM5") then
 variant      = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1","r4i1p1f1","r5i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."CNRM-CM6-1") then
 variant      = (/"r1i1p1f2","r2i1p1f2","r3i1p1f2","r4i1p1f2","r5i1p1f2"/)
 grd          = "gr"
end if

if(gcm(gg).eq."CNRM-CM6-1-HR") then
 variant      = (/"r1i1p1f2"/)
 grd          = "gr"
end if

if(gcm(gg).eq."CNRM-ESM2-1") then
 variant      = (/"r1i1p1f2","r2i1p1f2","r3i1p1f2","r4i1p1f2","r5i1p1f2"/)
 grd          = "gr"
end if

if(gcm(gg).eq."GFDL-ESM4") then
 variant      = (/"r1i1p1f1"/)
 grd          = "gr1"
end if

if(gcm(gg).eq."GISS-E2-1-G") then
 variant      = (/"r1i1p3f1","r2i1p3f1","r3i1p3f1","r4i1p3f1","r5i1p3f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."HadGEM3-GC31-LL") then
 variant      = (/"r1i1p1f3"/)
 grd          = "gn"
end if

if(gcm(gg).eq."MPI-ESM1-2-HR") then
 variant      = (/"r1i1p1f1","r2i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."MPI-ESM1-2-LR") then
 variant      = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1","r4i1p1f1","r5i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."NorESM2-MM") then
 variant      = (/"r1i1p1f1"/)
 grd          = "gn"
end if

if(gcm(gg).eq."UKESM1-0-LL") then
 variant      = (/"r1i1p1f2","r2i1p1f2","r3i1p1f2","r4i1p1f2"/)
 grd          = "gn"
end if

;For each ensemble read the data and store the values
do vv  = 0, dimsizes(variant)-1

 tas          = new((/1440,180,360/),"float")
 hurs         = new((/1440,180,360/),"float")
 tas_mmyy     = new((/dimsizes(year),12,180,360/),"float")
 hurs_mmyy    = new((/dimsizes(year),12,180,360/),"float")

 ftas_his     = addfile(dir+"tas_Amon_"+gcm(gg)+"_historical_"+variant(vv)+"_"+grd+"_198001-201412_1deg.nc","r")
 fhurs_his    = addfile(dir+"hurs_Amon_"+gcm(gg)+"_historical_"+variant(vv)+"_"+grd+"_198001-201412_1deg.nc","r")
 ftas_ssp     = addfile(dir+"tas_Amon_"+gcm(gg)+"_"+scenario+"_"+variant(vv)+"_"+grd+"_201501-210012_1deg.nc","r")
 fhurs_ssp    = addfile(dir+"hurs_Amon_"+gcm(gg)+"_"+scenario+"_"+variant(vv)+"_"+grd+"_201501-210012_1deg.nc","r")

 tas(0:419,:,:)     = ftas_his->tas
 hurs(0:419,:,:)    = fhurs_his->hurs
 tas(420:1439,:,:)  = ftas_ssp->tas(0:1019,:,:)
 hurs(420:1439,:,:) = fhurs_ssp->hurs(0:1019,:,:)

do yy = 0,dimsizes(year)-1
do mm = 0,11
 tas_mmyy(yy,mm,:,:)  = tas(yy*12+mm,:,:)
 hurs_mmyy(yy,mm,:,:) = hurs(yy*12+mm,:,:)
end do
end do

 tas_yy   = dim_avg_n_Wrap(tas_mmyy,1)
 hurs_yy  = dim_avg_n_Wrap(hurs_mmyy,1)

 mask_yy  = conform(tas_yy,mask1,(/1,2/))
 tas_yy   = where(ismissing(mask_yy),tas_yy@_FillValue,tas_yy)
 hurs_yy  = where(ismissing(mask_yy),hurs_yy@_FillValue,hurs_yy)

 tas_gg(gg,vv,:,:,:)  = tas_yy
 hurs_gg(gg,vv,:,:,:) = hurs_yy
 delete(tas)
 delete(hurs)
 delete(tas_mmyy)
 delete(hurs_mmyy)
end do

;Calculate ensemble mean 
if(dimsizes(variant).gt.1) then
 tas_gg(gg,5,:,:,:)   = dim_avg_n_Wrap(tas_gg(gg,0:dimsizes(variant)-1,:,:,:),0)
 hurs_gg(gg,5,:,:,:)  = dim_avg_n_Wrap(hurs_gg(gg,0:dimsizes(variant)-1,:,:,:),0)
else 
 tas_gg(gg,5,:,:,:)   = tas_gg(gg,0,:,:,:)
 hurs_gg(gg,5,:,:,:)  = hurs_gg(gg,0,:,:,:)
end if

 delete(variant)

end do


 wks  = gsn_open_wks ("pdf", "Figure3")

 setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 300000000
 end setvalues

 diff_ssp1 = new((/dimsizes(gcm)+1,2,2/),"float")
 diff_ssp2 = new((/dimsizes(gcm)+1,2,2/),"float")

do gg = 0,dimsizes(gcm)-1

 tmp2              = dim_avg_n_Wrap(tas_gg(gg,5,80:119,:,:),0) - dim_avg_n_Wrap(tas_gg(gg,5,0:39,:,:),0)
 diff_ssp2(gg,0,0) = avg(tmp2);dim_avg_n_Wrap(tmp2,(/1,2/))
 tmp4              = dim_avg_n_Wrap(hurs_gg(gg,5,80:119,:,:),0) - dim_avg_n_Wrap(hurs_gg(gg,5,0:39,:,:),0)
 diff_ssp2(gg,1,0) = avg(tmp4);dim_avg_n_Wrap(tmp4,(/1,2/))

end do

 diff_ssp2(dimsizes(gcm),0,0) = dim_avg(diff_ssp2(0:dimsizes(gcm)-1,0,0))
 diff_ssp2(dimsizes(gcm),1,0) = dim_avg(diff_ssp2(0:dimsizes(gcm)-1,1,0))

 ngcm                       = dimsizes(gcm)
 plot                       = new ( 1, "graphic" )
 res                        = True
 res@gsnDraw                = False        ; Don't draw plot or advance
 res@gsnFrame               = False        ; frame. Will do this later.
 res@xyMarkLineMode         = "Markers"
 res@xyMarkerThicknessF     = 4
 res@xyMarkerColors         = (/"plum4",\
			        "blue4",\
	 		        "forestgreen",\
			        "burlywood4",\
			        "deeppink",\
			        "orangered",\
			        "brown4",\
			        "gray53",\
		                "black"/)
			   
 res@xyMarkers              = (/16,16,16,16,16,\
			      16,16,16,0/)
 res@pmLegendDisplayMode    = "Always"
 res@xyExplicitLegendLabels = (/gcm(0),gcm(1),gcm(2),gcm(3),gcm(4),gcm(5),\
 				gcm(6),gcm(7),"mean"/)

 res@trYMinF                = -10.                  ; min value on y-axis
 res@trYMaxF                = 2.
 res@trXMinF                = 0                  ; min value on y-axis
 res@trXMaxF                = 10

 plot(0)                    = gsn_csm_xy (wks,diff_ssp2(:,0,:),diff_ssp2(:,1,:),res)
 gsn_panel(wks,(/plot(0)/),(/1,1/),False)
end
