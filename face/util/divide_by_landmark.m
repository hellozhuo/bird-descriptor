% author: zhuo.su@oulu.fi 
% date: 10.4.2019 
% function: preprocess each image and divide each of them into subregions
% 
% [In]
% image_data: images to be divided, e.g., 128 x 128 x 1200 uint8 data
% 
% preprocess: whether to be preprocessed 
% 
% lm: [lm_number, 2, N_image], locations of landmarks
% 
% radius: 2 x radius = the height or width of a landmark region
% 
% [Out]
% dataset: cell of size Number(=number of landmark regions) x 1, each of which is sub_height x sub_width x
% num data, e.g., for div = [8, 8], max_r = 3, image_data = 128 x 128 x
% 1200, then each cell in dataset is 21 x 21 x 1200 double (21 = floor(128
% - 2 x max_r) / 8) + 2 x max_r) 

function dataset = divide_by_landmark(image_data, preprocess, lm, radius)

[H, W, num] = size(image_data);
num_subregion = size(lm, 1);
dataset = cell(num_subregion, 1);

h = 1 + 2 * radius;
w = 1 + 2 * radius;
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
    big_img = zeros(H + 2 * radius, W + 2 * radius); % zeros paddings
    big_img(radius + 1: radius + H, radius + 1: radius + W) = image;
    for j = 1: num_subregion
        row_start = lm(j, 2, i) + 1; 
        row_start = min(row_start, H);
        row_end = row_start + h - 1;
        col_start = lm(j, 1, i) + 1;
        col_start = min(col_start, W);
        col_end = col_start + w - 1;
        dataset{j}(:, :, i) = big_img(row_start: row_end, col_start: col_end);
    end
end
