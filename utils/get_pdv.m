



function pdv = get_pdv(image_data, paras)
num_images = size(image_data, 3);
div1 = paras.div(1);
div2 = paras.div(2);
pdv = cell(div1 * div2, 1);
pdv_for_first_image = get_concat_pdv(image_data(:, :, 1), paras);
[num_points_per_region, pdv_dim] = size(pdv_for_first_image{1, 1});
for i = 1: paras.div(1)
    for j = 1: paras.div(2)
        pdv{(j - 1) * div1 + i} = zeros(num_points_per_region * num_images, pdv_dim);
    end
end
for i = 1: paras.div(1)
    for j = 1: paras.div(2)
        pdv{(j - 1) * div1 + i}(1: num_points_per_region, :) = pdv_for_first_image{i, j};
    end
end

count_points = num_points_per_region;
pdv_for_images = cell(num_images - 1, 1);
for index_image = 1: num_images - 1
    fprintf('extracting raw pdv step1 for %d / %d image\n', index_image, num_images);
    pdv_for_images{index_image} = get_concat_pdv(image_data(:, :, index_image), paras);
end
for index_image = 2: num_images
    fprintf('extracting raw pdv step2 for %d / %d image\n', index_image, num_images);
    for i = 1: paras.div(1)
        for j = 1: paras.div(2)
            pdv{(j - 1) * div1 + i}(count_points + 1: count_points + num_points_per_region, :) =...
                pdv_for_images{index_image - 1}{i, j};
        end
    end
    count_points = count_points + num_points_per_region;
end