% author: zhuo.su@oulu.fi
% date: 6.11.2018
% function: level 1, get the concatenated histograms for the whole dataset
%
% [IN]
% paras: parameters used in model and for feature extraction
%
% image_data: images for which features are extracted, e.g., 128 x 128 x
% 2285 uint8 data
%
% model: trained model for feature extraction
%
% [OUT]
% features: each row represents a feature vector of an image


function features = get_face_histogram_l1(paras, image_data, model)
    
%% step1, do preprocessing and divide each of images into sub regions
image_dataset = divide_to_subregion(image_data, paras.preprocess,...
    paras.div, paras.max_r);

%% step2, calculate histograms for each sub region
num_subregion = paras.div(1) * paras.div(2);
image_features = cell(num_subregion, 1);
parfor i = 1: num_subregion
    this_paras = paras;
    this_paras.div = [1, 1];
    this_paras.region_index = i;
    image_features{i} = get_face_histogram_l2(this_paras, image_dataset{i}, model);
end

%% step3, concatenate histograms of sub regions 
[num_images, dim] = size(image_features{1});
features = zeros(num_images, dim * num_subregion);
count = 0;
for i = 1: num_subregion
    fprintf('merging features in %d / %d th regoin\n', i, num_subregion);
    features(:, count + 1: count + dim) = image_features{i};
    count = count + dim;
end

