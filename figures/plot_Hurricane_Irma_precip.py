import numpy as np
import xarray as xr
import Ngl
import sys
sys.path.append("/global/homes/a/alyssas/python_functions/")
from surfaceWindCorrFactor import surfaceWindCorrFactor
from mask_tc_latlon import mask_tc_latlon
from math import sin, cos, sqrt, atan2, radians
from netCDF4 import Dataset
import pandas as pd
from shapely import geometry
import fiona





#plotting settings
wks_type = 'pdf'
output_name = 'Figure9_TCs'
wks = Ngl.open_wks(wks_type,output_name)
res = Ngl.Resources()
lineres = Ngl.Resources()
txres = Ngl.Resources()

#turn off drawing for individual plots,since we will panel them later
res.nglDraw = False
res.nglFrame = False

panel_plots = []#list to hold indiviudal plots before paneling
panel_labels = []

#map details
res.mpDataSetName = "Earth..4"
res.mpLimitMode = "Corners" #how you want to specify limits of map
res.mpLeftCornerLonF = float(-89) #Left Longitude Limit
res.mpRightCornerLonF = float(-79) #Right Longitude Limit
res.mpLeftCornerLatF = float(25) #Lower Latitude Limit
res.mpRightCornerLatF = float(32) #Upper Latitude Limit

res.mpFillOn              = True         # Turn on map fill.
res.mpFillAreaSpecifiers  = ["Water","Land","USStatesWater"]
res.mpSpecifiedFillColors = ["LightBlue1","LightBlue1","LightBlue1"]
res.mpAreaMaskingOn       = True            # Indicate we want to
res.mpMaskAreaSpecifiers  = "USStatesLand"  # mask land.
res.mpOutlineBoundarySets = "GeophysicalandUSStates" #draw US States
res.mpPerimOn = True
res.mpGridAndLimbOn = False


cmap ='precip_11lev' #colormap for precip plotting

res.cnFillOn = True #turn on contour fill
res.cnLineLabelsOn = False #turn off contour labels
res.cnLinesOn = False #Turn off contour lines
res.cnFillPalette = cmap #Set color palette for contour fills as cmap
res.cnLevelSelectionMode = "ExplicitLevels" #set contour levels
res.cnLineDrawOrder   = "Predraw" #draw contours first so then any masks will be plotted above them
res.cnFillDrawOrder   = "Predraw"
res.cnFillMode = "RasterFill"

res.lbLabelBarOn = False


res.cnLevels = np.arange(50,550,50) #contour levels for precip


#CPC precip data
cpc_file = xr.open_dataset("/global/cscratch1/sd/alyssas/CPC_gauge_precip_1948-2020.nc")
cpc_lat = cpc_file.lat.values
cpc_lon = cpc_file.lon.values
prect = cpc_file.precip.sel(time=slice("2017-09-09", "2017-09-12")).values #extract precip data for only the days Hurricane Irma was in the region
cpc_file.close()

prect[prect<=0] = np.nan
prect_sum = np.nansum(prect,axis=0) #calculate accumulated precip over the 3 days 
nlats = len(cpc_lat)
nlons = len(cpc_lon)


#calculate weights for area-weighting for averaging
rad = 4.*np.arctan(1.)/180.
clat = np.cos(cpc_lat*rad)
reverse_clat = np.fliplr([clat])[0]


fp = "/global/homes/a/alyssas/gz_2010_us_040_00_5m/gz_2010_us_040_00_5m.shp" #US state shapefile

