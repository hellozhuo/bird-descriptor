% author: zhuo.su@oulu.fi
% date: 6.11.2018
% function: level 1, get the concatenated histograms for the whole dataset
%
% [IN]
% paras: parameters used in model and for feature extraction
%
% image_data: training or test data,
%           | data1  128 x 128 x N uint8 | for regular regions
%           | data2  128 x 128 x N uint8 | for lanmark regions
%           | lm    52 x 2 x N uint32   | landmarks of data2
%
% model: trained model for feature extraction
%
% [OUT]
% f_division: each row represents a feature vector of an image, from
% regular regions
%
% f_landmark: each row represents a feature vector of an image, from
% landmark regions

function [f_division, f_landmark] = get_face_histogram_with_lm_l1(paras, image_data, model)
    
%% step1, do preprocessing and divide each of images into sub regions
division_dataset = divide_to_subregion(image_data.data1, paras.preprocess,...
    paras.div, paras.max_r);
landmark_dataset = divide_by_landmark(image_data.data2, paras.preprocess,...
    image_data.lm(paras.lm_index, :, :), paras.lm_radius);
region_dataset = [division_dataset; landmark_dataset];
num_division = length(division_dataset);
num_landmark = length(landmark_dataset);
clear divison_dataset landmark_dataset;

%% step2, calculate histograms for each sub region
num_subregion = length(region_dataset);
image_features = cell(num_subregion, 1);
parfor i = 1: num_subregion
    this_paras = paras;
    this_paras.div = [1, 1];
    this_paras.region_index = i;
    image_features{i} = get_face_histogram_l2(this_paras, region_dataset{i}, model);
end

%% step3, concatenate histograms of sub regions 
[num_images, dim] = size(image_features{1});

f_division = zeros(num_images, dim * num_division);
count = 0;
for i = 1: num_division
    fprintf('merging division features in %d / %d th regoin\n', i, num_subregion);
    f_division(:, count + 1: count + dim) = image_features{i};
    count = count + dim;
end

f_landmark = zeros(num_images, dim * num_landmark);
count = 0;
for i = num_division + 1: num_subregion
    fprintf('merging landmark features in %d / %d th regoin\n', i, num_subregion);
    f_landmark(:, count + 1: count + dim) = image_features{i};
    count = count + dim;
end

