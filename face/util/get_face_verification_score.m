% author: zhuo.su@oulu.fi
% date 21.11.2018
% function: get identification accuracy 
% 
% [In]
% paras: parameters for face verification
% 
% Training: training data, with fields, 
%           | data1  128 x 128 x N uint8 | for regular regions
%           | data2  128 x 128 x N uint8 | for lanmark regions
%           | lm    52 x 2 x N uint32   | landmarks of data2
%           | name  N x 1 cell          |
%           | unit_num --> N = num_subset x 4 x unit_num for lfw_v2 | 
% 
% Test: testing data, with fileds, 
%           | data1  128 x 128 x N uint8 | for regular regions
%           | data2  128 x 128 x N uint8 | for lanmark regions
%           | lm    52 x 2 x N uint32   | landmarks of data2
%           | unit_num                    |
% 
% modeldata: data extracted from Training, used for training model,
%           | data1  128 x 128 x N uint8 | for regular regions
%           | data2  128 x 128 x N uint8 | for lanmark regions
%           | lm    52 x 2 x N uint32   | landmarks of data2
%
% [Out]
% train_score, test_score: the verification scores of training pairs and test pairs

function get_face_verification_score(paras, Training, Test, modeldata)

%% get the max_r for the particular elbp
paras.max_r = get_max_radius(paras); 

%% Learn model from training set
model_name = fullfile(paras.data_dir, [paras.date_info, 'model.mat']);
if exist(model_name, 'file')
    fprintf('loading model from %s\n', model_name);
    load(model_name, 'model');
else
    model = get_face_model_with_lm(paras, modeldata);
    save(model_name, 'model');
end  

%% Extract features for training and test data
[training_f_div, training_f_lm] = get_face_histogram_with_lm_l1(paras, Training, model); % num_image x feature_dim
[N, ~] = size(training_f_div);
npart = 10;
n = N / npart;
for i = 1: npart
    training_f_div_part = training_f_div((i - 1) * n + 1: i * n, :);
    filename = fullfile(paras.data_dir, sprintf('%straining_f_div_part%02d.mat', paras.date_info, i));
    save(filename, 'training_f_div_part');
end

[N, ~] = size(training_f_lm);
npart = 10;
n = N / npart;
for i = 1: npart
    training_f_lm_part = training_f_lm((i - 1) * n + 1: i * n, :);
    filename = fullfile(paras.data_dir, sprintf('%straining_f_lm_part%02d.mat', paras.date_info, i));
    save(filename, 'training_f_lm_part');
end

[test_f_div, test_f_lm] = get_face_histogram_with_lm_l1(paras, Test, model);
[N, ~] = size(test_f_div);
npart = 10;
n = N / npart;
for i = 1: npart
    test_f_div_part = test_f_div((i - 1) * n + 1: i * n, :);
    filename = fullfile(paras.data_dir, sprintf('%stest_f_div_part%02d.mat', paras.date_info, i));
    save(filename, 'test_f_div_part');
end

[N, ~] = size(test_f_lm);
npart = 10;
n = N / npart;
for i = 1: npart
    test_f_lm_part = test_f_lm((i - 1) * n + 1: i * n, :);
    filename = fullfile(paras.data_dir, sprintf('%stest_f_lm_part%02d.mat', paras.date_info, i));
    save(filename, 'test_f_lm_part');
end

%% get scores
% [eigvec2,eigval,~,sampleMean] = PCA(gallery_features, paras.wpca_num);
% eigvec = (bsxfun(@rdivide,eigvec2',sqrt(eigval))');
% gallery_wpca = bsxfun(@minus, gallery_features, sampleMean)*eigvec;
% probe_wpca = bsxfun(@minus, probe_features, sampleMean)*eigvec;
% scores = pdist2(probe_wpca, gallery_wpca, 'cosine');



