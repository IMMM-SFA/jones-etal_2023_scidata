#take data from tempestextremes StitchNodes output textfile and convert it to a NetCDF

from netCDF4 import Dataset, num2date, date2num
import numpy as np
import datetime as dt

simulation_name = "SSP585_HOT_FAR"

#USER INPUT
input_file = "trajectories.txt."+simulation_name+"_17min_noedges"
output_file = "trajectories."+simulation_name+"_17min_noedges.nc"
time_calendar = 'gregorian'

ntimes = []
header_locs = []
nstorms = 0 #counter for number of storms in file
years = []

#reading in the text file and the data
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
lons = np.empty([int(nstorms),max(ntimes)])
lats = np.empty([int(nstorms),max(ntimes)])
pmin = np.empty([int(nstorms),max(ntimes)])
vmax = np.empty([int(nstorms),max(ntimes)])
year = np.empty([int(nstorms),max(ntimes)],dtype=int)
month = np.empty([int(nstorms),max(ntimes)],dtype=int)
day = np.empty([int(nstorms),max(ntimes)],dtype=int)
hour = np.empty([int(nstorms),max(ntimes)],dtype=int)
dates = np.empty([int(nstorms),max(ntimes)],dtype=int)


#now put data from file into the empty arrays
for i in range(nstorms):
    start = header_locs[i] + 1
    end = start + int(ntimes[i])
    tmp = data[start:end] #only work with subset of data for each individual stormID
    j = 0 
    for row in tmp:
        columns = row.split() #split each line by whitespaces
        lons[i,j] = (float(columns[2]))
        lats[i,j] = (float(columns[3]))
        pmin[i,j] = (float(columns[4])/100.) #convert from Pa to hPa
        vmax[i,j] = (float(columns[5]))
        year[i,j] = (int(columns[7]))
        month[i,j] = (int(columns[8]))
        day[i,j] = (int(columns[9]))
        hour[i,j] = (int(columns[10]))
        j+=1


#reformatting date information
iyear = str(year[0][0])
imonth = str(month[0][0])
if len(imonth) == 1:
    imonth = '0' + imonth
iday = str(day[0][0])
if len(iday) == 1:
    iday = '0' + iday
ihour = str(hour[0][0])
if len(ihour) == 1:
    ihour = '0' + ihour


#create new NetCDF file to write
new_file = Dataset(output_file,'w')
new_file.description = 'Results from tempestextremes StitchNodes reformatted to NetCDF'
new_file.author = 'A. M. Stansfield'
new_file.creation_date = str(dt.date.today())

#create dimensions
stormID = new_file.createDimension('stormID', None) #create dimension based on total number of storms in file
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
