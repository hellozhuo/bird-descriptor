% author: zhuo.su@oulu.fi
% date: 28.3.2019
% function: get model for face identification or verification
% 
% [In]
% paras: parameters to train the model, specifically
%       paras.method --> 
%           pca related -- model = projection matrix + codebook
%           cbfd related -- model = projection matrix + codebook
%           rp related -- model = projection matrix + codebook
%           full -- model = dimension of raw pdv
%           kmeans -- model = codebook, no need of projection matrix
%       paras.codesize --> number of bits in the projected discriptor space
%       paras.dicsize --> number of patterns of codebook 
%
% image_data: dataset used to train the model, usually from a divided sub
% region, e.g., 21 x 21 x 1200 uint8 data, usually divided from
% get_face_model.m
%
% [Out]
% W: projection matrix to project original pdvs
%
% codebook: dictionary of patterns by kmeans

function [W, codebook, projected_pdv, dic_ids, objective] = get_face_model_sub(paras, image_data)

%% parameters for multi-core implementation
codesize = paras.codesize;
dicsize = paras.dicsize;
method = paras.method;

%% extracting raw pdv for matrix learning
num_image = size(image_data, 3);
pdv_tmp = get_concat_pdv(paras, image_data(:, :, 1)); % [] x pdv_dim
[num_points, pdv_dim] = size(pdv_tmp);

raw_pdv = zeros(num_points * num_image, pdv_dim);
raw_pdv(1: num_points, :) = pdv_tmp;
count = num_points;

for i = 2: num_image
    fprintf('Before W learning: extracting raw pdv for %d / %d th image in region %d\n',...
        i, num_image, paras.region_index)
    pdv_tmp = get_concat_pdv(paras, image_data(:, :, i));
    raw_pdv(count + 1: count + num_points, :) = pdv_tmp;
    count = count + num_points;
end

%% matrix learning
fprintf('learning projection matrix in region %d\n', paras.region_index);
if strcmp(method, 'cbfd') || strcmp(method, 'rp-cbfd')
    [W] = cbfd_learn(raw_pdv, codesize, 20, 0.001, 0.0001);
    objective = 0;
    % use the follwing function if objective is needed
    %[W, objective] = cbfd_learn_o(raw_pdv, codesize, 20, 0.001, 0.0001);
elseif strcmp(method, 'pca') || strcmp(method, 'rp-pca')
    W = pca_learn(raw_pdv, codesize);
elseif strcmp(method, 'rp')
    W = randn(pdv_dim, codesize);
elseif strcmp(method, 'kmeans')
    W = 1;
end

%% codebook learning
fprintf('learning codebook in region %d\n', paras.region_index);
if strcmp(paras.kmeans_type, 'hamming')
    projected_pdv = double(raw_pdv * W > 0);
    [dic_ids, codebook] = CalculateDictionary(projected_pdv, dicsize);
elseif strcmp(paras.kmeans_type, 'euc')
    projected_pdv = double(raw_pdv * W > 0);
    [dic_ids, codebook] = CalculateDictionary_Euc(projected_pdv, dicsize);
elseif strcmp(paras.kmeans_type, 'real-euc')
    projected_pdv = raw_pdv * W;
    [dic_ids, codebook] = CalculateDictionary_Euc(projected_pdv, dicsize);
end
    


