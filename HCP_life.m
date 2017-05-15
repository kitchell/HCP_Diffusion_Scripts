function HCP_life(subj, bvals)
% LiFE function (Pestilli et al, 2014, Nature Methods).  This will evaluate ensemble connectome generated from 
% ensemble_connectome_generator.m (github.com/brain-life/pestillilab-projects/Concussion/zero7_ensemble_connectome_generator.m).
% It will fit the LiFE model, determine which fascicles do not contribute positvely to overall diffusion signal, and remove
% those fascicles from the connectome.
% 
% Inputs are subject name, and a cacheDir for output logs
%
% Output will be a .mat file called 'optimized_life_connectome_1'. This will then be used in AFQ.
%
% 2017 Brad Caron Indiana University, Pestilli Lab

% edit these for your file structure
projdir = '/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test/';
anatomyFile = [projdir subj '/anatomy/T1w_acpc_dc_restore_1p25_AUTO.nii.gz'];
feFileName = 'data_b1000_aligned_trilin_noMEC_ensemble_FE';
dwiFile = [projdir subj '/diffusion_data/dt6/data_b1000_aligned_trilin_noMEC.nii.gz'];
fgFileName = fullfile(projdir, subj, '/major_tracts/', 'data_b1000_aligned_trilin_noMEC_ensemble.mat');
%fe_path = [projdir subj 'major_tracts'];
dwiFileRepeated = [];
savedir = [projdir subj '/major_tracts/life'];

% Build the life model into an fe structure
L = 360; % Discretization parameter
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,savedir,dwiFileRepeated,anatomyFile,L,[1,0]);

% Fit the model.
Niter = 500;
fit = feFitModel(feGet(fe,'model'),feGet(fe,'dsigdemeaned'),'bbnnls',Niter,'preconditioner');

% Install the fit to the FE structure
fe = feSet(fe,'fit',fit);

% Save the life model to disk; again, edit for your file structure
save([projdir subj '/major_tracts/life/optimized_life_1'], 'fe', '-v7.3');

% Extract the fascicles with positive weight
w  = feGet(fe,'fiber weights'); % Collect the weights associated with each fiber
fg = feGet(fe,'fibers acpc');
fg = fgExtract(fg, w > 0);
% edit for your file structure
save([projdir subj '/major_tracts/life/optimized_life_connectome_1'], 'fg', '-v7.3');

end