for shapes in fiona.open(fp):
    if shapes['properties']['NAME'] == "Florida": #find shapefile info for Florida only
        geom_type = shapes['geometry']['type']
        geom_coords = shapes['geometry']['coordinates']
        test_array = np.full_like(prect_sum,np.nan)
        for part in geom_coords:
            part_squeeze = np.squeeze(part)
            part_shape = np.shape(part_squeeze)
            lons = []
            lats = []
            for i in range(part_shape[0]):
                lons.append(part_squeeze[i][0]+360)
                lats.append(part_squeeze[i][1])
            max_lat = max(lats)
            min_lat = min(lats)
            max_lon = max(lons)
            min_lon = min(lons)
            for k in range(nlats):
                for l in range(nlons):
                    if cpc_lat[k] <= max_lat and cpc_lat[k] >= min_lat and cpc_lon[l] <= max_lon and cpc_lon[l] >= min_lon:
                        if Ngl.gc_inout(cpc_lat[k], cpc_lon[l], lats, lons) != 0: #if point is within Florida, extract data from that point
                            test_array[k,l] = prect_sum[k,l]

        #mask out any values below 25N to only focus on mainland FL
        test_array[cpc_lat<25] = np.nan

        #calculate average accumulated precip over Florida, weighting by latitude
        test_array2 = np.ma.MaskedArray(test_array, mask=np.isnan(test_array))
        meanval = np.ma.mean(np.ma.average(test_array2,axis=0,weights=clat))
        panel_labels.append("Avg:"+str(round(meanval,2)))#add value to list to be added to panel plots



res.tiMainString = str("Observations")
res.sfXArray = cpc_lon
res.sfYArray = cpc_lat

#Get Hurricane Irma's observed track to add to plot
ibtracs_file = xr.open_dataset("ibtracs_NA_1980-2019_WRFfiltered.nc")
obs_lats = ibtracs_file.clat.values
obs_lons = ibtracs_file.clon.values
obs_time = ibtracs_file.time_str.values
ibtracs_file.close()

storm_date = "2017090906"
irma_idx_obs = np.where(obs_time==int(storm_date))[0]
irma_clats_obs = obs_lats[irma_idx_obs,:]
irma_clons_obs = obs_lons[irma_idx_obs,:]


#plot the accumulated precipitation and add observed track on top
precip_plot = Ngl.contour_map(wks, np.squeeze(np.nan_to_num(prect_sum)), res)

lineres.gsLineColor = "black"
lineres.gsLineThicknessF = 6.0
lineres.gsLineDashPattern = 1.0
Ngl.add_polyline(wks,precip_plot,irma_clons_obs[0],irma_clats_obs[0],lineres)

txres.txFontHeightF = 0.04
txres.txBackgroundFillColor = "white"
txres.txPerimColor = "black"
txres.txPerimOn = True
Ngl.add_text(wks, precip_plot, "(a)", -88, 26, txres)

panel_plots.append(precip_plot)



#WRF Simulations

#get latitudes/longitudes from one random file
latlonDS = xr.open_dataset("/global/project/projectdirs/m2637/TGW/CONUS_TGW_WRF_Historical/aux/wrfout_d01_1980-01-01_00:00:00_3hourly.aux.nc")
wrf_lats = latlonDS.XLAT.values
wrf_lons = latlonDS.XLONG.values
latlonDS.close()

#calculate weights for area-weighting
rad = 4.*np.arctan(1.)/180.
clat = np.cos(wrf_lats*rad)

nlats = np.shape(wrf_lats)[0]
nlons = np.shape(wrf_lons)[1]


sim_list = ["Historical", "SSP585_COLD_NEAR", "SSP585_HOT_NEAR", "SSP585_COLD_FAR", "SSP585_HOT_FAR"]
label_list = ["(b)", "(c)", "(d)", "(e)", "(f)"]


