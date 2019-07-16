%% demo of learning based binary descriptor
% author: zhuo.su@oulu.fi
% date: 7.11.2018
%
% paras: parameters used in model and for feature extraction
%       paras.elbp_set --> a cell, every two means a certain type of raw
%       pdv extraction 
%           'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24]; -- concatenated LBP_S
%           with the form [lbp_type, radius, [q], bit]. In this case the
%           dimension of the concated LBP_S is 8 + 16 + 24 = 48
%           'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24];  --
%           concatenated ADLBP_S with the form [adlbp_type, radius, q,
%           bit]. . In this case the dimension of the concatenated ADLBP_S
%           is 48.
%           Similar to 'rd'.
%       paras.base_dir --> data dir to save experimental data, e.g., if
%       base dir is '/data', then '/data/pca/lbp_0/11/xxxxx-xxx.mat for
%       experiment configuration of {'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24]}
%       using pca, in the form of
%       /base_dir/method/descriptor_tpye/patch_size/date_info-xxx.mat,
%       would be the path to save the experimental data. 
%       paras.method --> 
%           lbp_riu2 / lbp_u2 -- model = lbp mapping table + dim
%           pca related -- model = projection matrix + codebook
%           cbfd related -- model = projection matrix + codebook
%           rp related -- model = projection matrix + codebook
%       paras.codesize --> number of bits in the projected discriptor space
%       paras.dicsize --> number of patterns of codebook 
%       paras.div --> divide each face image into subregoins, e.g., [8 x 8]
%       paras.binary --> whether the extracted raw pdv should be binary
%       paras.sort --> whether the extracted raw pdv be sorted
%       paras.preprocess --> to preprocess image before extracting raw pdv
%       paras.wpca_num --> number of eigenvectors left when applying wpca
%       on the concatenated histogram (feature of an image)
%       paras.date_info --> record the time of experiment 
%       paras.fuse_type --> features fusion method
%       paras.step --> sampling step in raw pdv extraction in sub regions
%       paras.kmeans_type --> euc: euclidean distance, hamming: hamming
%       distance
%       paras.lm_index --> landmark indices to extract landmark regions
%       paras.lm_radius --> radius of a landmark region


%% Init environment
clc;
close all;
clear variables

%% Set parameters
paras.div = [8, 8];
paras.binary = false;
paras.sort = false;
paras.preprocess = false;
paras.dicsize = 500;
paras.kmeans_type = 'hamming';
paras.codesize = 15;
paras.method = 'pca';
paras.wpca_num = 700;
paras.step = 1;
paras.elbp_set = {...
    'lbp', [0, 1, 8; 0, 3, 16; 0, 5, 24]; ...
    'lbp', [1, 1, 8; 1, 3, 16; 1, 5, 24]; ...
    'ad', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24]; ...
    'ad', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16; 1, 5, 1, 1, 24]; ...
    'rd', [0, 2, 1, 1, 8; 0, 3, 1, 1, 16; 0, 5, 1, 1, 24]; ...
    'rd', [1, 2, 1, 1, 8; 1, 3, 1, 1, 16; 1, 5, 1, 1, 24]...
    };
paras.date_info = datestr(now, 'dd-mmm-yyyy-HH-MM-SS-');
% paras.date_info = '10-Apr-2019-20-33-44-';
paras.base_dir = fullfile('exdata', 'lfw_view2');
paras.fuse_type = 'average';
paras.lm_index = [18, 22, 23, 27, 28, 30, 32, 34, 36, 37, 38, 40, 41, 43, 45, 46, 48, 49, 52, 55, 58] - 17;
paras.lm_radius = 12; % 25 x 25 patch, so that the lbp map is 15 x 15, for max_r = 5

tic;
parpool(8);
%% load dataset and get model (projection matrix and dictonary)
% for the cropped lfw dataset, please email to zhuo.su@oulu.fi at this moment. We will upload it later.
matname_landmark = 'lfw_dlib_lm_view2.mat';
load(fullfile('dataset', matname_landmark), 'lfw_dlib_lm_view2');
lfw_view2 = lfw_dlib_lm_view2(:, 1);
lfw_view2_lm = lfw_dlib_lm_view2(:, 2);

