This file describes the workflow for the tropical cyclone (TC) analysis and creation of Figures 8 and 9 in Jones et al. (2023). 
Note that the file paths and names may need to be changed in the scripts depending on the user's environment.

1) To track TCs in the WRF model output, run the shell script "TC_tracking_WRF.sh". This script utilizes commands (DetectNodes and StitchNodes) from the TempestExtremes software package to track TCs based on minima in sea level pressure, a warm-core check, and various constraints on minimum storm intensity, track length, and formation latitude. The TC tracks and intensities are output into a text file.

2) Run "filter_WRF_domainedge.py" with each TC track text file as input to get rid of any TC track time steps when the TC center is right on the WRF domain boundary. The WRF domain grid edge locations are contained in wrf_grid.csv.

3) Run "filter_traj_file_byintensity.py" with each TC track text file as input to get rid of any TC track time steps when a TC's 10-m maximum wind speed is less than 17 m/s. 

4) Run "TC_precip_extract.sh" to extract TC-only precipitation (precipitation within 5 degrees around the TC center location) from the model output using the NodeFileFilter command in TempestExtremes. TC precipitation is output into new NetCDF files.

5) Run "convert_traj_file_tonetcdf.py" with each TC track text file as input to convert the text files to NetCDF files. In the tempest directory, the files beginning with "traj." and ending with "17min_noedges.nc" are the TC track NetCDF files for the WRF Historical and WRF SSP585 simulations created by following steps 1-4. 

6) Run "filter_TCs_like_WRF.py" on raw TC track observations from IBTrACS and ERA5 to filter the observed TC tracks on full global domains with the same tracking paramters as used on WRF in Step 1 using TempestExtremes. 

7) Run "convert_traj_file_tonetcdf.py" on the IBTrACS and ERA5 files output from Step 6. The files "ibtracs_NA_1980-2019_WRFfiltered.nc" and "ERA5_TC_tracks_frompaul_WRFfiltered.nc" are NetCDF files that contain the TC tracks from IBTrACS and ERA5. 

8) Run "plot_Figure8.py" to create Figure 8, which shows TC tracks, colored by Saffir-Simpson scale intensity, in IBTrACS, ERA5, and WRF Historical. 

9) Run "plot_Figure9.py" to create Figure 9, which shows the track and accumulated precipitation from Hurricane Irma in observations, WRF Historical, and the WRF SSP585 simulations. Required files not included in this directory are precipitation files from the CPC Unified Gauge-Based Analysis of Daily Precipitation over CONUS data for September 9-12, 2017. This data is provided by the NOAA PSL, Boulder, Colorado, USA, from their website at https://psl.noaa.gov. Also required is the WRF TC-only precipitation NetCDF files, output from Step 4.
