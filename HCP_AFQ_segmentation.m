function HCP_AFQ_segmentation(subj)
% This function will run Automated Fiber Quantification (Yeatman et al, 2014; https://github.com/yeatmanlab/AFQ). It will take
% the LiFE-evaluated ensemble connectome and segment streamlines into 20 major fiber tracts.
%
% Input is subject name.
%
% Output is a post_life_afq_fg.mat file that will contain fg, fg_classified, classification, and fascicles structures.  Fg_classified
% holds the major tracts, and will be used to generate tract profiles.
%

% AFQ
% These file structures will need to be changed for your file set-up.
projdir = '/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test/';
dtFile = [projdir subj '/diffusion_data/dt6/dti90trilin/dt6.mat'];
% wholeBrainConnectome = [projdir subj '/major_tracts/data_b1000_aligned_trilin_noMEC_ensemble.mat'];
wholeBrainConnectome = [projdir subj '/major_tracts/life/optimized_life_connectome_1.mat'];
[fg_classified, ~, class] = AFQ_SegmentFiberGroups(dtFile, wholeBrainConnectome);
save([projdir subj '/major_tracts/life/postlife_afq_fg'], 'fg_classified', 'class', '-v7.3');
end