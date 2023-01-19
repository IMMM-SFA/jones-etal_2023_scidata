from netCDF4 import Dataset, num2date, date2num
import numpy as np
import datetime as dt
import os

simulation_name = "SSP585_COLD_NEAR"

#reading in the text file and the data
with open("trajectories.txt."+simulation_name) as f, open("traj_temp.txt","w") as f_out:
        data = f.readlines()#read rest of data line by line and store in variable "data"
        line_count = 0
        for line in data:
                if "start" in line.split(): #if line is a header line, write to intermediate output file
                        f_out.write(line)
                        f_out.write('\n')
                else:
                        count = 0
                        if float(line.split()[5]) >= 17.: #if TC intensity at this time is greater or equal to 17 m/s, write line to intermediate output file
                                f_out.write(line)
                                count+=1
                line_count += 1



header_locs = []
with open("traj_temp.txt","r") as f:
        data = f.readlines()#read rest of data line by line and store in variable "data"
        line_count = 0
        for line in data:
                if "start" in line.split():
                        header_locs.append(line_count)#find locations of all lines that begin with "start"
                line_count += 1

#calculate new lengths of each TC track
lengths = list(np.diff(header_locs)-2)
lengths.append(line_count-header_locs[-1]-2)


count=0
#write final output file
with open("traj_temp.txt","r") as f, open("trajectories.txt."+simulation_name+"_17min","w") as f_out:
        line_count = 0
        data = f.readlines()#read rest of data line by line and store in variable "data"
        for line in data:
                if "start" in line.split():
                        split_line = line.split()
                        if lengths[count] > 1: #if new length of TC track is greater than 1, write track to final output file with new track length from "lengths" list
                            split_line[1] = str(lengths[count])
                            line_joined = '\t'.join(split_line)
                            f_out.write(line_joined)
                            f_out.write('\n')
                            for j in range(2,lengths[count]+2):
                                f_out.write(data[line_count+j])
                        count+=1
                line_count += 1
