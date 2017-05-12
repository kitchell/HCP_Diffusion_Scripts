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
