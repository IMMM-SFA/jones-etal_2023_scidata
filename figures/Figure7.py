import numpy as np
import netCDF4 as nc
import seaborn as sns
import matplotlib.pyplot as plt
import scipy
year     = np.arange(1980,2100)
cities   = ("Houston","StLouis","Seattle","LasVegas","NewYork","Miami")
fig, ax  = plt.subplots(6, 2, figsize=(30,28))
dir      = '~/data/'
for ci in np.arange(np.shape(cities)[0]):
    city = cities[ci]
    print(city)
    fpr  = nc.Dataset(f'{dir}precipitation_over_{city}.nc')
    prE  = np.asarray(fpr.variables['prE'])
    prW  = np.asarray(fpr.variables['prW'])
    prP  = np.asarray(fpr.variables['prP'])
    prE  = prE *1000

    ftmax = nc.Dataset(f'{dir}tmax_over_{city}.nc')
    tmaxE = np.asarray(ftmax.variables['tmaxE'])
    tmaxW = np.asarray(ftmax.variables['tmaxW'])
    tmaxP = np.asarray(ftmax.variables['tmaxP'])
    tmaxE = tmaxE-273.15
#Plotting
    sns.kdeplot(prP.flatten(),color='blue', ax=ax[ci,0],label="PRISM",legend=True)
    sns.kdeplot(prE.flatten(),color='black', ax=ax[ci,0],label="ERA5",legend=True)
    sns.kdeplot(prW.flatten(), color='red',ax=ax[ci,0],label="WRF",legend=True)
    sns.kdeplot(tmaxP.flatten(),color='blue', ax=ax[ci,1],label="PRISM",legend=True)
    sns.kdeplot(tmaxE.flatten(),color='black', ax=ax[ci,1],label="ERA5",legend=True)
    sns.kdeplot(tmaxW.flatten(), color='red',ax=ax[ci,1],label="WRF",legend=True)
    ax[ci,0].set_title(f'precipitation {city}')
    ax[ci,1].set_title(f'tmax {city}')
    ax[ci,0].set_xlim(0,85)
    ax[ci,0].set_ylim(0.0001,1)
    ax[ci,1].set_xlim(-20,50)
    ax[ci,0].legend()
    ax[ci,1].legend()
    ax[ci,0].set_yscale('log')
plt.savefig('Figure7.pdf')
