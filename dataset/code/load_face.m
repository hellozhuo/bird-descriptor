%% load face dataset to xx.mat
% author: zhuo.su@oulu.fi
% date: 4.11.2018
%
% [IN]
% dataset: dataset
%
%
% [OUT]
% path: path of mat file
%
%%

function dataset_path = load_face(dataset)

% load dataset cas_peal_r1
if strcmpi(dataset, 'cas_peal_r1')
    suffix = 'crop';
    dataset_path = ['dataset/cas_peal_r1_', suffix, '.mat'];
    if exist(dataset_path, 'file')
        load(dataset_path, 'cas_peal_r1');
    end
    image_dir = ['/home/zsu18/myprogram/dataset/CAS_PEAL_R1/cropped_', suffix];
%     target = {'/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/Gallery.txt', ...
%         '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Accessory.txt',...
%         '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Expression.txt',...
%         '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Lighting.txt'};

    target = {'/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/Training_Set.txt'};
    for i = 1:length(target)
        fileID = fopen(target{i}, 'r');
        files = textscan(fileID, '%s');
        fclose(fileID);
        files = files{:};
        num_file = length(files);
        if num_file < 1
            error('no image in this target foler: %s', target_dir);
        end
        load(replace(fullfile(image_dir, strcat(files{1}, '.mat')), '\', '/'), 'face');
        first_image = face;
%         first_image = imread(replace(fullfile(image_dir, strcat(files{1}, '.bmp')), '\', '/'));
        [rows, cols] = size(first_image);
        target_images = uint8(zeros(rows, cols, num_file));
        target_labels = uint32(zeros(num_file, 1));
        target_images(:, :, 1) = first_image;
        part = split(files{1}, '_');
        target_labels(1) = uint32(str2double(part{2}));
        for j = 2: num_file
            fprintf('loading %d / %d for target: %s\n', j, num_file, target{i});
            load(replace(fullfile(image_dir, strcat(files{j}, '.mat')), '\', '/'), 'face');
            target_images(:, :, j) = face;
%             target_images(:, :, j) = imread(replace(fullfile(image_dir, strcat(files{j}, '.bmp')), '\', '/'));
            part = split(files{j}, '_');
            target_labels(j) = uint32(str2double(part{2}));
        end
        [~, set_name] = fileparts(target{i});
        cas_peal_r1.(set_name).data = target_images;
        cas_peal_r1.(set_name).label = target_labels;
    end
    if exist(dataset_path, 'file')
        delete(dataset_path);
    end
    save(dataset_path, 'cas_peal_r1');
elseif strcmpi(dataset, 'cas_peal_r1_landmark')
    suffix = 'landmark';
    dataset_path = ['dataset/cas_peal_r1_', suffix, '.mat'];
    if exist(dataset_path, 'file')
        load(dataset_path, 'cas_peal_r1');
    end
    image_dir = ['/home/zsu18/myprogram/dataset/CAS_PEAL_R1/cropped/', suffix];
    target = {'/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/Gallery.txt', ...
        '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Accessory.txt',...
        '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Expression.txt',...
        '/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/ProbeSet_Lighting.txt'};
% %     , ...
%     target = {'/home/zsu18/myprogram/dataset/CAS_PEAL_R1/Evaluation Prototype/LiUsed/Training_Set.txt'};
    for i = 1:length(target)
        fileID = fopen(target{i}, 'r');
        files = textscan(fileID, '%s');
        fclose(fileID);
        files = files{:};
        num_file = length(files);
        if num_file < 1
            error('no image in this target foler: %s', target_dir);
        end
        format_landmark = '%d %d';
        N_landmark = 51;
        first_image = imread(replace(fullfile(image_dir, strcat(files{1}, '.jpg')), '\', '/'));
        [rows, cols] = size(first_image);
        target_images = uint8(zeros(rows, cols, num_file));
        target_labels = uint32(zeros(num_file, 1));
        target_lm = uint32(zeros(N_landmark, 2, num_file));
        target_images(:, :, 1) = first_image;
        part = split(files{1}, '_');
        target_labels(1) = uint32(str2double(part{2}));
        f_landmark = fopen(replace(fullfile(image_dir, strcat(files{1}, '.txt')), '\', '/'));
        info_landmark = textscan(f_landmark, format_landmark, N_landmark);
        fclose(f_landmark);
        target_lm(:, 1, 1) = info_landmark{1};
        target_lm(:, 2, 1) = info_landmark{2};
        for j = 2: num_file
            fprintf('loading %d / %d for target: %s\n', j, num_file, target{i});
            target_images(:, :, j) = imread(replace(fullfile(image_dir, strcat(files{j}, '.jpg')), '\', '/'));
            part = split(files{j}, '_');
            target_labels(j) = uint32(str2double(part{2}));
            f_landmark = fopen(replace(fullfile(image_dir, strcat(files{j}, '.txt')), '\', '/'));
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            target_lm(:, 1, j) = info_landmark{1};
            target_lm(:, 2, j) = info_landmark{2};
        end
        [~, set_name] = fileparts(target{i});
        cas_peal_r1.(set_name).data = target_images;
        cas_peal_r1.(set_name).label = target_labels;
        cas_peal_r1.(set_name).lm = target_lm;
    end
    if exist(dataset_path, 'file')
        delete(dataset_path);
    end
    save(dataset_path, 'cas_peal_r1');
elseif strcmpi(dataset, 'lfw-deepfunneled_view1')
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-deepfunneled';
    evafile_train = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairsDevTrain.txt';
    evafile_test = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairsDevTest.txt';
    
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';    
    target = {'train', 'test'};
    target_file = {evafile_train, evafile_test};
    
    for i = 1: 2
        fid = fopen(target_file{i});
        N = fgetl(fid);
        N = uint32(str2double(N));
        lfw_df_view1.(target{i}) = cell(4, 1);
        for j = 1: 4
            lfw_df_view1.(target{i}){j} = uint8(zeros(128, 128, N));
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in %s\n', j, N, target{i});
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(same1_name, 'face');
            lfw_df_view1.(target{i}){1}(:, :, j) = face;
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d'), '.mat']);
            load(same2_name, 'face');
            lfw_df_view1.(target{i}){2}(:, :, j) = face;
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in %s\n', j, N, target{i});
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(diff1_name, 'face');
            lfw_df_view1.(target{i}){3}(:, :, j) = face;
            
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d'), '.mat']);
            load(diff2_name, 'face');
            lfw_df_view1.(target{i}){4}(:, :, j) = face;
        end
    end
    fclose(fid);  
    matname = 'lfw_df_view1';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
    
elseif strcmpi(dataset, 'lfw-deepfunneled_view2')
    lfw_df_view2 = cell(10, 1);
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-deepfunneled';
    evafile = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairs.txt';
    fid = fopen(evafile);
    fgetl(fid);
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';
    N = 300;
    for i = 1: 10
        lfw_df_view2{i} = cell(4, 1);
        for j = 1: 4
            lfw_df_view2{i}{j} = uint8(zeros(128, 128, N));
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in subset %d\n', j, N, i);
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(same1_name, 'face');
            lfw_df_view2{i}{1}(:, :, j) = face;
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d'), '.mat']);
            load(same2_name, 'face');
            lfw_df_view2{i}{2}(:, :, j) = face;
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in subset %d\n', j, N, i);
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(diff1_name, 'face');
            lfw_df_view2{i}{3}(:, :, j) = face;
            
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d'), '.mat']);
            load(diff2_name, 'face');
            lfw_df_view2{i}{4}(:, :, j) = face;
        end
    end
    fclose(fid);  
    matname = 'lfw_df_view2';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
    
elseif strcmpi(dataset, 'lfw-a_view2')
    lfw_a_view2 = cell(10, 1);
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-a';
    evafile = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairs.txt';
    fid = fopen(evafile);
    fgetl(fid);
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';
    N = 300;
    for i = 1: 10
        lfw_a_view2{i} = cell(4, 1);
        for j = 1: 4
            lfw_a_view2{i}{j} = uint8(zeros(128, 128, N));
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in subset %d\n', j, N, i);
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(same1_name, 'face');
            lfw_a_view2{i}{1}(:, :, j) = face;
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d'), '.mat']);
            load(same2_name, 'face');
            lfw_a_view2{i}{2}(:, :, j) = face;
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in subset %d\n', j, N, i);
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d'), '.mat']);
            load(diff1_name, 'face');
            lfw_a_view2{i}{3}(:, :, j) = face;
            
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d'), '.mat']);
            load(diff2_name, 'face');
            lfw_a_view2{i}{4}(:, :, j) = face;
        end
    end
    fclose(fid);  
    matname = 'lfw_a_view2';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
elseif strcmpi(dataset, 'lfw-dlib_view2')
    lfw_dlib_view2 = cell(10, 3);
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-dlib';
    evafile = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairs.txt';
    format_landmark = '%d %d';
    N_landmark = 51;
    fid = fopen(evafile);
    fgetl(fid);
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';
    N = 300;
    for i = 1: 10
        lfw_dlib_view2{i, 1} = cell(4, 1);
        lfw_dlib_view2{i, 2} = cell(4, 1);
        lfw_dlib_view2{i, 3} = cell(4, 1);
        for j = 1: 4
            lfw_dlib_view2{i, 1}{j} = uint8(zeros(128, 128, N));
            lfw_dlib_view2{i, 2}{j} = uint32(zeros(51, 2, N));
            lfw_dlib_view2{i, 3}{j} = cell(N, 1);
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in subset %d\n', j, N, i);
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([same1_name, '.jpg']);
            lfw_dlib_view2{i, 1}{1}(:, :, j) = face;
            f_landmark = fopen([same1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_view2{i, 2}{1}(:, 1, j) = info_landmark{1};
            lfw_dlib_view2{i, 2}{1}(:, 2, j) = info_landmark{2};
            lfw_dlib_view2{i, 3}{1}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d')]);
            face = imread([same2_name, '.jpg']);
            lfw_dlib_view2{i, 1}{2}(:, :, j) = face;
            f_landmark = fopen([same2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_view2{i, 2}{2}(:, 1, j) = info_landmark{1};
            lfw_dlib_view2{i, 2}{2}(:, 2, j) = info_landmark{2};
            lfw_dlib_view2{i, 3}{2}{j} = [info{1}{j}, '_', num2str(info{3}(j), '%04d')];
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in subset %d\n', j, N, i);           
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([diff1_name, '.jpg']);
            lfw_dlib_view2{i, 1}{3}(:, :, j) = face;
            f_landmark = fopen([diff1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_view2{i, 2}{3}(:, 1, j) = info_landmark{1};
            lfw_dlib_view2{i, 2}{3}(:, 2, j) = info_landmark{2};
            lfw_dlib_view2{i, 3}{3}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
           
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d')]);
            face = imread([diff2_name, '.jpg']);
            lfw_dlib_view2{i, 1}{4}(:, :, j) = face;
            f_landmark = fopen([diff2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_view2{i, 2}{4}(:, 1, j) = info_landmark{1};
            lfw_dlib_view2{i, 2}{4}(:, 2, j) = info_landmark{2};
            lfw_dlib_view2{i, 3}{4}{j} = [info{3}{j}, '_', num2str(info{4}(j), '%04d')];
        end
    end
    fclose(fid);  
    matname = 'lfw_dlib_view2';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
elseif strcmpi(dataset, 'lfw-landmark_view2')
    lfw_dlib_lm_view2 = cell(10, 3);
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-landmark';
    evafile = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairs.txt';
    format_landmark = '%d %d';
    N_landmark = 51;
    fid = fopen(evafile);
    fgetl(fid);
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';
    N = 300;
    for i = 1: 10
        lfw_dlib_lm_view2{i, 1} = cell(4, 1);
        lfw_dlib_lm_view2{i, 2} = cell(4, 1);
        lfw_dlib_lm_view2{i, 3} = cell(4, 1);
        for j = 1: 4
            lfw_dlib_lm_view2{i, 1}{j} = uint8(zeros(128, 128, N));
            lfw_dlib_lm_view2{i, 2}{j} = uint32(zeros(51, 2, N));
            lfw_dlib_lm_view2{i, 3}{j} = cell(N, 1);
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in subset %d\n', j, N, i);
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([same1_name, '.jpg']);
            lfw_dlib_lm_view2{i, 1}{1}(:, :, j) = face;
            f_landmark = fopen([same1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_lm_view2{i, 2}{1}(:, 1, j) = info_landmark{1};
            lfw_dlib_lm_view2{i, 2}{1}(:, 2, j) = info_landmark{2};
            lfw_dlib_lm_view2{i, 3}{1}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d')]);
            face = imread([same2_name, '.jpg']);
            lfw_dlib_lm_view2{i, 1}{2}(:, :, j) = face;
            f_landmark = fopen([same2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_lm_view2{i, 2}{2}(:, 1, j) = info_landmark{1};
            lfw_dlib_lm_view2{i, 2}{2}(:, 2, j) = info_landmark{2};
            lfw_dlib_lm_view2{i, 3}{2}{j} = [info{1}{j}, '_', num2str(info{3}(j), '%04d')];
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in subset %d\n', j, N, i);           
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([diff1_name, '.jpg']);
            lfw_dlib_lm_view2{i, 1}{3}(:, :, j) = face;
            f_landmark = fopen([diff1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_lm_view2{i, 2}{3}(:, 1, j) = info_landmark{1};
            lfw_dlib_lm_view2{i, 2}{3}(:, 2, j) = info_landmark{2};
            lfw_dlib_lm_view2{i, 3}{3}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
           
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d')]);
            face = imread([diff2_name, '.jpg']);
            lfw_dlib_lm_view2{i, 1}{4}(:, :, j) = face;
            f_landmark = fopen([diff2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_dlib_lm_view2{i, 2}{4}(:, 1, j) = info_landmark{1};
            lfw_dlib_lm_view2{i, 2}{4}(:, 2, j) = info_landmark{2};
            lfw_dlib_lm_view2{i, 3}{4}{j} = [info{3}{j}, '_', num2str(info{4}(j), '%04d')];
        end
    end
    fclose(fid);  
    matname = 'lfw_dlib_lm_view2';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
elseif strcmpi(dataset, 'lfw-affine_view2')
    lfw_affine_view2 = cell(10, 3);
    image_dir = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/lfw-affine';
    evafile = '/home/zsu18/myprogram/dataset/LFW/cropped_lu_lfw/pairs.txt';
    format_landmark = '%d %d';
    N_landmark = 51;
    fid = fopen(evafile);
    fgetl(fid);
    format_same = '%s %d %d';
    format_diff = '%s %d %s %d';
    N = 300;
    for i = 1: 10
        lfw_affine_view2{i, 1} = cell(4, 1);
        lfw_affine_view2{i, 2} = cell(4, 1);
        lfw_affine_view2{i, 3} = cell(4, 1);
        for j = 1: 4
            lfw_affine_view2{i, 1}{j} = uint8(zeros(128, 128, N));
            lfw_affine_view2{i, 2}{j} = uint32(zeros(51, 2, N));
            lfw_affine_view2{i, 3}{j} = cell(N, 1);
        end
        % extract same pairs
        info = textscan(fid, format_same, N);
        for j = 1: N
            fprintf('processing %4d / %4d of same pairs in subset %d\n', j, N, i);
            same1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([same1_name, '.jpg']);
            lfw_affine_view2{i, 1}{1}(:, :, j) = face;
            f_landmark = fopen([same1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_affine_view2{i, 2}{1}(:, 1, j) = info_landmark{1};
            lfw_affine_view2{i, 2}{1}(:, 2, j) = info_landmark{2};
            lfw_affine_view2{i, 3}{1}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
            
            same2_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{3}(j), '%04d')]);
            face = imread([same2_name, '.jpg']);
            lfw_affine_view2{i, 1}{2}(:, :, j) = face;
            f_landmark = fopen([same2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_affine_view2{i, 2}{2}(:, 1, j) = info_landmark{1};
            lfw_affine_view2{i, 2}{2}(:, 2, j) = info_landmark{2};
            lfw_affine_view2{i, 3}{2}{j} = [info{1}{j}, '_', num2str(info{3}(j), '%04d')];
        end
        % extract diff pairs
        info = textscan(fid, format_diff, N);
        for j = 1: N
            fprintf('processing %4d / %4d of diff pairs in subset %d\n', j, N, i);           
            diff1_name = fullfile(image_dir, info{1}{j}, [info{1}{j}, '_', num2str(info{2}(j), '%04d')]);
            face = imread([diff1_name, '.jpg']);
            lfw_affine_view2{i, 1}{3}(:, :, j) = face;
            f_landmark = fopen([diff1_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_affine_view2{i, 2}{3}(:, 1, j) = info_landmark{1};
            lfw_affine_view2{i, 2}{3}(:, 2, j) = info_landmark{2};
            lfw_affine_view2{i, 3}{3}{j} = [info{1}{j}, '_', num2str(info{2}(j), '%04d')];
           
            diff2_name = fullfile(image_dir, info{3}{j}, [info{3}{j}, '_', num2str(info{4}(j), '%04d')]);
            face = imread([diff2_name, '.jpg']);
            lfw_affine_view2{i, 1}{4}(:, :, j) = face;
            f_landmark = fopen([diff2_name, '.txt']);
            info_landmark = textscan(f_landmark, format_landmark, N_landmark);
            fclose(f_landmark);
            lfw_affine_view2{i, 2}{4}(:, 1, j) = info_landmark{1};
            lfw_affine_view2{i, 2}{4}(:, 2, j) = info_landmark{2};
            lfw_affine_view2{i, 3}{4}{j} = [info{3}{j}, '_', num2str(info{4}(j), '%04d')];
        end
    end
    fclose(fid);  
    matname = 'lfw_affine_view2';
    mat_save_name = fullfile('dataset', [matname, '.mat']);
    if exist(mat_save_name, 'file')
        delete(mat_save_name);
    end
    save(mat_save_name, matname);
end

