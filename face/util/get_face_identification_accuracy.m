% author: zhuo.su@oulu.fi
% date 21.11.2018
% function: get identification accuracy 
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
% accuracy: the identification accuracy

function accuracy = get_face_identification_accuracy(paras, Gallery, Probe, Training)

score_num = size(paras.elbp_set, 1);
Num_gallery = size(Gallery.data, 3);
Num_probe = size(Probe.data, 3);

scores = zeros(Num_probe, Num_gallery, score_num);

for i = 1: score_num
    fprintf('\n\nprocessing %d th feature\n', i); 
    
    elbp_type = sprintf('%s_%d', paras.elbp_set{i, 1}, paras.elbp_set{i, 2}(1));
    patch_size_str = num2str(max(paras.elbp_set{i, 2}(:, 2)) * 2 + 1, '%02d');
    
    this_paras = paras;
    this_paras.(paras.elbp_set{i, 1}) = paras.elbp_set{i, 2};
    
    % generate a data dir to save the specific experiment data, including
    % model, features
    data_dir = fullfile(paras.base_dir, paras.method, elbp_type, patch_size_str);
    if ~exist(data_dir, 'dir')
        mkdir(data_dir);
    end
    this_paras.data_dir = data_dir;
    
    scores(:, :, i) = get_face_identification_score(this_paras, Gallery, Probe, Training);
end

% In this case, the scores is in fact a distance matrix, so use min.
if strcmp(paras.fuse_type, 'average')
    scores_ave = mean(scores, 3);
    [~, min_ind] = min(scores_ave, [], 2);
    gnd_pred = uint32(zeros(size(Probe.label)));
    ntest = length(gnd_pred);
    labels = uint32(Gallery.label);
    for i = 1: ntest
        gnd_pred(i) = labels(min_ind(i));
    end

    accuracy = sum(gnd_pred==Probe.label)*100/ntest;
else
    accuracy = 0;
end

    







