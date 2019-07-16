% author: zhuo.su@oulu.fi
% date: 6.11.2018
% function: level 2, get the histograms for sub image regions
%
% [IN]
% paras: parameters used in model and for feature extraction
%
% image_data: sub images for which features are extracted, e.g., 21 x 21 x
% 2285 uint8 data, usually divided from get_concat_histogram.m
%
% model: trained model for feature extraction
%
% [OUT]
% features: each row represents a feature vector of an image subregion


function features = get_face_histogram_l2(paras, image_data, model)
    
num_image = size(image_data, 3);
feature_tmp = get_face_histogram_l3(paras, image_data(:, :, 1), model);

feature_length = length(feature_tmp);
features = zeros(num_image, feature_length);
features(1, :) = feature_tmp;

for i=2:num_image
    features(i, :) = get_face_histogram_l3(paras, image_data(:, :, i), model);
    fprintf('extracted pdv for img %d / %d in region %d\n',i, num_image, paras.region_index);
end

