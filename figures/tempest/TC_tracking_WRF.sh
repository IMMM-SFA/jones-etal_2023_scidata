#!/bin/bash -l

################################################################
#SBATCH -N 1                #Number of nodes
#SBATCH -t 01:00:00         #Time limit
#SBATCH -q regular          #Use the regular QOS
#SBATCH -L SCRATCH          #Job requires $SCRATCH file system
#SBATCH -C knl,quad,cache   #Use KNL nodes in quad cache format (default, recommended)
#SBATCH -o wrf_tracking.out
#SBATCH -e wrf_tracking.err
################################################################

############ USER OPTIONS #####################


## Unique string identifying name of model simulation
UQSTR=SSP585_HOT_FAR

## Path to TempestExtremes binaries
TEMPESTEXTREMESDIR=/global/homes/a/alyssas/tempestextremes_20211109_NFEhack/

#name of file that will contain TC tracks
TRAJFILENAME=trajectories.txt.${UQSTR}

#Add names of WRF output files with data needed to track TCs to text file
rm tracking_files.txt
ls /global/project/projectdirs/m2637/TGW/CONUS_TGW_WRF_${UQSTR}/aux/*.nc > tracking_files.txt


#DetectNodes and Stitchnodes settings
DCU_PSLFOMAG=3.0
DCU_PSLFODIST=4.0
DCU_WCFOMAG=-10.0
DCU_WCFODIST=5.0
DCU_WCMAXOFFSET=0.25
DCU_MERGEDIST=5.0
SN_TRAMERRA2NGE=6.0
SN_TRAJMINTIME="24h"
SN_TRAJMAXGAP="6h"
SN_MINWIND=10.0
SN_MINLEN=2


mkdir -p DN_files
rm DN_files/out*

#Detect candiate cyclones
STRDETECT="--verbosity 0 --regional --timestride 2 --closedcontourcmd SLP,${DCU_PSLFOMAG},${DCU_PSLFODIST},0;_DIFF(Z300,Z500),${DCU_WCFOMAG},${DCU_WCFODIST},${DCU_WCMAXOFFSET} --mergedist ${DCU_MERGEDIST} --searchbymin SLP --outputcmd SLP,min,0;_VECMAG(U10,V10),max,2"
srun -n 32 ${TEMPESTEXTREMESDIR}/bin/DetectNodes --in_data_list "tracking_files.txt" --out "DN_files/out" --latname "XLAT" --lonname "XLONG" ${STRDETECT}

cat DN_files/out* > wrfout_d01_DN.txt

# Stitch candidate cyclones together
${TEMPESTEXTREMESDIR}/bin/StitchNodes --in_fmt "lon,lat,slp,wind" --range ${SN_TRAMERRA2NGE} --mintime ${SN_TRAJMINTIME} --maxgap ${SN_TRAJMAXGAP} --in wrfout_d01_DN.txt --out ${TRAJFILENAME} --threshold "wind,>=,${SN_MINWIND},${SN_MINLEN};lat,<=,35,first"

exit
