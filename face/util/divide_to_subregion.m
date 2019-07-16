% author: zhuo.su@oulu.fi 
% date: 28.3.2019 
% function: preprocess each image and divide each of them into subregions
% 
% [In]
% image_data: images to be divided, e.g., 128 x 128 x 1200 uint8 data
% 
% preprocess: whether to be preprocessed 
% 
% div: [M, N], to divide each image into M x N sub regions
% 
% max_r: add bias for each sub region for extracting completed pdvs without
% missng information on the borders
% 
% [Out]
% dataset: cell of size Number(=M x N) x 1, each of which is sub_height x sub_width x
% num data, e.g., for div = [8, 8], max_r = 3, image_data = 128 x 128 x
% 1200, then each cell in dataset is 21 x 21 x 1200 double (21 = floor(128
% - 2 x max_r) / 8) + 2 x max_r) 

function dataset = divide_to_subregion(image_data, preprocess, div, max_r)

[H, W, num] = size(image_data);
num_subregion = div(1) * div(2);
dataset = cell(num_subregion, 1);

row_step = floor((H - 2 * max_r) / div(1));
col_step = floor((W - 2 * max_r) / div(2));
h = row_step + 2 * max_r;
w = col_step + 2 * max_r;
for i = 1: num_subregion
    dataset{i} = zeros(h, w, num);
end

for i = 1: num
    fprintf('dividing %d / %d th image\n', i, num);
    if preprocess
        image = preproc2(double(image_data(:, :, i)),0.2,1,2,[],[],10);
    else
        image = double(image_data(:, :, i));
    end
    for j = 1: div(1)
        row_start = row_step * (j - 1) + 1;
        row_end = row_start + row_step + 2 * max_r - 1;
        for k = 1: div(2)
            index = (j - 1) * div(2) + k;
            col_start = col_step * (k - 1) + 1;
            col_end = col_start + col_step + 2 * max_r - 1;
            sub_image = image(row_start: row_end, col_start: col_end);
            dataset{index}(:, :, i) = sub_image;
        end
    end
end

