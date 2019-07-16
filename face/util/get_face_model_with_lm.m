% author: zhuo.su@oulu.fi
% date: 7.11.2018
% function: get a model struct for face verification
% 
% [In]
% paras: parameters to train the model, specifically
%       paras.method --> 
%           lbp_riu2 / lbp_u2 -- model = lbp mapping table + dim
%           pca related -- model = projection matrix + codebook
%           cbfd related -- model = projection matrix + codebook
%           rp related -- model = projection matrix + codebook
%       paras.codesize --> number of bits in the projected discriptor space
%       paras.dicsize --> number of patterns of codebook 
%       paras.div --> divide each face image into subregoins, e.g., [8 x 8]
%
% modeldata: data extracted from Training, used for training model,
%           | data1  128 x 128 x N uint8 | for regular regions
%           | data2  128 x 128 x N uint8 | for lanmark regions
%           | lm    52 x 2 x N uint32   | landmarks of data2
%
% [Out]
% model: abtained model structure
% 
% [Note]
% commented lines are for experiment analysis

function model = get_face_model_with_lm(paras, modeldata)

if ismember(paras.method, {'cbfd', 'pca', 'rp', 'kmeans'})
    fprintf('learning projection matrix and codebook for %s\n', paras.method);
    % do preprocessing and divide each of training images into sub regions
    division_dataset = divide_to_subregion(modeldata.data1, paras.preprocess,...
        paras.div, paras.max_r);
    landmark_dataset = divide_by_landmark(modeldata.data2, paras.preprocess,...
        modeldata.lm(paras.lm_index, :, :), paras.lm_radius);
    training_dataset = [division_dataset; landmark_dataset];
    clear divison_dataset landmark_dataset;
    
    % get models for each sub region 
    num_subregion = length(training_dataset);

    W = cell(num_subregion, 1);
    codebook = cell(num_subregion, 1);
    
    % for analysis only
%     projected_pdv = cell(num_subregion, 1);
%     dic_ids = cell(num_subregion, 1);
% %     objective = cell(num_subregion, 1); % for cbfd

    parfor i = 1: num_subregion
        this_paras = paras;
        this_paras.div = [1, 1];
        this_paras.region_index = i;
        [W{i}, codebook{i}] = get_face_model_sub(this_paras, training_dataset{i});
%         [W{i}, codebook{i}, projected_pdv{i}, dic_ids{i}] = get_face_model_sub(this_paras, training_dataset{i});
    end
    
%     meta_dir = fullfile(paras.data_dir, 'metafile', paras.date_info);
%     if ~exist(meta_dir, 'dir')
%         mkdir(meta_dir);
%     end
%     for i = 1: num_subregion
%         fprintf('writing for %d / %d th region\n', i, num_subregion);
%         meta_file = fullfile(meta_dir, sprintf('meta-%02d.mat', i));
%         pdv_region = projected_pdv{i};
%         dic_ids_region = dic_ids{i};
% %         objective_region = objective{i}; % for cbfd
%         save(meta_file, 'pdv_region', 'dic_ids_region');
%     end
    
%     delete(gcp('nocreate'));
%     error('enough\n');

    model.W = W;
    model.dictionary = codebook; 
elseif ismember(paras.method, {'lbp_riu2', 'lbp_u2'})
    fprintf('learning lbp mapping table for %s\n', paras.method);
    if isfield(paras, 'lbp')
        model.dictionary = get_lbpmap(paras.lbp(:, end), paras.method);
    elseif isfield(paras, 'rd')
        model.dictionary = get_lbpmap(paras.rd(:, end), paras.method);
    elseif isfield(paras, 'ad')
        model.dictionary = get_lbpmap(paras.ad(:, end), paras.method);
    end
    
%% for analysis only
%     training_dataset = divide_to_subregion(Training.data, paras.preprocess,...
%         paras.div, paras.max_r);
%     
%     num_subregion = paras.div(1) * paras.div(2);
%     dic_ids = cell(num_subregion, 1);
%     dictionary = model.dictionary;
% 
%     parfor i = 1: num_subregion
%         this_paras = paras;
%         this_paras.div = [1, 1];
%         this_paras.region_index = i;
%         [dic_ids{i}] = get_u2_indices(this_paras, training_dataset{i}, dictionary);
%     end
%     
%     meta_dir = fullfile(paras.data_dir, 'metafile', paras.date_info);
%     if ~exist(meta_dir, 'dir')
%         mkdir(meta_dir);
%     end
%     for i = 1: num_subregion
%         fprintf('writing for %d / %d th region\n', i, num_subregion);
%         meta_file = fullfile(meta_dir, sprintf('meta-%02d.mat', i));
%         dic_ids_region = dic_ids{i};
%         save(meta_file, 'dic_ids_region');
%     end
%     
%     delete(gcp('nocreate'));
%     error('enough\n');
elseif strcmp(paras.method, 'full')
    model = 'no model for full';   
end
    


