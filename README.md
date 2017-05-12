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

# 1. HCP_run_dtiInit.m
you can do ACPC alignment, shell splitting, and dtiInit via command line or in matlab
- command line: **HCP_run_dtiInit.sh**
  - this just runs the matlab script via command line
  - edit the script to have the correct subj number and file paths then run by typing
  * ./HCP_run_dtiInit.sh
- matlab: **HCP_run_dtiInit.m**
This requires the following arguments:
  - baseDir: string of the base directory for the subject folder
  - subj: string of the subject folder name/number
  - shell: shell you want to work on 
  - xflip: true/false if you want to flip the x bvecs (you want it to be true)

# 2. Freesurfer
once the 