matname_division = 'lfw_dlib_view2.mat';
load(fullfile('dataset', matname_division), 'lfw_dlib_view2');
lfw_view2_divdata = lfw_dlib_view2(:, 1);
lfw_view2_name = lfw_dlib_view2(:, 3);

%% configure and run
num_subset = length(lfw_view2);
% since the number of images in train_data (8 * 4 * 300 = 9600) is too
% large, we randomly select num_train of images from them.
num_train = 2000;
[H, W, Num] = size(lfw_view2{1}{1});
[Hdiv, Wdiv, ~] = size(lfw_view2_divdata{1}{1});
num_lm = size(lfw_view2_lm{1}{1}, 1);
accuracy = zeros(num_subset, 1);
for i = 1: num_subset
    fprintf('processing the %d th test\n', i);
    %% get testing data
    index_test = i;   
    test_data_div = uint8(zeros(Hdiv, Wdiv, Num * 4));
    test_data = uint8(zeros(H, W, Num * 4));
    test_lm = uint32(zeros(num_lm, 2, Num * 4));
    for j = 1: 4
        test_data_div(:, :, (j - 1) * Num + 1: j * Num) = lfw_view2_divdata{index_test}{j};
        test_data(:, :, (j - 1) * Num + 1: j * Num) = lfw_view2{index_test}{j};
        test_lm(:, :, (j - 1) * Num + 1: j * Num) = lfw_view2_lm{index_test}{j};
    end
    test.data1 = test_data_div;
    test.data2 = test_data;
    test.lm = test_lm;
    test.unit_num = Num;
    
    %% get training data
    training_data_div = uint8(zeros(Hdiv, Wdiv, Num * 4 * (num_subset - 1)));
    training_data = uint8(zeros(H, W, Num * 4 * (num_subset - 1)));
    training_lm = uint32(zeros(num_lm, 2, Num * 4 * (num_subset - 1)));
    training_name = cell(Num * 4 * (num_subset - 1), 1);
    index = [1: i - 1, i + 1: num_subset];
    for j = 1: num_subset - 1
        for k = 1: 4
            ind_start = Num * 4 * (j - 1) + (k - 1) * Num;
            training_data_div(:, :, ind_start + 1: ind_start + Num) = lfw_view2_divdata{index(j)}{k};
            training_data(:, :, ind_start + 1: ind_start + Num) = lfw_view2{index(j)}{k};
            training_lm(:, :, ind_start + 1: ind_start + Num) = lfw_view2_lm{index(j)}{k};
            training_name(ind_start + 1: ind_start + Num) = lfw_view2_name{index(j)}{k};
        end
    end
    training.data1 = training_data_div;
    training.data2 = training_data;
    training.lm = training_lm;
    training.name = training_name;
    training.unit_num = Num;
    
    %% get model data
    [model_name, ind] = unique(training_name);
    model_data_div = training_data_div(:, :, ind);
    model_data = training_data(:, :, ind);
    model_lm = training_lm(:, :, ind);
    model_ind = randperm(length(model_name));
%     indfile = fullfile('dataset', sprintf('lfw_view2_model_ind_%02d.mat', i));
%     if ~exist(indfile, 'file')
%         model_ind = randperm(length(model_name));
%         save(indfile, 'model_ind');
%     else
%         load(indfile, 'model_ind');
%     end
    model_data_div = model_data_div(:, :, model_ind(1: num_train));
    model_data = model_data(:, :, model_ind(1: num_train));
    model_lm = model_lm(:, :, model_ind(1: num_train));
    modeldata.data1 = model_data_div;
    modeldata.data2 = model_data;
    modeldata.lm = model_lm;
    
    get_face_verification_accuracy(paras, training, test, modeldata);  
end

% for i = 1: 1 %num_subset
%     fprintf('%02d th acc: %f\n', i, accuracy(i));
% end

e = toc;
fprintf('eclapse time is %f\n', e);

delete(gcp);

