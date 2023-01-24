load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
external TEST "./delta_interp_mm.so"
;This scripts interpolates CMIP6 deltas to WRF domain
strtyrhis   = year
endyrhis    = strtyrhis

;This information needs to be changed based on the time period
strtyrrcp   = strtyrhis + 80
endyrrcp    = endyrhis  + 80

yearhis     = ispan(strtyrhis,endyrhis,1)
yearrcp     = ispan(strtyrrcp,endyrrcp,1)

; Mean delta

gcm         = "ModelMean"

; Select scenario

scenario    = "ssp245"

; Select model sensitivity

sensitivity = "Cold"
; Location of CMIP6 monthly delta

dirDelta    = "../../../data/"+scenario+"/"

; WRF grid
dirC        = "./"

WRFGridFile = addfile(dirC+"geo_em.d01.nc","r")

; Get WRF lat lon 

latWRFm     = WRFGridFile->XLAT_M(0,:,:) 
lonWRFm	    = WRFGridFile->XLONG_M(0,:,:)

latWRFu     = WRFGridFile->XLAT_U(0,:,:)
lonWRFu	    = WRFGridFile->XLONG_U(0,:,:)

latWRFv     = WRFGridFile->XLAT_V(0,:,:)
lonWRFv     = WRFGridFile->XLONG_V(0,:,:)

nyear       = dimsizes(yearhis)

; Loop through the years

do    yy    = 0, nyear-1

; Location of original met files

dirMetOrgnl = "../metfiles_interp/future2/"+yearrcp(yy)+"minus"+yearhis(yy)+"_jan-dec_"+scenario+"_"+sensitivity+gcm+"/original/"

; Location to write spatiotemporally interpolated met files

dirMetIntrp = "../metfiles_interp/future2/"+yearrcp(yy)+"minus"+yearhis(yy)+"_jan-dec_"+scenario+"_"+sensitivity+gcm+"/interpolated/"

print(dirMetOrgnl)
print(dirMetIntrp)

; Previous and next years for future year

yearrcp_m1  = yearrcp(yy)-1
yearrcp_p1  = yearrcp(yy)+1

; Previous and next years for historical year

yearhis_m1  = yearhis(yy)-1
yearhis_p1  = yearhis(yy)+1

; Read 3D Var for previous, current and next year

fhur_ym1    = addfile(dirDelta+"hur_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")
fta_ym1	    = addfile(dirDelta+"ta_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")

fhur	    = addfile(dirDelta+"hur_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")
fta	    = addfile(dirDelta+"ta_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")

