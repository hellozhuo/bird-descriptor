
% 13.2.2019

root = '/data2/dataset/curetgrey';
target_file = 'dataset/curet.mat';

if ~exist(root, 'dir')
    error('the dataset not exits')
end

num_total = 61 * 92;
h = 200;
w = 200;
curet = cell(61, 1);
for i = 1: 61
    curet{i}.data = zeros(h, w, 92);
    curet{i}.label = zeros(92, 1);
    dir_name = fullfile(root, sprintf('sample%d', i));
    info = dir(dir_name);
    num = length(info);
    assert(num == 92 + 2);
    for j = 3: num
        fprintf('processing %d th img in dir %d\n', j - 2, i);
        img_name = fullfile(dir_name, info(j).name);
        img = imread(img_name);
        [h_img, w_img, c] = size(img);
        assert(h_img == h && w_img == w && c == 1, 'the size of img is wrong\n');
        curet{i}.data(:, :, j - 2) = img;
        curet{i}.label(j - 2) = i;
    end
end
save(target_file, 'curet');
fprintf('finished\n');

        
