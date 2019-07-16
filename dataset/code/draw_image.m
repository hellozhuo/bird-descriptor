% date: 11.11.2018

% lfw = lfw_affine_view2(:, 1);
% landmark = lfw_affine_view2(:, 2);
% 
% n1 = 2;
% n2 = 1;
% n3 = 218;
% image = lfw{n1, 1}{n2, 1}(:, :, n3);
% image = repmat(image, 1, 1, 3);
% shape = landmark{n1, 1}{n2, 1}(:, :, n3);
% 
% n_lm = size(shape, 1);
% for i = 1: n_lm
%     image(shape(i, 2) + 1, shape(i, 1) + 1, :) = [255, 0, 0];
% end
% 
% imshow(image)

data = cas_peal_r1.Gallery.data;
landmark = cas_peal_r1.Gallery.lm;

n1 = 2;
n2 = 1;
n3 = 218;
image = data(:, :, n3);
image = repmat(image, 1, 1, 3);
shape = landmark(:, :, n3);

lm_index = [19, 21, 24, 26, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 29, 31, 32, 36, 50, 52, 54, 49, 55, 67, 59, 57];
lm_index = lm_index - 17;
fprintf('len: %d\n', length(lm_index));

n_lm = size(shape, 1);
for i = 1: length(lm_index)
    image(shape(lm_index(i), 2) + 1, shape(lm_index(i), 1) + 1, :) = [255, 0, 0];
end

imshow(image)
