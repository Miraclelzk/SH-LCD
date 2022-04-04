function [SHDs, OrderKeys, poses] = loadData(down_shape,down_range,skip_data_frame)
%data_shape 采样的参数[lat,lon]

%%
global data_path;
data_save_path= strcat('.\data\',num2str(down_shape(1)),"_",num2str(down_shape(2)),"_",num2str(down_shape(3)),"\");

%%
% newly make
if exist(data_save_path) == 0 
    % make 
    [SHDs, OrderKeys, poses] = makeExperience(data_path, down_shape,down_range,skip_data_frame);    
    
    % save
    mkdir(data_save_path);

    filename = strcat(data_save_path, 'SHDs', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    save(filename, 'SHDs');
    filename = strcat(data_save_path, 'OrderKeys', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    save(filename, 'OrderKeys');
    filename = strcat(data_save_path, 'poses', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    save(filename, 'poses');

% or load 
else
    filename = strcat(data_save_path, 'SHDs', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    load(filename);
    % fix
    for iii = 1:length(SHDs)
        SH = double(SHDs{iii});
        SHDs{iii} = SH;
    end
    
    filename = strcat(data_save_path, 'OrderKeys', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    load(filename);
    filename = strcat(data_save_path, 'poses', num2str(down_shape(1)), 'x', num2str(down_shape(2)), '.mat');
    load(filename);
    
    disp('- successfully loaded.');
end

%%
disp(' ');

end

