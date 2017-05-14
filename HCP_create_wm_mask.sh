#!/bin/bash

##Script for creating a white matter mask based on freesurfer output. This script will call a matlab function called
## HCP_fs_make_wm_mask. Written by Lindsey Kitchell (IU graduate student 2017)

#subj folder name
subj=$1
datadir="/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test"

##load freesurfer
module unload freesurfer/5.3.0
module load freesurfer/6.0.0


#setup freesurfer
export SUBJECTS_DIR=$datadir/$subj/anatomy
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR/freesurfer/mri

#convert file types
mri_convert aparc+aseg.mgz aparc+aseg.nii.gz

cp $SUBJECTS_DIR/freesurfer/mri/aparc+aseg.nii.gz $datadir/$subj/anatomy

#move to the data directory
cd $datadir

module load matlab

matlab -nodesktop -nodisplay -nosplash -r "HCP_fs_make_wm_mask('$subj')";
exit


