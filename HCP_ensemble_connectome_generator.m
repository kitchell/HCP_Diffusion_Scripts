function HCP_ensemble_connectome_generator(subj,bvals)
% This function will combine all of the outputs from mrtrix tractography into singular .mat file.  This will be used
% in LiFE and AFQ steps. Function created by Franco Pestilli.
%
% Inputs are subject name, and b-values for study (see below for examples).
% Project directory will need to be ammended for your file set-up. 
%
% Output is a *_ensemble.mat file.
%
% % 2017 Brad Caron Indiana University, Pestilli Lab

% build paths; these will need to be inputted into function
% subjects for study
% subj = '1_5';

% b-values for study
% bvals = '1000'

% project directory for study
projdir1 = ['/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test/' subj];
mkdir(fullfile(projdir1, 'major_tracts'))
% Curvature paramater (lmax)
lmaxparam = {'2','4','6','8','10','12'};
% probability or deterministic tracking from mrtrix
streamprob = {'PROB','STREAM'};


% Tensor-based tracking. only on fascicles group
fe_path = fullfile(projdir1);
fg = fgRead(fullfile(fe_path,'tractography',sprintf('data_b%s_aligned_trilin_noMEC_wm_tensor-NUM01-500000.tck',bvals)));
%dt6File = fullfile(fe_path,'diffusion_data/dt6/dti90trilin/dt6.mat');
%fasciclesClassificationSaveName = fullfile(fe_path,'major_tracts', sprintf('data_b%_aligned_trilin_noMEC_wm_tensor-500000.mat',bvals));

% Subsample the fascicles 500,000 are too many (eliminate this step in the future by reducing the number of fascicles you 
% track, track 60,000 fascicles max for 13 tractography methods and 100,000x70 data points).
fgIdx = randsample(1:length(fg.fibers), 60000);
fg = fgExtract(fg,fgIdx,'keep');

% CSD-based tracking. Load one at the time.
for ilm = 1:length(lmaxparam)
    for isp = 1:length(streamprob)
        fe_path = fullfile(projdir1);
                fg_tmp = fgRead(fullfile(fe_path,'tractography',sprintf('data_b%s_aligned_trilin_noMEC_csd_lmax%s_wm_SD_%s-NUM01-500000.tck',bvals,lmaxparam{ilm},streamprob{isp})));
        fgIdx = randsample(1:length(fg_tmp.fibers),60000);
        fg_tmp = fgExtract(fg_tmp,fgIdx,'keep');

        % Merge the new fiber group with the original fiber group.
        fg = fgMerge(fg,fg_tmp);
        %clear fg_tmp
    end
end 
% Write fascicle group to disk.
fgFileName = fullfile(fe_path, 'major_tracts', sprintf('data_b%s_aligned_trilin_noMEC_ensemble.mat',bvals));
fgWrite(fg,fgFileName);

end