fhur_yp1    = addfile(dirDelta+"hur_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")
fta_yp1	    = addfile(dirDelta+"ta_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+".era5.level_ensAvg.MovingAvg.delta.1deg.nc","r")

; Read 2D Var for previous, current amd next year

fhurs_ym1   = addfile(dirDelta+"hurs_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftas_ym1    = addfile(dirDelta+"tas_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftos_ym1    = addfile(dirDelta+"tos_Omon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
fts_ym1     = addfile(dirDelta+"ts_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_m1+".minus."+yearhis_m1+"_ensAvg.MovingAvg.delta.1deg.nc","r")


fhurs       = addfile(dirDelta+"hurs_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftas        = addfile(dirDelta+"tas_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftos        = addfile(dirDelta+"tos_Omon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+"_ensAvg.MovingAvg.delta.1deg.nc","r")
fts         = addfile(dirDelta+"ts_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp(yy)+".minus."+yearhis(yy)+"_ensAvg.MovingAvg.delta.1deg.nc","r")


fhurs_yp1   = addfile(dirDelta+"hurs_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftas_yp1    = addfile(dirDelta+"tas_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
ftos_yp1    = addfile(dirDelta+"tos_Omon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+"_ensAvg.MovingAvg.delta.1deg.nc","r")
fts_yp1     = addfile(dirDelta+"ts_Amon_"+sensitivity+gcm+"_"+scenario+"_"+yearrcp_p1+".minus."+yearhis_p1+"_ensAvg.MovingAvg.delta.1deg.nc","r")


; Number of lat, lon and levels in input delta

nlat     = 180
nlon     =  360
nlev_era = 37

; Number of monthly time steps, 12 for current year, 1 for previous and 1 for next year, total =14

ntime    = 14

; Create variables to store input delta from CMIP6
delta_hur1  		= new((/ntime,nlev_era,nlat,nlon/),"float")
delta_ta1     		= new((/ntime,nlev_era,nlat,nlon/),"float")
delta_hurs1   		= new((/ntime,nlat,nlon/),"float")
delta_tas1    		= new((/ntime,nlat,nlon/),"float")
delta_ts1     		= new((/ntime,nlat,nlon/),"float")
delta_tos1    		= new((/ntime,180,360/),"float")

; Read variables for last month of previous year, all months for current year and first month for next year

delta_hur1(0,:,:,:)     = fhur_ym1->hur(11,:,:,:)
delta_hur1(1:12,:,:,:)  = fhur->hur(:,:,:,:)
delta_hur1(13,:,:,:)    = fhur_yp1->hur(0,:,:,:)

delta_ta1(0,:,:,:)      = fta_ym1->ta(11,:,:,:)
delta_ta1(1:12,:,:,:)   = fta->ta(:,:,:,:)
delta_ta1(13,:,:,:)     = fta_yp1->ta(0,:,:,:)

delta_hurs1(0,:,:)    	= fhurs_ym1->hurs(11,:,:)
delta_hurs1(1:12,:,:) 	= fhurs->hurs(:,:,:)
delta_hurs1(13,:,:)   	= fhurs_yp1->hurs(0,:,:)

delta_tas1(0,:,:)     	= ftas_ym1->tas(11,:,:)
delta_tas1(1:12,:,:)  	= ftas->tas(:,:,:)
delta_tas1(13,:,:)    	= ftas_yp1->tas(0,:,:)

delta_ts1(0,:,:)      	= fts_ym1->ts(11,:,:)
delta_ts1(1:12,:,:)   	= fts->ts(:,:,:)
delta_ts1(13,:,:)     	= fts_yp1->ts(0,:,:)

delta_tos1(0,:,:)     	= ftos_ym1->tos(11,:,:)
delta_tos1(1:12,:,:)  	= ftos->tos(:,:,:)
delta_tos1(13,:,:)    	= ftos_yp1->tos(0,:,:)

; Convert 0 to 360 CMIP6 1 degree lon to -180 to 180 to match WRF grid

delta_hur        	= lonFlip(delta_hur1)
delta_ta         	= lonFlip(delta_ta1)
delta_hurs       	= lonFlip(delta_hurs1)
delta_tas        	= lonFlip(delta_tas1)
delta_ts         	= lonFlip(delta_ts1)
delta_tos        	= lonFlip(delta_tos1)

; Spatial interpolate from CMIP6 grid to WRF grid

interp_ta      		= rgrid2rcm (delta_ta&lat,  delta_ta&lon,  delta_ta, latWRFm, lonWRFm, 0)
interp_hur       	= rgrid2rcm (delta_hur&lat, delta_hur&lon, delta_hur, latWRFm, lonWRFm, 0)
interp_hurs      	= rgrid2rcm (delta_hurs&lat, delta_hurs&lon, delta_hurs, latWRFm, lonWRFm, 0)
interp_tas       	= rgrid2rcm (delta_tas&lat,  delta_tas&lon,  delta_tas,  latWRFm, lonWRFm, 0)
interp_ts        	= rgrid2rcm (delta_ts&lat,   delta_ts&lon,   delta_ts,   latWRFm, lonWRFm, 0)
interp_tos       	= rgrid2rcm (delta_tos&lat,  delta_tos&lon,  delta_tos,  latWRFm, lonWRFm, 0)

nlatWRFm         	= dimsizes(latWRFm(:,0))
nlonWRFm         	= dimsizes(lonWRFm(0,:))

nlatWRFu         	= dimsizes(latWRFu(:,0))
nlonWRFu         	= dimsizes(lonWRFu(0,:))

nlatWRFv         	= dimsizes(latWRFv(:,0))
nlonWRFv         	= dimsizes(lonWRFv(0,:))

; Number of levels in met files

nlev_met           	= 38

; List all the metfiles for the year of interest and save the list in fils

fils            = systemfunc("ls "+ dirMetOrgnl + "met*nc")

print(fils)
;total number of 3 hour time steps from mid December previous year to mid January next year

if(isleapyear(yearhis(yy))) then
ntime3h 		= 366 * 8 + 31*8
else
ntime3h 		= 365 * 8 + 31*8
end if


;Timesteps at the mid of each month of the year, staring mid December of previous year and ending in mid January of next year

if(isleapyear(yearhis(yy))) then
timesteps 		= (/1,248,488,728,972,1216,1460,1704,1952,2196,2440,2684,2928,3176/)
else
timesteps 		= (/1,248,484,720,964,1208,1452,1696,1944,2188,2432,2676,2920,3168/)
end if

ntimesteps  = dimsizes(timesteps)
month                   = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)
do   mm                 =  1, 13
;Variables to store 3 hourly temporally integrated delta
ntime3h_mm               = timesteps(mm) - timesteps(mm-1) + 1
interp_TT3h             = new((/ntime3h_mm,nlev_met,nlatWRFm,nlonWRFm/),"float")
interp_RH3h             = new((/ntime3h_mm,nlev_met,nlatWRFm,nlonWRFm/),"float")
interp_SST3h            = new((/ntime3h_mm,nlatWRFm,nlonWRFm/),"float")
interp_SKINTEMP3h       = new((/ntime3h_mm,nlatWRFm,nlonWRFm/),"float")



;Fortran code for temporal interpolation of deltas i.e.,for each grid cell it converts 14 monthly delta values (1 from previous year, 12 from current and 1 from next year) to 3 hourly timesteps creating ntime3h values
interp_ta_mm    = interp_ta(mm-1:mm,:,:,:)
interp_tas_mm   = interp_tas(mm-1:mm,:,:)
interp_hur_mm   = interp_hur(mm-1:mm,:,:,:)
interp_hurs_mm  = interp_hurs(mm-1:mm,:,:)
interp_tos_mm   = interp_tos(mm-1:mm,:,:)
interp_ts_mm    = interp_ts(mm-1:mm,:,:)
ntime_mm        = 2

TEST::delta(interp_ta_mm,interp_tas_mm,interp_hur_mm,interp_hurs_mm,interp_tos_mm,interp_ts_mm,interp_TT3h,interp_RH3h,interp_SST3h,interp_SKINTEMP3h,nlatWRFm,nlonWRFm,nlev_era,ntime_mm,nlev_met,ntime3h_mm)
interp_SST3h = where(ismissing(interp_SST3h),0,interp_SST3h)




; List all the metfiles for the year of interest and save the list in fils

;fils 		= systemfunc("ls "+ dirMetOrgnl + "met*"+yearhis(yy)+"*-"+month(mm-1)+"-*nc")

; Print the metfiles name for the year

;print(fils)
; Count number of metfiles

no_files        = dimsizes(fils)

; Loop over the metfiles

if(mm.eq.1) then
fstart = 0
else
fstart = timesteps(mm-1)-124
end if

if(mm.eq.13) then
fstop = timesteps(mm-1)-1
else
fstop =  timesteps(mm)-124-1
end if

print(fstart+" "+fstop)

if(mm.eq.1) then
; Removing steps previous year december
cc              = 124
else
cc              = 0
end if

do ff           = fstart, fstop;no_files-1

; Read the metfile for one step at a time in edit mode

fmet	        = addfile(fils(ff), "w")

;start from january for year of interest, i.e. remove steps from december of previous year

print(ff+" "+cc)
print(fils(ff))

; Read the required variables

tt              = fmet->TT
rh              = fmet->RH
sst             = fmet->SST
skintemp        = fmet->SKINTEMP
metfile_times   = fmet->Times

; Add deltas to variables

tt(0,:,:,:)     = tt(0,:,:,:) + interp_TT3h(cc,:,:,:)
rh(0,:,:,:)     = rh(0,:,:,:) + interp_RH3h(cc,:,:,:)
rh              = where(rh.gt.100,100,rh)
rh              = where(rh.lt.0,0,rh)
sst(0,:,:)      = sst(0,:,:) + interp_SST3h(cc,:,:)
skintemp(0,:,:) = skintemp(0,:,:) + interp_SKINTEMP3h(cc,:,:)

; Edit the year in Times from  met file

futureyear_str       = tostring(yearrcp(yy))
futureyear_char      = stringtochar(futureyear_str)
metfile_times(0,0:3) = futureyear_char(0:3)

; Write edited variables

fmet->TT        = tt
fmet->RH        = rh
fmet->SST       = sst
fmet->SKINTEMP  = skintemp
fmet->Times     = metfile_times

; Create new met file name with future year

fstr1           = tostring(fils(ff))
length          = strlen(fstr1)
fstr            = stringtochar(fstr1)
filehis         = tostring(fstr(length-33:))

fils_chr        = stringtochar(filehis)
fils_chr(11:14) = futureyear_char(0:3)
fils_fut        = chartostring(fils_chr)

; Move files to output directory

system("mv "+fils(ff) +" "+dirMetIntrp+"/"+fils_fut)

delete([/tt,rh,sst,skintemp,metfile_times/])
cc = cc + 1
end do

delete([/interp_TT3h,interp_RH3h,interp_SST3h,interp_SKINTEMP3h/]) 
delete([/interp_ta_mm,interp_tas_mm,interp_hur_mm,interp_hurs_mm,interp_tos_mm,interp_ts_mm/]) 
delete([/ntime3h_mm,ntime_mm/])  

end do
end do
end
