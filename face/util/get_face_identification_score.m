% author: zhuo.su@oulu.fi
% date 21.11.2018
% function: get identification scores between Gallery and Probe 
% 
% [In]
% paras: parameters for face identification
% 
% Gallery: structure with data and label, e.g., 
%           | data  128 x 128 x 1040 uint8 |
%           | label 1040 x 1 uint32        |
% 
% Probe: structure with data and label, e.g., 
%           | data  128 x 128 x 2285 uint8 |
%           | label 2285 x 1 uint32        |
% 
% Training: structure with data and label, e.g., 
%           | data  128 x 128 x 1200 uint8 | 
%           | lable 1200 x 1 uint32        |
%
% [Out]
% scores: the identification scores between Gallery and Probe

function scores = get_face_identification_score(paras, Gallery, Probe, Training)

%% get the max_r for the particular elbp
paras.max_r = get_max_radius(paras); 

%% Learn model from training set
model_name = fullfile(paras.data_dir, [paras.date_info, 'model.mat']);
if exist(model_name, 'file')
    fprintf('loading model from %s\n', model_name);
    load(model_name, 'model');
else
    model = get_face_model(paras, Training);
    save(model_name, 'model');
end  


%% Uncomment to extract and save features of Training set
% variance_dir = fullfile(paras.data_dir, 'variance');
% if ~exist(variance_dir, 'dir')
%     mkdir(variance_dir);
% end
% training_feature_file = fullfile(variance_dir, [paras.date_info, 'Training_feature.mat']);
% training_features = get_face_histogram_l1(paras, Training.data, model);
% fprintf('saving training features\n');
% save(training_feature_file, 'training_features');
% % delete(gcp('nocreate'));
% % error('done');

%% Extract features for Gallery and Probe
gallery_feature_file = fullfile(paras.data_dir, [paras.date_info, 'Gallery_feature.mat']);
if exist(gallery_feature_file, 'file')
    load(gallery_feature_file, 'gallery_features');
else
    gallery_features = get_face_histogram_l1(paras, Gallery.data, model); % num_image x feature_dim
    save(gallery_feature_file, 'gallery_features');
end

probe_feature_file = fullfile(paras.data_dir, [paras.date_info, paras.probe_name, '_feature.mat']);
if exist(probe_feature_file, 'file')
    load(probe_feature_file, 'probe_features');
else
    probe_features = get_face_histogram_l1(paras, Probe.data, model);
    save(probe_feature_file, 'probe_features');
end

[eigvec2,eigval,~,sampleMean] = PCA(gallery_features, paras.wpca_num);
eigvec = (bsxfun(@rdivide,eigvec2',sqrt(eigval))');
gallery_wpca = bsxfun(@minus, gallery_features, sampleMean)*eigvec;
probe_wpca = bsxfun(@minus, probe_features, sampleMean)*eigvec;
scores = pdist2(probe_wpca, gallery_wpca, 'cosine');



