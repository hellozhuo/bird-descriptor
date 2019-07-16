function [dic_ids, dictionary] = CalculateDictionary(feature,dictionarySize)
%% k-means

fprintf('Building Dictionary\n\n');

reduce_flag = 1;
ndata_max = 200000;   % use 4% avalible memory if its greater than the default

ndata = size(feature,1);

if (reduce_flag > 0) && (ndata > ndata_max)
    fprintf('Number of points: %d\n', ndata);
%     if ~exist(dic_file, 'file')
%         p = randperm(ndata, ndata_max);
%         save(dic_file, 'p');
%     else
%         load(dic_file, 'p');
%     end
    p = randperm(ndata, ndata_max);
    fprintf('Reducing to %d descriptors\n', ndata_max);
    feature = feature(p, :);
end


%% perform clustering
% options = zeros(1,14);
% options(1) = 1; % display
% options(2) = 1;
% options(3) = 0.001; % precision  0.1
% options(5) = 1; %centers initialize
% centers = zeros(dictionarySize, size(feature,2));
% 
% options(14) = 200; % maximum iterations

%% run kmeans
fprintf('\nRunning k-means\n');

% dictionary = sp_kmeans(centers, feature, options);
[dic_ids, dictionary] = kmeans(feature, dictionarySize, 'Distance', 'hamming'); % num_clusters x dim

%%