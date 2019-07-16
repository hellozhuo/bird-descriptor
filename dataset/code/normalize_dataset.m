% zhuo.su@oulu.fi
% 26.2.2019
% % Normalize dataset to zero-mean and unit varaiance

% dataset: cell(num_class, 1), each element in cell has data and label
function dataset = normalize_dataset(dataset)

for i = 1: length(dataset)
    num_img = size(dataset{i}.data, 3);
    for j = 1: num_img
        fprintf('normalize %d / %d th image in class %d\n', j, num_img, i);
        img = dataset{i}.data(:, :, j);
        dataset{i}.data(:, :, j) = samp_prepro(img);
    end
end