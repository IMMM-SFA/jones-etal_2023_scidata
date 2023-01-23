load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;This code creates plots for Figure 13
fmask         = addfile("PRISM_1deg.nc","r")
mask1         = fmask->tmax(0,{20:55},{230:305})
lat          := fmask->lat({20:55})
lon          := fmask->lon({230:305})
lon           = lon-360.
mask1&lon     = lon

year          = ispan(1980,2099,1)
var           = "tas"
dir245        = "~/data/ssp245/"
dir585        = "~/data/ssp585/"

pdfname       = "Figure13"
wks           = gsn_open_wks ("pdf",pdfname)

setvalues NhlGetWorkspaceObjectId()
"wsMaximumSize" : 300000000
end setvalues

plot          = new ( 1, "graphic" )
nts           = 120
tHOT585       = new((/nts,12/),"float")
tHOT245       = new((/nts,12/),"float")
tCOLD585      = new((/nts,12/),"float")
tCOLD245      = new((/nts,12/),"float")

do yy         = 0, dimsizes(year)-1

f1HOT585      = addfile(dir585+var+"_Amon_HotModelMean_ssp585_"+year(yy)+"_ensAvg.1deg.nc","r")
f1COLD585     = addfile(dir585+var+"_Amon_ColdModelMean_ssp585_"+year(yy)+"_ensAvg.1deg.nc","r")

f1HOT245      = addfile(dir245+var+"_Amon_HotModelMean_ssp245_"+year(yy)+"_ensAvg.1deg.nc","r")
f1COLD245     = addfile(dir245+var+"_Amon_ColdModelMean_ssp245_"+year(yy)+"_ensAvg.1deg.nc","r")


t1HOT585      = f1HOT585->$var$(:,{20:55},{230:305})
lat          := f1HOT585->lat({20:55})
lon          := f1HOT585->lon({230:305})
lon           = lon-360.
t1HOT585&lon  = lon
maskC         = conform(t1HOT585,mask1,(/1,2/))
t1HOT585      = where(ismissing(maskC),t1HOT585@_FillValue,t1HOT585)
tHOT585(yy,:) = dim_avg_n_Wrap(t1HOT585,(/1,2/))
delete(lat)
delete(lon)

t1COLD585      = f1COLD585->$var$(:,{20:55},{230:305})
lat           := f1COLD585->lat({20:55})
lon           := f1COLD585->lon({230:305})
lon            = lon-360.
t1COLD585&lon  = lon
t1COLD585      = where(ismissing(maskC),t1COLD585@_FillValue,t1COLD585)
tCOLD585(yy,:) = dim_avg_n_Wrap(t1COLD585,(/1,2/))
delete(lat)
delete(lon)


t1HOT245       = f1HOT245->$var$(:,{20:55},{230:305})
lat           := f1HOT245->lat({20:55})
lon           := f1HOT245->lon({230:305})
lon            = lon-360.
t1HOT245&lon   = lon
t1HOT245       = where(ismissing(maskC),t1HOT245@_FillValue,t1HOT245)
tHOT245(yy,:)  = dim_avg_n_Wrap(t1HOT245,(/1,2/))
delete(lat)
delete(lon)

t1COLD245      = f1COLD245->$var$(:,{20:55},{230:305})
lat           := f1COLD245->lat({20:55})
lon           := f1COLD245->lon({230:305})
lon            = lon-360.
t1COLD245&lon  = lon
t1COLD245      = where(ismissing(maskC),t1COLD245@_FillValue,t1COLD245)
tCOLD245(yy,:) = dim_avg_n_Wrap(t1COLD245,(/1,2/))
delete(lat)
delete(lon)

end do

fera           = addfile("/global/cfs/cdirs/m2702/im3-climtask/data/ERA5/monthly/2t/ERA5_2t_CONUS_monthly_197901_201912.nc","r")
fera           = addfile("ERA5_2t_CONUS_monthly_197901_201912_1deg.nc","r")
tera1          = fera->t2m(12:,{20:55},{230:305})
lat           := fera->lat({20:55})
lon           := fera->lon({230:305})
lon            = lon-360.
tera1&lon      = lon
delete(maskC)
maskC          = conform(tera1,mask1,(/1,2/))
tera1          = where(ismissing(maskC),tera1@_FillValue,tera1)


tera           = new((/120,12/),"float")

do yy1         = 0,39
do mm1         = 0,11
tera(yy1,mm1)  = avg(tera1(yy1*12+mm1,:,:))
end do
end do

tera(40:79,:)  = tera(0:39,:)
tera(80:,:)    = tera(0:39,:)
tera           = tera     - 273.15
tHOT585        = tHOT585  - 273.15
tCOLD585       = tCOLD585 - 273.15
tHOT245        = tHOT245  - 273.15
tCOLD245       = tCOLD245 - 273.15

tera(40:,:)    = tera@_FillValue

;Plotting
res                       = True           ; plot mods desired
res@gsnDraw               = False
res@gsnFrame              = False
res@gsnMaximize           = True            ; maximize plot size
res@xyLineThicknessF      = 2.0            ; make thicker

res@vpHeightF             = 0.4            ; change aspect ratio of plot
res@vpWidthF              = 0.70                 

res@pmLegendParallelPosF  = -.30           ; move to different location           
res@pmLegendOrthogonalPosF= -0.2         
  
res@xyMonoDashPattern     = True            ; all solid lines
res@trYMaxF               =  10
res@trYMinF               =  -2
res@xyLineColors          = (/"black","red","blue","red","blue"/)
res@gsLineDashPattern     = 4    
res@xyDashPatterns        = (/0,0,0,2,2/)
resd                      = res
yearts                    = ispan(1980,2099,1)

;Create annual averages
tera_ann                  = dim_avg_n_Wrap(tera,1)
tHOT585_ann               = dim_avg_n_Wrap(tHOT585,1)
tCOLD585_ann              = dim_avg_n_Wrap(tCOLD585,1)
tHOT245_ann               = dim_avg_n_Wrap(tHOT245,1)
tCOLD245_ann              = dim_avg_n_Wrap(tCOLD245,1)

;Create anomalies
tera_ann                  = tera_ann     - avg(tera_ann(0:9))
tHOT585_ann               = tHOT585_ann  - avg(tHOT585_ann(0:9))
tCOLD585_ann              = tCOLD585_ann - avg(tCOLD585_ann(0:9))
tHOT245_ann               = tHOT245_ann  - avg(tHOT245_ann(0:9))
tCOLD245_ann              = tCOLD245_ann - avg(tCOLD245_ann(0:9))


res@tiMainString          = "Annual"
plot(0)                   = gsn_csm_xy(wks,yearts,(/tera_ann,tHOT585_ann,tCOLD585_ann/),res)

resd@xyDashPattern        = 2
delete(resd@xyLineColors)
resd@xyLineColors         = (/"red","blue"/)
plot2                     = gsn_csm_xy(wks,yearts,(/tHOT245_ann,tCOLD245_ann/),resd)
overlay(plot(0),plot2)

resP                      = True                 ; modify the panel plot
resP@gsnPanelMainString   = " "
gsn_panel(wks,(/plot(0)/),(/1,1/),resP)

end do
end
