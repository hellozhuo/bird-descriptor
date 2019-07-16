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
% accuracy: the verification accuracy

function get_face_verification_accuracy(paras, Training, Test, modeldata)

score_num = size(paras.elbp_set, 1);
% n_train = size(Training.data, 3);
% train_score = zeros(n_train / 2, score_num);
% n_test = size(Test.data, 3);
% test_score = zeros(n_test / 2, score_num);

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
    
    get_face_verification_score(this_paras, Training, Test, modeldata);
end

% In this case, the scores is in fact a distance matrix, so use min.
% if strcmp(paras.fuse_type, 'average')
%     scores_ave = mean(scores, 3);
%     [~, min_ind] = min(scores_ave, [], 2);
%     gnd_pred = uint32(zeros(size(Probe.label)));
%     ntest = length(gnd_pred);
%     labels = uint32(Gallery.label);
%     for i = 1: ntest
%         gnd_pred(i) = labels(min_ind(i));
%     end
% 
%     accuracy = sum(gnd_pred==Probe.label)*100/ntest;
% else
%     accuracy = 0;
% end

    







