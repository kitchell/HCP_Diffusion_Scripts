#!/bin/bash 


## shell script to run the matlab script HCP_run_dtiInit.m 
## for a single subject
## Developed by Lindsey Kitchell (IU Grad Student 2017)
## ./HCP_run_dtiInit.sh '100307'

## set up variable
baseDir='/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test/'
subj=$1
shell=1000
xflip=true

## make sure matlab is loaded
module load matlab
module load spm/8


## run matlab script

matlab -nodesktop -nodisplay -nosplash -r "HCP_run_dtiInit('$baseDir','$subj', $shell, $xflip)" 