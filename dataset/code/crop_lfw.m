%% crop out face images from the LFW dataset
% author: zhuo.su@oulu.fi
% date: 26.10.2018
%%

dataset_dir = '/home/zsu18/myprogram/dataset/LFW';
target = 'lfw-a';
dest_name = 'cropped_lu_lfw';
dest_dir = fullfile(dataset_dir, dest_name);
if ~exist(dest_dir, 'dir')
    mkdir(dest_dir);
end
eye_cor_file = fullfile(dataset_dir, 'lfw_eye_manual_by_ChihoChan.txt');
fileID = fopen(eye_cor_file, 'r');
formatSpec = '%s %f %f %f %f';
Info = textscan(fileID, formatSpec, 'headerlines', 3);
fclose(fileID);
file_number = length(Info{1});

target_dir = fullfile(dataset_dir, target);
target_dest_dir = fullfile(dest_dir, target);
if ~exist(target_dest_dir, 'dir')
    mkdir(target_dest_dir);
end
    
out_size = [128, 128];
dest.x1 = double(37);
dest.y1 = double(43);
dest.x2 = double(92);
dest.y2 = double(43);

source.x1 = double(104);
source.y1 = double(110);
source.x2 = double(148);
source.y2 = double(110);

transform = generateTransform(source,dest,0);
Info1 = Info{1};

for i = 1: file_number
    folder_file_name = Info1{i};
    folder_file = split(folder_file_name, '/');
    folder_name = folder_file{1};
    file_name = folder_file{2};
    fprintf('cropping %d / %d th image in %s\n', i, file_number, target);
    folder_dest_dir = fullfile(target_dest_dir, folder_name);
    if ~exist(folder_dest_dir, 'dir')
        mkdir(folder_dest_dir);
    end
    image = imread(fullfile(target_dir, folder_file_name));
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    face = get_face_region_with_transform(image, transform, out_size);
    face = uint8(face);
    save(fullfile(folder_dest_dir, replace(file_name, '.jpg', '.mat')), 'face');
    imwrite(face, fullfile(folder_dest_dir, replace(file_name, '.jpg', '.bmp')));
   
end

