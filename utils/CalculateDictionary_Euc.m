function [dic_ids, dictionary] = CalculateDictionary_Euc(raw_feature,dictionarySize)
%% k-means

reduce_flag = 1;
ndata_max = 100000;   % use 4% avalible memory if its greater than the default

ndata = size(raw_feature,1);

if (reduce_flag > 0) && (ndata > ndata_max)
    fprintf('Number of points: %d\n', ndata);
    p = randperm(ndata, ndata_max);
    fprintf('Reducing to %d descriptors\n', ndata_max);
    feature = raw_feature(p, :);
end


%% perform clustering
options = zeros(1,14);
options(1) = 1; % display
options(2) = 1;
options(3) = 0.001; % precision  0.1
options(5) = 1; %centers initialize
centers = zeros(dictionarySize, size(feature,2));

options(14) = 200; % maximum iterations

%% run kmeans
fprintf('\nRunning k-means\n');

dictionary = sp_kmeans(centers, feature, options); % num_clusters x dim

fprintf('calculating dic indices\n');
dist_mat = sp_dist2(raw_feature, dictionary);
[~, dic_ids] = min(dist_mat, [], 2);
%%