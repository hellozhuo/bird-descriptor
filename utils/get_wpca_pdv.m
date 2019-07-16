

function wpca_pdv = get_wpca_pdv(image_data, part, paras)

div1 = paras.div(1);
div2 = paras.div(2);

num_image = size(image_data, 3);

wpca_pdv = cell(div1, div2, num_image);

for i = 1: num_image
    pdv = get_concat_pdv(image_data(:, :, i), paras);
    fprintf('extracting raw pdv step1 for %d / %d image in part %d\n', i, num_image, part);
    wpca_pdv(:, :, i) = pdv;
end
