# EduCan

Calcualting functional activities of the upper limb in real life is a challange. Recently [Lum et al., (2022)](https://pubmed.ncbi.nlm.nih.gov/33150830/) developed a machine learning pipeline to seperate functional from non-functional arm activities in healthy participants and on the non-affected side of stroke patients. We tested this model and found that, while it was not yet perfect, it was better than the previously used activity counts threshold method. 
Therefore, this code will implement the model developed by Lum et al., and tested by Vets et al, on women pre- and post-breast cancer treatment to gain insigt into their arm use in daily life.

### Steps to take before you run this code

1. have matlab installed
2. have the respository downloaded
3. configure your system to use Python
4. this includes setting Python to environment variables in windows system path
5. have the python modules installed

>  **Note** 
> To call Python® modules in MATLAB®, you must have a supported version of the reference implementation (CPython) installed on your system. 
> This code is created using MATLAB 2022b and Python 3.9 in [Anaconda Distribution](https://www.anaconda.com/products/distribution)
> for other versions of either MATLAB or Python check the [version compatibility](https://nl.mathworks.com/support/requirements/python-compatibility.html)


### What does the code do? 

**Data segmentating steps:**

1. read the native actigraph data usting the pygt3x module in python (implemented in MATLAB).
2. calculate wear/non-wear time  based on the hip accelerometer.
    - code from [Syed et al., 2020](https://www.nature.com/articles/s41598-020-62821-2), who implemented [van Hees' Algorithm 1993](https://pubmed.ncbi.nlm.nih.gov/21829556/) using raw acceleration data. We used a non-wear time of 135 minutes and a sliding window of 1 minute, as shown by [Syed et al (2022)](https://www.nature.com/articles/s41598-021-87757-z) to have a high f1-score without needing to resort to deep learning. 
3. if there is at least 5 days and 12 hour per day/block of wear time, than the pre-processing steps start. 

**pre-processing steps:**

1. refedine axis definition to match those of [Lum et al., (2020)](https://journals.sagepub.com/doi/full/10.1177/1545968320962483)
2. resample data from 30Hz to 50Hz
3. calulate features

**processing**

1. use the pretrained model to predict functional (label 1) and non-functional (label 0) activities of the upper limb
2. calculate the minutes functional active per wear block. 
3. Calulcate the percentage of minutes functional active with respect to the total wear time
4. export all outcome to excel

### How to run the code

###### .gt3x files
First, read the native acigraph files in using ```workflow_gt3x.m```. 
```
open workflow_gt3x.m
```
This will write the raw acceleration data, the sample frenquency, and acceleration scale to a .parq file. 
When data extraction is completed, **restart matlab** before you run ```workflow_fa.m``` to segmente the wear blocks, prepare the data for the pretrained model, calculate the minutes of functional activity per limb in absolute values and as a percentage of total wear time.
```
open workflow_fa.m
```
The restart after the gt3x workflow is nescesary because of the change in python environment. The requirement.txt is for the workflow_fa.m code.

###### csv files
If the workflow_gt3x fails you can also use .csv files extracted from the actigraph software. The naming of the files should be the same as for the .parq files: **rawdata_hip.csv** | **rawdata_left.csv** | **rawdata_right.csv**
change the folowing code from 'parq' to 'csv'
```
import_ext = 'csv'
```
specify the subjects for which you want to use the csv files. Make sure that the data is in subject paths.



