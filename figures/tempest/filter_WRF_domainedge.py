from netCDF4 import Dataset, num2date, date2num
import numpy as np
import datetime as dt
import os
import pandas as pd

simulation_name = "SSP585_HOT_FAR"


#reading in the text file and the data
with open("trajectories.txt."+simulation_name+"_17min") as f, open("traj_temp.txt","w") as f_out:
        data = f.readlines()#read rest of data line by line and store in variable "data"
        line_count = 0
        for line in data:
                if "start" in line.split(): #if line is a header line, write it to intermediate output file
                        f_out.write(line)
                        f_out.write('\n')
                else:
                        count = 0
                        n0 = float(line.split()[0]) #domain indices of TC track point
                        n1 = float(line.split()[1])
                        if n0 != 0 and n0 != 423 and n1 != 0 and n1 != 298: #if this point is NOT on the domain edge, write to intermediate output file
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

#find new length of each TC track
lengths = list(np.diff(header_locs)-2)
lengths.append(line_count-header_locs[-1]-2)


count=0
#write final output file
with open("traj_temp.txt","r") as f, open("trajectories.txt."+simulation_name+"_17min_noedges","w") as f_out:
        line_count = 0
        data = f.readlines()#read rest of data line by line and store in variable "data"
        for line in data:
                if "start" in line.split():
                        split_line = line.split()
                        if lengths[count] > 1: #if new length of each TC track is greater than 1 point, write to new output file using new length in "lengths" list
                            split_line[1] = str(lengths[count])
                            line_joined = '\t'.join(split_line)
                            f_out.write(line_joined)
                            f_out.write('\n')
                            for j in range(2,lengths[count]+2):
                                f_out.write(data[line_count+j])
                        count+=1
                line_count += 1
