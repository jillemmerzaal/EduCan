#!/usr/bin/env python
# coding: utf-8

# In[2]:


from pygt3x.reader import FileReader
from pygt3x.calibration import CalibratedReader
import numpy as np
import logging


# In[3]:


def gt3x2df(dir_path, file):
    Input = file
    core = Input[:Input.find('.')]
    input_path = dir_path + Input
    
    with FileReader(input_path) as reader:
        calibrated_reader = CalibratedReader(reader)
        df = calibrated_reader.to_pandas()
        print(df.head())
    
    data = df.iloc[:,0:].values
    x = data[:,0]
    y = data[:,1]
    z = data[:,2]
    
    
    # return the non-wear_time using hees' function
    hz = 30 
    min_non_wear_time_window = 30
    window_overlap = 15
    std_mg_threshold = 3.0
    std_min_num_axes = 2
    value_range_mg_threshold = 50.0
    value_range_min_num_axes = 2
    
    # number of data samples in 1 minute
    num_samples_per_min = hz * 60

    # define the correct number of samples for the window and window overlap
    min_non_wear_time_window *= num_samples_per_min
    window_overlap *= num_samples_per_min


    # convert the standard deviation threshold from mg to g
    std_mg_threshold /= 1000

    # convert the value range threshold from mg to g
    value_range_mg_threshold /= 1000

    # new array to record non-wear time. Convention is 0 = non-wear time, and 1 = wear time. Since we create a new array filled with ones, we only have to 
    # deal with non-wear time (0), since everything else is already encoded as wear-time (1)
    non_wear_vector = np.ones((data.shape[0], 1), dtype = 'uint8')


    # loop over the data, start from the beginning with a step size of window overlap
    for i in range(0, len(data), window_overlap):


        # define the start of the sequence
        start = i

        # define the end of the sequence
        end = i + min_non_wear_time_window

        # slice the data from start to end
        subset_data = data[start:end]

        # check if the data sequence has been exhausted, meaning that there are no full windows left in the data sequence (this happens at the end of the sequence)
        # comment out if you want to use all the data
        if len(subset_data) < min_non_wear_time_window:
            break


        # calculate the standard deviation of each column (YXZ)
        std = np.std(subset_data, axis=0)

        # check if the standard deviation is below the threshold, and if the number of axes the standard deviation is below equals the std_min_num_axes threshold

        if (std < std_mg_threshold).sum() >= std_min_num_axes:
            # at least 'std_min_num_axes' are below the standard deviation threshold of 'std_min_num_axes', now set this subset of the data to 0 which will 
            # record it as non-wear time. Note that the full 'new_wear_vector' is pre-populated with all ones, so we only have to set the non-wear time to zero
            non_wear_vector[start:end] = 0

            
        # calculate the value range (difference between the min and max) (here the point-to-point numpy method is used) for each column
        value_range = np.ptp(subset_data, axis = 0)
        # check if the value range, for at least 'value_range_min_num_axes' (e.g. 2) out of three axes, was less than 'value_range_mg_threshold' (e.g. 50) mg
        if (value_range < value_range_mg_threshold).sum() >= value_range_min_num_axes:
            # set the non wear vector to non-wear time for the start to end slice of the data
            # Note that the full array starts with all ones, we only have to set the non-wear time to zero
            non_wear_vector[start:end] = 0
   
    return [data, x, y, z, non_wear_vector]

