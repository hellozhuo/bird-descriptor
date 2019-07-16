%% demo of learning-based binary descriptor
% author: zhuo.su@oulu.fi
% date: 7.11.2018
%
% paras: parameters used in model and feature extraction
%       paras.elbp_set --> a cell, every two elements in which mean a certain type of raw pdv extraction method, e.g.,
%           'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24] 
%               -- concatenated LBP_S with the form [lbp_type, radius, [q], bit]. In this case the dimension of the concated LBP_S is 8 + 16 + 24 = 48.
%           'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24] 
%               -- concatenated ADLBP_S with the form [adlbp_type, radius, q, bit]. In this case the dimension of the concatenated ADLBP_S is 48.
%           So does 'rd'.

%       paras.base_dir --> data dir to save experimental data, e.g., 
%           if base dir is '/data', then '/data/pca/lbp_0/11/xxxxx-xxx.mat' would be generated for configuration {'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24]} using pca to learn binary descriptor. More generally, the path of the generated .mat file is /base_dir/method/descriptor_tpye/patch_size/date_info-xxx.mat,

%       paras.method --> specify how to create feature descritor. Different methods would have different corresponding models, specifically,
%           method = lbp_riu2 / lbp_u2 -- model = lbp mapping table + dim (dimension)
%           method = pca  -- model = projection matrix + codebook
%           method = cbfd -- model = projection matrix + codebook
%           method = rp -- model = projection matrix + codebook
%           method = full -- model = dimension of raw pdv
%           method = kmeans -- model = codebook, no need of projection matrix

%       paras.codesize --> number of bits in the projected discriptor space
%       paras.dicsize --> number of patterns of codebook 
%       paras.div --> divide each face image into subregoins, e.g., [8 x 8]
%       paras.binary --> whether the extracted raw pdv should be binary
%       paras.sort --> whether the extracted raw pdv be sorted
%       paras.preprocess --> to preprocess image before extracting raw pdv
%       paras.wpca_num --> number of eigenvectors left when applying wpca on the concatenated histogram (feature of an image)
%       paras.date_info --> record the time of the experiment 
%       paras.fuse_type --> features fusion method, now we noly have "average"
%       paras.step --> sampling step in raw pdv extraction in sub regions
%       paras.kmeans_type --> euc: euclidean distance; hamming: hamming distance; real-euc: eculidean distance without binarizing the raw pdv

%% Init environment
clc;
close all;
clear variables

%% Set parameters
paras.div = [8, 8];
paras.binary = false;
paras.sort = false;
paras.preprocess = true;
paras.dicsize = 500;
paras.kmeans_type = 'hamming';
paras.codesize = 15;
paras.method = 'pca';
paras.wpca_num = 1039;
paras.step = 1;
paras.elbp_set = {...
% for full and lbp_u2
%     'lbp', [0, 1, 8; 0, 2, 8; 0, 3, 8; 0, 4, 8; 0, 5, 8]; ...
%     'lbp', [1, 1, 8; 1, 2, 8; 1, 3, 8; 1, 4, 8; 1, 5, 8]; ...
%     'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 8; 0, 4, 1, 1, 8; 0, 5, 1, 1, 8]; ...
%     'ad', [1, 2, 1, 1, 8; 1, 3, 1, 1, 8; 1, 4, 1, 1, 8; 1, 5, 1, 1, 8]; ...
%     'rd', [0, 2, 1, 1, 8; 0, 3, 1, 1, 8; 0, 4, 1, 1, 8; 0, 5, 1, 1, 8]; ...
%     'rd', [1, 2, 1, 1, 8; 1, 3, 1, 1, 8; 1, 4, 1, 1, 8; 1, 5, 1, 1, 8]...
% for other methods, e.g., pca, cbfd, rp, kmeans, ... 
% here we use all the 6 descriptors, feel free to use only one by commenting others
    'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24]; ...
    'lbp', [1, 1, 8; 1, 3, 16; 1, 5, 24]; ...
    'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24]; ...
    'ad', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16; 1, 5, 1, 1, 24]; ...
    'rd', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24]; ...
    'rd', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16; 1, 5, 1, 1, 24]...
% for pca patch size = 7x7
%     'lbp', [0, 1, 8; 0, 2, 8; 0, 3, 16]; ...
%     'lbp', [1, 1, 8; 1, 2, 8; 1, 3, 16]; ...
%     'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16]; ...
%     'ad', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16]; ...
%     'rd', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16]; ...
%     'rd', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16]...
    };
paras.date_info = datestr(now, 'dd-mmm-yyyy-HH-MM-SS-');
paras.base_dir = fullfile('exdata', 'cas_peal_r1_lighting');
paras.fuse_type = 'average';

tic;
parpool(6);
%% load dataset and get model (projection matrix and dictonary)
matname = 'cas_peal_r1_crop.mat';
load(fullfile('dataset', matname), 'cas_peal_r1');

% probe = {'ProbeSet_Expression', 'ProbeSet_Accessory'}; %, 'ProbeSet_Lighting'};
probe = {'ProbeSet_Lighting'};
acc = zeros(1, length(probe));
for i =1: length(probe)
    paras.probe_name = probe{i};
    acc(i) = get_face_identification_accuracy(paras, cas_peal_r1.Gallery, cas_peal_r1.(probe{i}), cas_peal_r1.Training_Set);
end

for i =1: length(probe)
    fprintf('\nRank-1 recognition rate for %s set:%2.2f\n',probe{i},acc(i));
end

e = toc;
fprintf('eclapse time is %f\n', e);

%% In conclusion (save infomation)
% In form of Info with fields: paras, dataset_info, results

% dateset_info
dataset_info.matname = matname;
dataset_info.probe = probe;

% results
results.accuracy = acc;

% write to Info
Info.paras = paras;
Info.dataset_info = dataset_info;
Info.results = results;

save_dir = fullfile(paras.base_dir, 'results');
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
file_name = fullfile(save_dir, [paras.date_info, matname]);
save(file_name, 'Info');
fprintf('saved results to %s\n', file_name);

delete(gcp);
