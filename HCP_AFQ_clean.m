function HCP_AFQ_clean(subj)

projdir = '/N/dc2/projects/lifebid/wm_morphology/HCP_3T_test/';

load(fullfile(projdir, subj, '/major_tracts/life/postlife_afq_fg.mat'));

% cleans the fiber tracts with AFQ_removeFiberOutliers

maxDist = 4;

maxLen = 4;

numNodes = 30;

M = 'mean';

maxIter = 1;

count = true;


for ii = 1:20
    fg_clean(ii) = AFQ_removeFiberOutliers(fg_classified(ii), maxDist, maxLen, numNodes, M, count, maxIter);
end

save([projdir subj '/major_tracts/life/clean_postlife_afq_fg'], 'fg_clean');

end