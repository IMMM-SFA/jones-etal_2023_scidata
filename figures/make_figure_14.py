import numpy as np
import matplotlib.pyplot as plt

#GCM warming data
# columns are 0) year 1) ERA5 CONUS mean temp 2) low-sensitivity SSP245 3) high-sensitivity SSP585 4) low-sensitivity SSP245 5) high-sensitivity SSP585
raw_data=np.genfromtxt('Raw_ERA5_GCM_data.csv', delimiter=',', dtype=float)
raw_data[0,0]=1980. #fix first value

#WRF TGW simulation data
#columns are 0) year 1) historical CONUS mean temp 2) low-sensitivity SSP245 CONUS mean temp 3) high-sensitivity SSP585 4) low-sensitivity SSP245 5) high-sensitivity SSP585
wrf_data=np.genfromtxt('Wrf_tas_timeseries.csv', delimiter=',', dtype=float)
wrf_data[0,0]=1980. #fix first value


#normalize by common baseline period 1980-1989
raw_base=np.average(raw_data[0:10,1:6], axis=0)
raw_data[:,1:6]=raw_data[:,1:6]-raw_base

wrf_base=np.average(wrf_data[0:10,1])
wrf_data[:,1:6]=wrf_data[:,1:6]-wrf_base


data=wrf_data

plt.subplot(2,2,1)
plt.plot(data[0:40,0],data[0:40,1],'g')
plt.plot(data[40:80,0],data[40:80,2],'g')
plt.plot(data[80:120,0],data[80:120,2],'g')
plt.plot(raw_data[:,0],raw_data[:,2],'m',linewidth=1)
plt.ylim([-1, 9])
plt.ylabel('Degrees C')
plt.title('a) Low-Sensitivity Models SSP245')

plt.subplot(2,2,2)
plt.plot(data[0:40,0],data[0:40,1],'g')
plt.plot(data[40:80,0],data[40:80,3],'g')
plt.plot(data[80:120,0],data[80:120,3],'g')
plt.plot(raw_data[:,0],raw_data[:,3],'m',linewidth=1)
plt.ylim([-1, 9])
plt.ylabel('Degrees C')
plt.title('b) High-Sensitivity Models SSP245')

plt.subplot(2,2,3)
plt.plot(data[0:40,0],data[0:40,1],'g')
plt.plot(data[40:80,0],data[40:80,4],'g')
plt.plot(data[80:120,0],data[80:120,4],'g')
plt.plot(raw_data[:,0],raw_data[:,4],'m', linewidth=1)
plt.ylim([-1, 9])
plt.ylabel('Degrees C')
plt.title('c) Low-Sensitivity Models SSP585')

plt.subplot(2,2,4)
plt.plot(data[0:40,0],data[0:40,1],'g')
plt.plot(data[40:80,0],data[40:80,5],'g')
plt.plot(data[80:120,0],data[80:120,5],'g')
plt.plot(raw_data[:,0],raw_data[:,5],'m', linewidth=1)
plt.ylim([-1, 9])
plt.ylabel('Degrees C')
plt.title('d) High-Sensitivity Models SSP585')

plt.show()

