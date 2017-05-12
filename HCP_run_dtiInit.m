function HCP_run_dtiInit(baseDir, subj, shell, xflip)
% Sets up the directories for a single HCP subject, flips the bvecs around 
% the x-axis, splits the data into the three shells, sets the parameters 
% for dtiInit, runs dtiInit. Also renames the T1 nifti to remove the . in
% the name.
%
% This assumes you have downloaded the 'Diffusion Preprocessed' data from
% HCP website and have unzipped the folder.
% 
% HCP_run_dtiInit(baseDir, subj, shell, xflip)
%
%
% Inupts:
% baseDir = base directory where the subjects are
% ex: paths.dirs.base = '/N/dc2/projects/lifebid/wm_morphology/pipelinetest/';
% 
% subj - a string containg the subjects folder name
%
% shell - shell to be analyzed, [1000, 2000, or 3000]
%
% xflip - boolean input (true or false), indicates whether you want the
% bvecs to be flipped around the x-axis. Default is true. 

if ~exist('xflip', 'var') || isempty(xflip)
    xflip = true;
end

restoredefaultpath
addpath(genpath('/N/dc2/projects/lifebid/code/kitchell'))
addpath(genpath('/N/dc2/projects/lifebid/code/franpest/AFQ'))
addpath(genpath('/N/dc2/projects/lifebid/code/franpest/encode'))
addpath(genpath('/N/dc2/projects/lifebid/code/vistasoft'))

% Prepare data paths and paths
paths.dirs.subj        = subj;
%paths.dirs.base        = '/N/dc2/projects/lifebid/wm_morphology/pipelinetest/';
paths.dirs.base = baseDir;
paths.dirs.in_original_hcp_anat  = 'T1w';
paths.dirs.in_original_hcp_dwi   = 'Diffusion';
paths.dirs.out_data    = 'diffusion_data';
paths.dirs.out_backup  = 'original_hcp_data';
paths.dirs.out_anatomy = 'anatomy';
paths.dirs.out_tractography      = 'tractography';
paths.dirs.out_dt                = 'dt6';

paths.file.names.dwi     = 'data.nii.gz';
paths.file.names.anatomy = 'T1w_acpc_dc_restore_1p25.nii.gz';
paths.file.names.bvecs   = 'data.bvecs';
paths.file.names.bvals   = 'data.bvals';
paths.file.names.params  = 'params';
paths.file.names.normalization = 'bvals_bvecs_normalization.mat';

paths.file.dwi  = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.in_original_hcp_dwi,  paths.file.names.dwi);
paths.file.bvec = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.in_original_hcp_dwi, paths.file.names.bvecs);
paths.file.bval = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.in_original_hcp_dwi,  paths.file.names.bvals);
paths.file.t1f  = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.in_original_hcp_anat, paths.file.names.anatomy);

% Parameters used for normalization
params.single_shells       = [0,1000,2000,3000];
params.thresholds.b0_normalize    = 200;
params.thresholds.bvals_normalize = 100;
params.flip_x = xflip;

%% Organize folders
cd(fullfile(paths.dirs.base,paths.dirs.subj))

eval(sprintf('!mv -v %s %s', fullfile(paths.dirs.in_original_hcp_anat, paths.dirs.in_original_hcp_dwi), ...
                                      paths.dirs.in_original_hcp_dwi));
    

eval(sprintf('!mkdir -v %s',paths.dirs.out_backup))
eval(sprintf('!mv -v %s %s',paths.dirs.in_original_hcp_anat, ...
                            paths.dirs.out_backup));%T1w original_hcp_data/
