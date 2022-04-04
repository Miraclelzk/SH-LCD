function [SHDs, orderkeys, xy_poses] = makeExperience(ScanDir, shape,lat_range, skip_data_frame)

%% 参数
num_lat = shape(1);
num_lon = shape(2);
num_bw = shape(3);

%%
%采样数据名字
left_data_names=load('.\sample_data\leftsampledata.mat');
left_data_names=left_data_names.Left_Sample_Date;

right_data_names=load('.\sample_data\rightsampledata.mat');
right_data_names=right_data_names.Right_Sample_Date;

%% gps to xyz
Sample_Pose=load('.\sample_data\samplepose.mat');
Sample_Pose=Sample_Pose.Sample_Pose;
gtpose_xy = Sample_Pose(:, [2,3]);


%%
num_data = length(left_data_names);
num_data_save = floor(num_data/skip_data_frame) + 1;
save_counter = 1;

SHDs = cell(1, num_data_save);
orderkeys = zeros(num_data_save, num_bw);
xy_poses = zeros(num_data_save, 2);

for data_idx = 1:num_data
    
    if(rem(data_idx, skip_data_frame) ~=0)
        continue;
    end
    
    left_file_name = left_data_names(data_idx,:);
    left_data_time = str2double(left_file_name(1:end-4));
    LeftScanDir = strcat(ScanDir, '\VLP_left\');
    left_data_path = strcat(LeftScanDir, left_file_name);
    
	right_file_name = right_data_names(data_idx,:);
    right_data_time = str2double(right_file_name(1:end-4));
    RightScanDir = strcat(ScanDir, '\VLP_right\');
    right_data_path = strcat(RightScanDir, right_file_name);
    
    % get
    ptcloud = KAISTbin2Ptcloud(left_data_path,right_data_path);
    
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
