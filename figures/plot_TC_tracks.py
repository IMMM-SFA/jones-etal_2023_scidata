#script to plot TC tracks, colored by Saffir-Simpson intensity, in observations, ERA5, and WRF TGW simulations

import numpy as np
import xarray as xr
import Ngl
import sys
sys.path.append("/global/homes/a/alyssas/python_functions/")
from surfaceWindCorrFactor import surfaceWindCorrFactor
from mask_tc_latlon import mask_tc_latlon
from math import sin, cos, sqrt, atan2, radians
from netCDF4 import Dataset
#import pyproj
import pandas as pd
from shapely import geometry




#plotting settings
wks_type = 'pdf' 
output_name = 'Figure8_TCs'
wks = Ngl.open_wks(wks_type,output_name)
res = Ngl.Resources()
lineres = Ngl.Resources()
txres = Ngl.Resources()

#turn off drawing for individual plots,since we will panel them later
res.nglDraw = False
res.nglFrame = False

panel_plots = []#list to hold indiviudal plots before paneling
nstorm_list = []#list to hold annual mean # of storms in each dataset

#map details
res.mpDataSetName = "Earth..2"
res.mpDataBaseVersion = "MediumRes"
res.mpLimitMode = "Corners" #how you want to specify limits of map
res.mpLeftCornerLonF = float(-105) #Left Longitude Limit
res.mpRightCornerLonF = float(-60) #Right Longitude Limit
res.mpLeftCornerLatF = float(20) #Lower Latitude Limit
res.mpRightCornerLatF = float(55) #Upper Latitude Limit

res.mpAreaMaskingOn = True #turn masking on
res.mpFillOn = True
res.mpOceanFillColor = -1 #don't fill ocean
res.mpLandFillColor = "Tan" #land is transparent
res.mpInlandWaterFillColor = -1 #don't fill inland water masses
res.mpOutlineBoundarySets = "National" #draw national borders
res.mpPerimOn = True
res.mpGridAndLimbOn = False

linethicknesses = [2.0,4.0,5.2,7.6,9.2,10.4] #line thicknesses for different TC intensities


#IBTrACS observations
ibtracs = xr.open_dataset("ibtracs_NA_1980-2019_WRFfiltered.nc")
clats_obs = ibtracs.clat.values
clons_obs = ibtracs.clon.values
vmax_obs = ibtracs.vmax_2D.values
ibtracs.close()
nstorms_obs = np.shape(clats_obs)[0]
ntimes_obs = np.shape(clats_obs)[1]

clats_obs[clats_obs<=0] = np.nan
clons_obs[clats_obs<=0] = np.nan
vmax_obs[clats_obs<=0] = np.nan


clons_obs = clons_obs - 360.

res.tiMainFontHeightF = 0.035
res.tiMainString = "Observations"
map_obs = Ngl.map(wks,res)

storm_count_obs = 0
for i in range(nstorms_obs):
    in_box = False
    for j in range(ntimes_obs):
            thislat = clats_obs[i,j]
            thislon = clons_obs[i,j]
            thiswind = vmax_obs[i,j]
            if np.isfinite(thiswind) == True and thiswind>=17.:
                in_box = True
                #plot TC track segment color-coded based on Saffir-Simpson wind category
                if thiswind >= 17. and thiswind < 33.:
                        lineres.gsLineColor = "green3"
                        lineres.gsLineThicknessF = linethicknesses[1]
                elif thiswind >= 33. and thiswind < 43:
                        lineres.gsLineColor = "yellow2"
                        lineres.gsLineThicknessF = linethicknesses[2]
                elif thiswind >= 43 and thiswind < 49:
                        lineres.gsLineColor = "orange"
                        lineres.gsLineThicknessF = linethicknesses[3]
                elif thiswind >= 49 and thiswind < 58:
                        lineres.gsLineColor = "darkorange3"
                        lineres.gsLineThicknessF = linethicknesses[4]
                elif thiswind >= 58.:
                        lineres.gsLineColor = "red"
                        lineres.gsLineThicknessF = linethicknesses[5]
                if j != 0:
                    pline = Ngl.add_polyline(wks,map_obs,[thislon,clons_obs[i,j-1]],[thislat,clats_obs[i,j-1]],lineres)
    if in_box == True: #counting number of TCs
        storm_count_obs+=1

#more plot settings
txres.txFontHeightF = 0.04
txres.txBackgroundFillColor = "white"
txres.txPerimColor = "black"
txres.txPerimOn = True
Ngl.add_text(wks, map_obs, "(a)", -101, 51, txres)

panel_plots.append(map_obs)
nstorm_list.append(str(round(storm_count_obs/40.,1))) #calculate annual mean # of TCs and add text to plot



#ERA5
era5_file = xr.open_dataset("ERA5_TC_tracks_frompaul_WRFfiltered.nc",decode_times=False, drop_variables='time')
seasons_era = era5_file.seasons
clats_era = era5_file.clat.values
clons_era = era5_file.clon.values
vmax_era = era5_file.vmax_2D.values
era5_file.close()

#only extract TCs for time period of interest (1980-2019)
idx = np.where((seasons_era>=1980)&(seasons_era<=2019))[0]
clats_era = clats_era[idx]
clons_era = clons_era[idx]
vmax_era = vmax_era[idx]

nstorms_era = np.shape(clats_era)[0]
ntimes_era = np.shape(clats_era)[1]

clats_era[clats_era<=0] = np.nan
clons_era[clats_era<=0] = np.nan
vmax_era[clats_era<=0] = np.nan

