% 17.2.2019
function preload(data_name, image_data, paras)

tic;
paras.max_r = get_max_radius(paras); 

num = size(image_data, 3);

pdv_of_first_image = get_concat_pdv(image_data(:, :, 1), paras);
[num_points, dim] = size(pdv_of_first_image);

data1 = zeros(dim, num_points, num);
data1(:, :, 1) = pdv_of_first_image';

for i = 2: num
    fprintf('preloading for %d / %d th image\n', i, num);
    pdv = get_concat_pdv(image_data(:, :, i), paras);
    data1(:, :, i) = pdv';
end
e1 = toc;
fprintf('e1: %f\n', e1);
tic

load(data_name, 'data');
e2 = toc;
fprintf('e2: %f\n', e2);
% clear data;
    