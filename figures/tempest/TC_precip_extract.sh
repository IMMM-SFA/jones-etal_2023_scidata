#!/bin/bash -l

################################################################
#SBATCH -N 1                #Number of nodes
#SBATCH -t 01:00:00         #Time limit
#SBATCH -q regular          #Use the regular QOS
#SBATCH -L SCRATCH          #Job requires $SCRATCH file system
#SBATCH -C knl,quad,cache   #Use KNL nodes in quad cache format (default, recommended)
#SBATCH -o wrf_precip.out
#SBATCH -e wrf_precip.err
################################################################

############ USER OPTIONS #####################


## Unique string identifying name of model simulation
UQSTR=SSP585_HOT_FAR

## Path to TempestExtremes binaries
TEMPESTEXTREMESDIR=/global/homes/a/alyssas/tempestextremes_20211109_NFEhack/

#name of file that will contain TC tracks
TRAJFILENAME=trajectories.txt.${UQSTR}_17min_noedges

#Add names of WRF output files containing 6-hourly precipitation to text file
rm precip_file_list.txt
rm precip_output_files.txt
ls /global/project/projectdirs/m2637/TGW/CONUS_TGW_WRF_${UQSTR}/PRECT_6h/*.nc > precip_file_list.txt
PRECIPFILES=`ls /global/project/projectdirs/m2637/TGW/CONUS_TGW_WRF_${UQSTR}/PRECT_6h/*.nc`

#Create text file with desired names of output files that will contain TC-filtered precipitation
for g in $PRECIPFILES
do
  filename=${g}
  just_filename=`basename $g`
  echo "$SCRATCH/wrf_filtered/${UQSTR}/${just_filename}_5deg_filtered.nc" >> precip_output_files.txt
done


#extract TC precip using a set radius of 5 degrees around the TC center
srun -n 32 ${TEMPESTEXTREMESDIR}/bin/NodeFileFilter --in_nodefile ${TRAJFILENAME} --in_fmt "lon,lat,slp,wind" --in_data_list "precip_file_list.txt" --out_data_list "precip_output_files.txt" --bydist 5.0 --var "PRECT" --maskvar "mask" --latname "XLAT" --lonname "XLONG"

exit