clons_era = clons_era-360.

res.tiMainString = "ERA5"
map_era = Ngl.map(wks,res)

storm_count_era = 0
for i in range(nstorms_era):
    in_box = False
    for j in range(ntimes_era):
            thislat = clats_era[i,j]
            thislon = clons_era[i,j]
            thiswind = vmax_era[i,j]
            if np.isfinite(thiswind) == True and thiswind>=17.:
                in_box = True
                if thiswind >= 17. and thiswind < 33.:
                        lineres.gsLineColor = "green3"
                        lineres.gsLineThicknessF = linethicknesses[1]
                elif thiswind >= 33. and thiswind < 43:
                        lineres.gsLineColor = "yellow2"
                        lineres.gsLineThicknessF = linethicknesses[2]
                elif thiswind >= 43 and thiswind < 49:
                        lineres.gsLineColor = "orange"
                        lineres.gsLineThicknessF = linethicknesses[3]
                elif thiswind >= 49 and thiswind < 58:
                        lineres.gsLineColor = "darkorange3"
                        lineres.gsLineThicknessF = linethicknesses[4]
                elif thiswind >= 58.:
                        lineres.gsLineColor = "red"
                        lineres.gsLineThicknessF = linethicknesses[5]
                if j != 0:
                    pline = Ngl.add_polyline(wks,map_era,[thislon,clons_era[i,j-1]],[thislat,clats_era[i,j-1]],lineres)
    if in_box == True:
        storm_count_era+=1

txres.txFontHeightF = 0.04
txres.txBackgroundFillColor = "white"
txres.txPerimColor = "black"
txres.txPerimOn = True
Ngl.add_text(wks, map_era, "(b)", -101, 51, txres)

panel_plots.append(map_era)
nstorm_list.append(str(round(storm_count_era/40.,1)))



#WRF Historical simulation
files1 = "trajectories.Historical_17min_noedges.nc"
DS1 = xr.open_dataset(files1, decode_times=False, drop_variables='time')
clons1 = DS1.clon.values
clats1 = DS1.clat.values
vmax1 = DS1.vmax_2D.values
MSLP1 = DS1.min_p.values
nstorms1 = len(clons1[:,0])
ntimes1 = len(clons1[0,:])
DS1.close()

clats1[clats1<=0] = np.nan
clons1[clats1<=0] = np.nan
vmax1[vmax1<=0] = np.nan


res.tiMainString = "WRF Historical"

map_wrf = Ngl.map(wks,res)

storm_count_wrf = 0
for i in range(nstorms1):
        in_box = False
        for j in range(ntimes1):
                thislat = clats1[i,j]
                thislon = clons1[i,j]
                thiswind = vmax1[i,j]
                if np.isfinite(thiswind) == True and thiswind>=17.:
                    in_box=True
                    if thiswind >= 17. and thiswind < 33.:
                            lineres.gsLineColor = "green3"
                            lineres.gsLineThicknessF = linethicknesses[1]
                    elif thiswind >= 33. and thiswind < 43:
                            lineres.gsLineColor = "yellow2"
                            lineres.gsLineThicknessF = linethicknesses[2]
                    elif thiswind >= 43 and thiswind < 49:
                            lineres.gsLineColor = "orange"
                            lineres.gsLineThicknessF = linethicknesses[3]
                    elif thiswind >= 49 and thiswind < 58:
                            lineres.gsLineColor = "darkorange3"
                            lineres.gsLineThicknessF = linethicknesses[4]
                    elif thiswind >= 58:
                            lineres.gsLineColor = "red"
                            lineres.gsLineThicknessF = linethicknesses[5]
                    if j != 0:
                        pline = Ngl.add_polyline(wks,map_wrf,[thislon,clons1[i,j-1]],[thislat,clats1[i,j-1]],lineres)
        if in_box == True:
            storm_count_wrf+=1

Ngl.add_text(wks, map_wrf, "c", -101, 51, txres)
panel_plots.append(map_wrf)
nstorm_list.append(str(round(storm_count_wrf/40.,1)))


#set up a legend for the bottom plot to show different Saffir-Simpson category colors
lgres                    = Ngl.Resources()
lgres.lgAutoManage       = False
lgres.vpWidthF = 0.75
lgres.vpHeightF          = 0.07

lgres.lgOrientation = "Horizontal"

lgres.lgMonoItemType        = False                 #indicates that we wish to set the item types individually
lgres.lgMonoMarkerIndex     = False
lgres.lgMonoLineThickness   = False
lgres.lgMonoMarkerSize      = True

lgres.lgLabelFontHeightF      = 0.013

lgres.lgItemCount        = 5
lgres.lgItemTypes        = ["Markers","Markers","Markers","Markers","Markers"]
lgres.lgMarkerIndexes    = [16,      16,      16,      16,      16]
lgres.lgMarkerSizeF = 0.013
lgres.lgMarkerColors = ["green3", "yellow2", "orange", "darkorange3", "red"]
legend_labels = ["TS", "Cat 1", "Cat 2", "Cat 3", "Cat 4/5"]

legend = Ngl.legend_ndc(wks,lgres.lgItemCount,legend_labels,0.12,0.38,lgres)


#panel the plots and plot
panelres = Ngl.Resources()
panelres.nglPanelLabelBar = False
panelres.nglPanelBottom = 0.05
panelres.nglPanelFigureStrings = nstorm_list
panelres.nglPanelFigureStringsFontHeightF = 0.02
Ngl.panel(wks,panel_plots[0:3],[1,3],panelres)
Ngl.end()
