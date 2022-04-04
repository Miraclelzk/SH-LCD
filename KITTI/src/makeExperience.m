function [SHDs, orderkeys, xy_poses] = makeExperience(data_dir, shape,lat_range, skip_data_frame)

%% 参数
num_lat = shape(1);
num_lon = shape(2);
num_bw = shape(3);

%%
lidar_data_dir = strcat(data_dir, 'velodyne\');
data_names = osdir(lidar_data_dir);

%% gps to xyz
gtpose = csvread(strcat(data_dir, '00.csv'));
% gtpose_time = gtpose(:, 1);
gtpose_xy = gtpose(:, [4,12]);


%%
num_data = length(data_names);
num_data_save = floor(num_data/skip_data_frame) + 1;
save_counter = 1;

SHDs = cell(1, num_data_save);
orderkeys = zeros(num_data_save, num_bw);
xy_poses = zeros(num_data_save, 2);

for data_idx = 1:num_data
    
    if(rem(data_idx, skip_data_frame) ~=0)
        continue;
    end
    
    file_name = data_names{data_idx};
    data_time = str2double(file_name(1:end-4));
    data_path = strcat(lidar_data_dir, file_name);
    
    % get
    ptcloud = readBin(data_path);
    [SHD,data] = Ptcloud2SHD(ptcloud,num_lon,num_lat,lat_range, num_bw); % up to 80 meter
    ok = orderkey(SHD,num_bw);
    
%     [nearest_time_gap, nearest_idx] = min(abs(repmat(data_time, length(gtpose_time), 1) - gtpose_time));
    xy_pose = gtpose_xy(data_idx, :);
    
    % save 
    SHDs{save_counter} = SHD;
    orderkeys(save_counter, :) = ok;
    xy_poses(save_counter, :) = xy_pose;
    save_counter = save_counter + 1;
    
    % log
    if(rem(data_idx, 100) == 0)
        message = strcat(num2str(data_idx), " / ", num2str(num_data), " processed (skip: ", num2str(skip_data_frame), ")");
        disp(message); 
    end
end

SHDs = SHDs(1:save_counter-1);
orderkeys = orderkeys(1:save_counter-1, :);
xy_poses = xy_poses(1:save_counter-1, :);


end