count=0
for name in sim_list:
    if name == "Historical":
        firstyear = 1980
        endyear = 2019
        res.tiMainString = "Historical"
    elif name == "SSP585_COLD_NEAR":
        firstyear = 2020
        endyear = 2059
        res.tiMainString = "SSP585COLD_NEAR"
    elif name == "SSP585_HOT_NEAR":
        res.tiMainString = "SSP585HOT_NEAR"
        firstyear = 2020
        endyear = 2059
    elif name == "SSP585_COLD_FAR":
        firstyear = 2060
        endyear = 2099
        res.tiMainString = "SSP585COLD_FAR"
    elif name == "SSP585_HOT_FAR":
        firstyear = 2060
        endyear = 2099
        res.tiMainString = "SSP585HOT_FAR"

    storm_year = endyear - 2 #calculate year that Hurricane Irma occurs in the simulation

    DS1 = xr.open_mfdataset(["/global/cscratch1/sd/alyssas/wrf_filtered/"+name+"/wrfout_d01_"+str(storm_year)+"-09-03_00:00:00_3hourly.nc_5deg_filtered.nc","/global/cscratch1/sd/alyssas/wrf_filtered/"+name+"/wrfout_d01_"+str(storm_year)+"-09-10_00:00:00_3hourly.nc_5deg_filtered.nc"])
    prect = DS1.PRECT.sel(time=slice(str(storm_year)+"-09-09", str(storm_year)+"-09-12")).values*3600000.*6. #extract precipitation from 3 days of interest and convert to mm
    DS1.close()
    prect[prect<=0] = np.nan

    precip_sum = np.nansum(prect,axis=0) #calculate accumulated precipitation over time

    for shapes in fiona.open(fp):
        if shapes['properties']['NAME'] == "Florida":
            geom_type = shapes['geometry']['type']
            geom_coords = shapes['geometry']['coordinates']
            test_array = np.full_like(precip_sum,np.nan)
            for part in geom_coords:
                part_squeeze = np.squeeze(part)
                part_shape = np.shape(part_squeeze)
                lons = []
                lats = []
                for i in range(part_shape[0]):
                    lons.append(part_squeeze[i][0])
                    lats.append(part_squeeze[i][1])
                max_lat = max(lats)
                min_lat = min(lats)
                max_lon = max(lons)
                min_lon = min(lons)
                for k in range(nlats):
                    for l in range(nlons):
                        if wrf_lats[k,l] <= max_lat and wrf_lats[k,l] >= min_lat and wrf_lons[k,l] <= max_lon and wrf_lons[k,l] >= min_lon:
                            if Ngl.gc_inout(wrf_lats[k,l], wrf_lons[k,l], lats, lons) != 0:
                                test_array[k,l] = precip_sum[k,l]

            test_array[wrf_lats<25] = np.nan

            test_array2 = np.ma.MaskedArray(test_array, mask=np.isnan(test_array))
            meanval = np.ma.mean(np.ma.average(test_array2,axis=0,weights=clat))


    #set x and y 1D arrays as x and y coordinates for plot
    res.sfXArray = wrf_lons
    res.sfYArray = wrf_lats

    #TC track file
    track_file = xr.open_dataset("trajectories."+name+"_17min_noedges.nc")
    clats = track_file.clat.values
    clons = track_file.clon.values
    time = track_file.time_str.values
    track_file.close()

    storm_date = str(storm_year)+"090906"
    irma_idx = np.where(time==int(storm_date))[0]
    irma_clats = clats[irma_idx,:]
    irma_clons = clons[irma_idx,:]

    precip_plot = Ngl.contour_map(wks, np.squeeze(np.nan_to_num(precip_sum)), res)

    lineres.gsLineColor = "black"
    lineres.gsLineThicknessF = 6.0
    lineres.gsLineDashPattern = 1.0
    Ngl.add_polyline(wks,precip_plot,irma_clons[0],irma_clats[0],lineres)

    panel_labels.append("Avg:"+str(round(meanval,2)))
    Ngl.add_text(wks, precip_plot, label_list[count], -88, 26, txres)
    panel_plots.append(precip_plot)
    count+=1

#panel the plots and plot
panelres = Ngl.Resources()
panelres.nglPanelLabelBar = True
panelres.nglPanelFigureStrings = panel_labels
panelres.nglPanelFigureStringsJust  = "TopLeft"
panelres.nglPanelFigureStringsFontHeightF = 0.013
Ngl.panel(wks,panel_plots[0:6],[3,2],panelres)
Ngl.end()
