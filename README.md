# HCP_Diffusion_Scripts
repository of scripts for processing the HCP data

After downloading and unzipping the preprocessed HCP data it should have a folder set up like this:

- subject_number:
  - release-notes
  - T1w
    * Diffusion
    * T1w_acpc_dc_restore_1.25.nii.gz

If it does not then you may need to edit the first script for the correct folder set up

For the HCP data it has already undergone the FSL preprocessing steps necessary. So the first step will be to align the T1 data to ACPC, split the shells, and run dtiInit. 

# 1. HCP_run_dtiInit
you can do ACPC alignment, shell splitting, and dtiInit via command line or in matlab
- command line: **HCP_run_dtiInit.sh**
  - this just runs the matlab script via command line
  - edit the script to have the correct file paths etc. then run by typing
  * ```./HCP_run_dtiInit.sh 'subjectnumber'```
- matlab: **HCP_run_dtiInit.m**

This requires the following arguments:
  - baseDir: string of the base directory for the subject folder
  - subj: string of the subject folder name/number
  - shell: shell you want to work on 
  - xflip: true/false if you want to flip the x bvecs (you want it to be true)

# 2. HCP_run_freesurfer.pbs
once the ACPC alignment happens you can send the T1 image to freesurfer
- qsub: **HCP_run_freesurfer.pbs**
  - edit the shell script to have the right subject number
  - type ```qsub HCP_run_freesurfer.pbs```
  
This will create a folder called freesurfer with all the freesurfer output in the anatomy folder of the subject
  
# 3. HCP_create_wm_mask.sh
This script will create the white matter mask needed for ensemble tractography. It calls a matlab script called HCP_fs_make_wm_mask.m. It will create a file called wm_mask.nii.gz in the anatomy folder of the subject.
- command line: **HCP_create_wm_mask.sh**
  - edit the script to have the correct file paths
  - it will take one input
    - subj: 'subjnum'
  - type ```./HCP_create_wm_mash.sh 'subjnum'```

# 4. HCP_run_ensemble.pbs
This script will send the script **HCP_mrtrix_ensemble.sh** to the queue on karst to perform ensemble tractography for a single subject
- command line: **HCP_run_ensemble.pbs**
  - edit the script to have the correct subject number
  - it will qsub **HCP_mrtrix_ensemble.sh**
    - edit that file to have the correct file paths if necessary
  - type ```qsub HCP_run_ensemble.pbs```

# 5. HCP_ensemble_connectome_generator.m
This script will combine the ensemble results into one connectome file
- matlab: **HCP_ensemble_connectome_generator.m**
  - edit to have the right folder paths
  - it will create a folder called major_tracts in the subject's folder
  - take the input of subj and bval shell
  - type ```HCP_ensemble_connectome_generator('1003007', '1000')```
  
# 6. HCP_life.m
This script will run life on the ensemble connectome file
- matlab: **HCP_life.m**
  - edit for file structure and bvals
  - takes the input of subj and bval shell (currently unused)
  - type ```HCP_life('subj', 'bval')```
  
# 7. HCP_AFQ_segmentation.m
This script will do the AFQ segmentation of major fiber tracts using the life connectome file
- matlab: **HCP_AFQ_segmentation.m**
  - edit for file structures and bvals
  - takes the input of subj name
  - type ```HCP_AFQ_segmentation('100307')```
  
# 8. HCP_AFQ_clean.m
This script will remove the outlying fibers from the AFQ segmentation
- matlab: **HCP_AFQ_clean.m**
  - edit for file paths if necessary
  - change params if necessary
  - takes the input of subj name
  - type ```HCP_AFQ_clean('100307')```
  
# 9. HCP_generate_tract_masks.m
This script will create binary volumes for all the AFQ segmented tracts.
- matlab: **HCP_generate_tract_masks.m**
  - edit for file paths if necessary
  - takes the input of subj, voxelResize, threshold, smoothBool
  - it will read the cleaned AFQ segmentation and the acpc T1 image
  - typical params are: voxelResize = .7, threshold = 2, smoothBool = 1
  - type ```HCP_generate_tract_masks('100307', .7, 2, 1)```
  
# 10. niftiMask2Surface.py
This script will create a surface file in the .ply format that will be usable for shapeDNA
It is a python function, so I still need to figure out how to run that on karst etc. 
