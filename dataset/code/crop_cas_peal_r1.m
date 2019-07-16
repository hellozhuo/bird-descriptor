%% crop out face images from the cas_peal_r1 dataset
% author: zhuo.su@oulu.fi
% date: 26.10.2018
%%

dataset_dir = '/path/to/CAS_PEAL_R1';
% target = {'FRONTAL/Accessory', 'FRONTAL/Expression', 'FRONTAL/Lighting',...
%     'FRONTAL/Normal'}; %, 'FRONTAL/Background', 'FRONTAL/Distance'};
target = {'FRONTAL/Background', 'FRONTAL/Distance'};
dest_name = 'cropped_custome2';
dest_dir = fullfile(dataset_dir, dest_name);
if ~exist(dest_dir, 'dir')
    mkdir(dest_dir);
end

out_size = [128, 128];

%% cas_peal_r1_crop
dest.x1 = double(40);
dest.y1 = double(48);
dest.x2 = double(89);
dest.y2 = double(48);

for i = 1: length(target)
    target_dest_dir = fullfile(dest_dir, target{i});
    if ~exist(target_dest_dir, 'dir')
        mkdir(target_dest_dir);
    end    
    % crop faces for the target
    target_dir = fullfile(dataset_dir, target{i});
    note_file = fullfile(target_dir, 'FaceFP_2.txt');
    fileID = fopen(note_file, 'r');
    formatSpec = '%s %d %d %d %d';
    Info = textscan(fileID, formatSpec);
    fclose(fileID);
    file_number = length(Info{1});
    for j = 1: file_number
        fprintf('cropping %d / %d th image in %s\n', j, file_number, target{i});
        file_name = Info{1}{j};
        image = imread(fullfile(target_dir, strcat(file_name, '.tif')));
%         eyes_position = [Info{2}(j), Info{3}(j); Info{4}(j), Info{5}(j)];
        source.x1 = double(Info{2}(j));
        source.y1 = double(Info{3}(j));
        source.x2 = double(Info{4}(j));
        source.y2 = double(Info{5}(j));
        face = get_face_region(image, source, dest, out_size);
        face = uint8(face);
        save(fullfile(target_dest_dir, strcat(file_name, '.mat')), 'face');
%         imwrite(face, fullfile(target_dest_dir, strcat(file_name, '.bmp')));       
    end
end