eval(sprintf('!mkdir -v %s',paths.dirs.out_anatomy));% anatomy
eval(sprintf('!cp -v %s/*nii.gz %s',fullfile(paths.dirs.out_backup,paths.dirs.in_original_hcp_anat),  ...
                                             paths.dirs.out_anatomy)); %original_hcp_data/T1w/*nii.gz* anatomy/
eval(sprintf('!mv -v %s %s', fullfile(paths.dirs.out_anatomy, 'T1w_acpc_dc_restore_1.25.nii.gz'), ...
                                      fullfile(paths.dirs.out_anatomy, paths.file.names.anatomy)));%remove . from anatomy name
eval(sprintf('!mkdir -v %s',paths.dirs.out_data));%diffusion_data
eval(sprintf('!mv -v %s %s',paths.dirs.in_original_hcp_dwi, ...
                            paths.dirs.out_backup));% Diffusion_7T original_hcp_data/
eval(sprintf('!cp -v %s/* %s',fullfile(paths.dirs.out_backup, ...
                                     paths.dirs.in_original_hcp_dwi), ...
                                     paths.dirs.out_data));% original_hcp_data/Diffusion_7T/* diffusion_data/
eval(sprintf('!mkdir -v %s',paths.dirs.out_tractography));% fibers
if exist('release-notes','file')
   eval(sprintf('!mv -v %s %s','release-notes', ...
        paths.dirs.out_backup)); % release-notes original_hcp_data/
end

cd(paths.dirs.out_data);% diffusion_data
eval(sprintf('!mv -v bvecs %s',paths.file.names.bvecs));% fibers
eval(sprintf('!mv -v bvals %s',paths.file.names.bvals));% fibers

%% Normalize HCP files to the VISTASOFT environment
%
% Split data into three separate paths (BVALS = 1000, 2000 and 3000).
bvals.val = dlmread(paths.file.names.bvals);

% Round the numbers to the closest thousand 
% This is necessary because the VISTASOFT software does not handle the B0
% when they are not rounded.
[bvals.unique, ~, bvals.uindex] = unique(bvals.val);
if ~isequal(bvals.unique, params.single_shells)
    bvals.unique(bvals.unique <= params.thresholds.b0_normalize) = 0;
    bvals.unique  = round(bvals.unique./params.thresholds.bvals_normalize) ...
        *params.thresholds.bvals_normalize;
    bvals.valnorm = bvals.unique( bvals.uindex );
    dlmwrite(paths.file.names.bvals,bvals.valnorm);
    save(paths.file.names.normalization,'bvals')
else
    bvals.valnorm = bvals.val;
end

index1000 = (bvals.valnorm == params.single_shells(2));
index2000 = (bvals.valnorm == params.single_shells(3));
index3000 = (bvals.valnorm == params.single_shells(4));
index0    = (bvals.valnorm == params.single_shells(1));

% Find all indices to each bvalue and B0
all_1000  = or(index1000,index0);
all_2000  = or(index2000,index0);
all_3000  = or(index2000,index0);

% Validate that we selected the correct number of bvals+b0
assertEqual(sum(all_1000), sum(index0)+sum(index1000))
assertEqual(sum(all_2000), sum(index0)+sum(index2000))
assertEqual(sum(all_3000), sum(index0)+sum(index3000))

% Write bvals to disk
bvals1000 = bvals.valnorm(all_1000);
dlmwrite('data_b1000.bvals',bvals1000);

bvals2000 = bvals.valnorm(all_2000);
dlmwrite('data_b2000.bvals',bvals2000);

bvals3000 = bvals.valnorm(all_3000);
dlmwrite('data_b3000.bvals', bvals3000);

% Work on BVECS
bvecs1000 = dlmread('data.bvecs');
if ~(size(bvecs1000,1) == 3), bvecs1000 = bvecs1000'; end
bvecs1000 = bvecs1000(:,all_1000);
if params.flip_x
   bvecs1000(1,:) = -bvecs1000(1,:);
end
dlmwrite('data_b1000.bvecs',bvecs1000);

bvecs2000 = dlmread('data.bvecs');
if ~(size(bvecs2000,1) == 3), bvecs2000 = bvecs2000'; end
bvecs2000 = bvecs2000(:,all_2000);
if params.flip_x
   bvecs2000(1,:) = -bvecs2000(1,:);
end
dlmwrite('data_b2000.bvecs',bvecs2000);

bvecs3000 = dlmread('data.bvecs');
if ~(size(bvecs3000,1) == 3), bvecs3000 = bvecs3000'; end
bvecs3000 = bvecs3000(:,all_3000);
if params.flip_x
   bvecs3000(1,:) = -bvecs3000(1,:);
end
dlmwrite('data_b3000.bvecs',bvecs3000);

% Split the data into single shells
dwi   = niftiRead('data.nii.gz');
dwi1000 = dwi;
dwi1000.fname = 'data_b1000.nii.gz';

dwi2000 = dwi;
dwi2000.fname = 'data_b2000.nii.gz';

dwi3000 = dwi;
dwi3000.fname = 'data_b3000.nii.gz';

% Remove the other bval data to make a b-val = 1000/2000/3000 dataset
dwi1000.data   = dwi.data(:,:,:,all_1000);
dwi1000.dim(4) = size(dwi1000.data,4);
niftiWrite(dwi1000);

dwi2000.data   = dwi2000.data(:,:,:,all_2000);
dwi2000.dim(4) = size(dwi2000.data,4);
niftiWrite(dwi2000);

dwi3000.data  = dwi3000.data(:,:,:,all_3000);
dwi3000.dim(4) = size(dwi3000.data,4);
niftiWrite(dwi3000);

%% AC-PC align
%!module load spm/8

% Make sure the file is aligned properly
ni_anat_file = fullfile(paths.dirs.base, paths.dirs.subj, ...
                        paths.dirs.out_anatomy, ...
                        paths.file.names.anatomy);

ni_anat = niftiRead( ni_anat_file );
ni_anat = niftiApplyCannonicalXform( ni_anat );                   
                    

% Load a standard template from vistasoft
MNI_template =  fullfile(mrDiffusionDir, 'templates', 'MNI_T1.nii.gz');

% Compute the spatial normalization to align the current raw data to the template
SpatialNormalization = mrAnatComputeSpmSpatialNorm(ni_anat.data, ni_anat.qto_xyz, MNI_template);

% Assume that the AC-PC coordinates in the template are in a specific location:
% X, Y, Z = [0,0,0; 0,-16,0; 0,-8,40]
% Use this assumption and the spatial normalization to extract the corresponding AC-PC location on the raw data
coords = [0,0,0; 0,-16,0; 0,-8,40];

ImageCoords = mrAnatGetImageCoordsFromSn(SpatialNormalization, tal2mni(coords)', true)';

% Now we assume that ImageCoords contains the AC-PC coordinates that we need for the Raw data. 
% We will use them to compute the AC_PC alignement automatically. The new file will be saved to disk. 
% Check the alignement.
mrAnatAverageAcpcNifti(ni_anat, ...
    fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_anatomy, 'T1w_acpc_dc_restore_1p25_AUTO.nii.gz'), ...
    ImageCoords, [], [], [], false);



%% DTIINIT

% get image dimensions
dwi = niftiRead('data.nii.gz');
res = dwi.pixdim(1:3);
clear dwi

% create output directory
mkdir(paths.dirs.out_dt);

% create parameters
dwParams = dtiInitParams;
dwParams.eddyCorrect       = -1;
dwParams.phaseEncodeDir    = 2; 
dwParams.rotateBvecsWithRx = 0;
dwParams.rotateBvecsWithCanXform = 0;
dwParams.dwOutMm = res;
dwParams.outDir    = paths.dirs.out_dt;

switch shell
    case 1000
        dwParams.bvecsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b1000.bvecs');
        dwParams.bvalsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b1000.bvals');

        % run dtiInit
        dt_path = dtiInit(fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b1000.nii.gz'), ...
                  fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_anatomy, 'T1w_acpc_dc_restore_1p25_AUTO.nii.gz'), dwParams);
    case 2000
        dwParams.bvecsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b2000.bvecs');
        dwParams.bvalsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b2000.bvals');

        % run dtiInit
        dt_path = dtiInit(fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b2000.nii.gz'), ...
                  fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_anatomy, 'T1w_acpc_dc_restore_1p25_AUTO.nii.gz'), dwParams);
    case 3000 
        dwParams.bvecsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b3000.bvecs');
        dwParams.bvalsFile = fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b3000.bvals');

        % run dtiInit
        dt_path = dtiInit(fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_data, 'data_b3000.nii.gz'), ...
                  fullfile(paths.dirs.base, paths.dirs.subj, paths.dirs.out_anatomy, 'T1w_acpc_dc_restore_1p25_AUTO.nii.gz'), dwParams);
end

%% Create an MRTRIX .b file from the bvals/bvecs of the shell chosen to run

bvecs = fullfile(paths.dirs.base, paths.dirs.subj, 'diffusion_data/dt6/', sprintf('data_b%i_aligned_trilin_noMEC.bvecs', shell));
bvals = fullfile(paths.dirs.base, paths.dirs.subj, 'diffusion_data/dt6/', sprintf('data_b%i_aligned_trilin_noMEC.bvals', shell));
out   = fullfile(paths.dirs.base, paths.dirs.subj, 'tractography',         sprintf('data_b%i.b', shell));
mrtrix_bfileFromBvecs(bvecs, bvals, out);


exit;



% AFQ
% dt = dtiLoadDt6(fullfile(paths.dirs.base,paths.dirs.subj, 'diffusion_data/dt6/dti90trilin/dt6.mat'));
% 
% fg = AFQ_WholebrainTractography(dt,['test']);
% [fg_classified,~,classification,fg]= AFQ_SegmentFiberGroups(dt, fg, [], [], false);
% fascicles = fg2Array(fg_classified)


