clear;

%% CK+, FERA2011, and UNBC datasets
hog_dir = 'D:\Datasets/face_datasets/hog_aligned_rigid/';
hog_files = dir([hog_dir, '*.hog']);

[appearance_data, valid_inds, vid_ids_train] = Read_HOG_files_small(hog_files, hog_dir);
appearance_data = appearance_data(valid_inds,:);
vid_ids_train = vid_ids_train(valid_inds,:);

%% Bosphorus dataset
hog_dir = 'D:\Datasets/face_datasets/hog_aligned_rigid_b/';
hog_files = dir([hog_dir, '*.hog']);

[appearance_data_bosph, valid_inds, vid_ids_train_bosph] = Read_HOG_files_small(hog_files, hog_dir);

appearance_data_bosph = appearance_data_bosph(valid_inds,:);
vid_ids_train_bosph = vid_ids_train_bosph(valid_inds,:);

appearance_data = cat(1,appearance_data, appearance_data_bosph);
vid_ids_train = cat(1,vid_ids_train, vid_ids_train_bosph);

%% DISFA
hog_dir = 'D:\Datasets\DISFA\hog_aligned_rigid/';
hog_files = dir([hog_dir, '*.hog']);

[appearance_data_disfa, valid_inds, vid_ids_train_disfa] = Read_HOG_files_small(hog_files, hog_dir, 100);

appearance_data_disfa = appearance_data_disfa(valid_inds,:);
vid_ids_train_disfa = vid_ids_train_disfa(valid_inds,:);

appearance_data = cat(1,appearance_data, appearance_data_disfa);
vid_ids_train = cat(1,vid_ids_train, vid_ids_train_disfa);

%% BP4D
hog_dir = 'D:\Datasets\FERA_2015\bp4d\processed_data/train/';
hog_files = dir([hog_dir, '*.hog']);

[appearance_data_bp, valid_inds, vid_ids_train_bp] = Read_HOG_files_small(hog_files, hog_dir, 50);

appearance_data_bp = appearance_data_bp(valid_inds,:);
vid_ids_train_bp = vid_ids_train_bp(valid_inds,:);

appearance_data = cat(1,appearance_data, appearance_data_bp);
vid_ids_train = cat(1,vid_ids_train, vid_ids_train_bp);

%% SEMAINE
hog_dir = 'D:\Datasets\FERA_2015\semaine\processed_data\train\';
hog_files = dir([hog_dir, '*.hog']);

[appearance_data_semaine, valid_inds, vid_ids_train_semaine] = Read_HOG_files_small(hog_files, hog_dir, 300);

appearance_data_semaine = appearance_data_semaine(valid_inds,:);
vid_ids_train_semaine = vid_ids_train_semaine(valid_inds,:);

appearance_data = cat(1,appearance_data, appearance_data_semaine);
vid_ids_train = cat(1,vid_ids_train, vid_ids_train_semaine);

%%
means_norm = mean(appearance_data);
stds_norm = std(appearance_data);

normed_data = bsxfun(@times, bsxfun(@plus, appearance_data, -means_norm), 1./stds_norm);

%% Creating a generic model
[PC, score, eigen_vals] = princomp(normed_data, 'econ');

% Keep 95 percent of variability
total_sum = sum(eigen_vals);
count = numel(eigen_vals);
for i=1:numel(eigen_vals)
   if ((sum(eigen_vals(1:i)) / total_sum) >= 0.95)
      count = i;
      break;
   end
end

PC = PC(:,1:count);

save('generic_face_rigid.mat', 'PC', 'means_norm', 'stds_norm');    

%% Creating a lower face model
normed_data_lower_face = normed_data;
normed_data_lower_face(:, 1:5*12*31) = 0;

[PC, score, eigen_vals] = princomp(normed_data_lower_face, 'econ');

% Keep 98 percent of variability
total_sum = sum(eigen_vals);
count = numel(eigen_vals);
for i=1:numel(eigen_vals)
   if ((sum(eigen_vals(1:i)) / total_sum) >= 0.98)
      count = i;
      break;
   end
end

PC = PC(:,1:count);

save('generic_face_lower.mat', 'PC', 'means_norm', 'stds_norm');   

%% Creating an upper face model
normed_data_upper_face = normed_data;
normed_data_upper_face(:, end-5*12*31+1:end) = 0;

[PC, score, eigen_vals] = princomp(normed_data_upper_face, 'econ');

% Keep 98 percent of variability
total_sum = sum(eigen_vals);
count = numel(eigen_vals);
for i=1:numel(eigen_vals)
   if ((sum(eigen_vals(1:i)) / total_sum) >= 0.98)
      count = i;
      break;
   end
end

PC = PC(:,1:count);

save('generic_face_upper.mat', 'PC', 'means_norm', 'stds_norm');   