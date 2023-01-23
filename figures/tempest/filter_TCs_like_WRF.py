from netCDF4 import Dataset, num2date, date2num
import numpy as np
import datetime as dt
from shapely import geometry
import pandas as pd


input_file = "ibtracs_NA_1980-2019.txt"
output_file = "ibtracs_NA_1980-2019_WRFfiltered.nc"
time_calendar = 'gregorian'


#get polygon of WRF domain to filter out track points outside of domain
wrf_domain = pd.read_csv("wrf_grid.csv", index_col=0)
outline_coords = zip(wrf_domain["lon"], wrf_domain["lat"])
polygon_geom = geometry.Polygon(outline_coords)



ntimes = []
header_locs = []
nstorms = 0 #counter for number of storms in file
years = []


#reading in the input text file and the data
with open(input_file,"r") as f:
    data = f.readlines()#read rest of data line by line and store in variable "data"
    line_count = 0
    for line in data:#looping through each line in textfile
        if "start" in line.split():
            ntimes.append(int(line.split()[1])) #save the number of time steps of data for each storm
            years.append(int(line.split()[2])) #save year in which storm occurred
            nstorms += 1 #counting total number of storms in file based on # of header lines
            header_locs.append(line_count)#find locations of all lines that begin with "start"
        line_count += 1


#create empty numpy arrays of appropriate shape to hold data
lons = np.full([int(nstorms),max(ntimes)],np.nan)
lats = np.full([int(nstorms),max(ntimes)],np.nan)
pmin = np.full([int(nstorms),max(ntimes)],np.nan)
vmax = np.full([int(nstorms),max(ntimes)],np.nan)
year = np.empty([int(nstorms),max(ntimes)],dtype=int)
month = np.empty([int(nstorms),max(ntimes)],dtype=int)
day = np.empty([int(nstorms),max(ntimes)],dtype=int)
hour = np.empty([int(nstorms),max(ntimes)],dtype=int)
dates = np.empty([int(nstorms),max(ntimes)],dtype=int)




#put data from file into the empty arrays - only data for storm points  within WRF domain
for i in range(nstorms):
    start = header_locs[i] + 1
    end = start + int(ntimes[i])
    tmp = data[start:end] #only work with subset of data for each individual stormID
    j = 0
    for row in tmp:
        columns = row.split() #split each line by whitespaces
        thislon = float(columns[2])-360.
        thislat = float(columns[3])
        thispoint = geometry.Point(thislon,thislat)
        if polygon_geom.contains(thispoint) == True: #only include track points that are within WRF domain
            lons[i,j] = (float(columns[2])-360.)
            lats[i,j] = (float(columns[3]))
            pmin[i,j] = (float(columns[4])/100.) #convert from Pa to hPa
            vmax[i,j] = (float(columns[5]))
            year[i,j] = (int(columns[6]))
            month[i,j] = (int(columns[7]))
            day[i,j] = (int(columns[8]))
            hour[i,j] = (int(columns[9]))
            j+=1

lons = lons + 360



#filter out TCs based on not meeting the WRF StitchNodes criteria
for i in range(nstorms):
    slats = lats[i,:]
    firstlat = slats[0] #first latitude point in one TC track

    slons = lons[i,:]
    spoints = ~np.isnan(slats) 

    hour_diffs = np.diff(hour[i,spoints]) #find number of hours between each TC track point

    for j in range(len(hour_diffs)):
        if hour_diffs[j] != 6. and hour_diffs[j] != -18.: #maximum gap between track points can only be 6 hours, if gap is greater than 6 hours, extract either first half or second half of TC track
            if j < len(hour_diffs)/2.:
                slats_nogap = lats[i,j+1:len(hour_diffs)+1]
                vmax_nogap = vmax[i,j+1:len(hour_diffs)+1]
                hour_nogap = hour[i,j+1:len(hour_diffs)+1]
            elif j > len(hour_diffs)/2.:
                slats_nogap = lats[i,:j+1]
                vmax_nogap = vmax[i,:j+1]
                hour_nogap = hour[i,:j+1]
            break

    if 'slats_nogap' in locals():
        pass
    else: #if there are no gaps between TC track points, extract entire TC track
        slats_nogap = slats[spoints]
        hour_nogap = hour[i,spoints]
        vmax_nogap = vmax[i,spoints]

    slen = len(slats_nogap)
    vmax_idx = np.where(vmax_nogap>10) #find points in TC track where the max. 10-m wind speed is greater than 10 m/s
    vmax_len = np.shape(vmax_idx)[1] #count number of these points
    del (slats_nogap, vmax_nogap, hour_nogap)


    if slen < 5. or abs(firstlat)>35. or vmax_len<2.: #Track must last at least 24 hours (5 timesteps in 6-hourly dataset), first latitude point must be equatorward or at 35 degrees N, max wind speed must be at least 10 m/s for at least 2 timesteps
        lats[i,:] = np.nan
        lons[i,:] = np.nan
        pmin[i,:] = np.nan
        vmax[i,:] = np.nan
        year[i,:] = 0
        month[i,:] = 0
        day[i,:] = 0
        hour[i,:] = 0




#create new NetCDF file to write
new_file = Dataset(output_file,'w')
new_file.description = 'Results from tempestextremes StitchNodes reformatted to NetCDF'
new_file.author = 'A. M. Stansfield'
new_file.creation_date = str(dt.date.today())

#create dimensions
stormID = new_file.createDimension('stormID', None)
time = new_file.createDimension('time',int(max(ntimes)))

#create variables
clon = new_file.createVariable('clon','f4',('stormID','time'),fill_value = 0)
clat = new_file.createVariable('clat','f4',('stormID','time'),fill_value = 0)
min_p = new_file.createVariable('min_p','f4',('stormID','time'),fill_value = 0)
vmax_2D = new_file.createVariable('vmax_2D','f4',('stormID','time'),fill_value = 0)
time_str = new_file.createVariable('time_str','i4',('stormID','time'))
seasons = new_file.createVariable('seasons','i4',('stormID'),fill_value = 0)

#add local attributes to variables
clon.units = 'degrees_east'
clon.long_name = 'storm center longitude'

clat.units = 'degrees_north'
clat.long_name = 'storm center latitude'

min_p.units = 'hPa'
min_p.long_name = 'minimum central pressure'

vmax_2D.units = 'm/s'
vmax_2D.long_name = 'max. wind speed from 2D wind field'

seasons.long_name = 'year of hurricane season'

#add extracted data into netCDF variables
clon[:,:] = lons
clat[:,:] = lats
min_p[:,:] = pmin
vmax_2D[:,:] = vmax
seasons[:] = years

#fill time variable as integers
for i in range(nstorms):
    for j in range(ntimes[i]):
        time_str[i,j] = int(str(year[i,j]) + str(month[i,j]).zfill(2) + str(day[i,j]).zfill(2) + str(hour[i,j]).zfill(2))


new_file.close()
