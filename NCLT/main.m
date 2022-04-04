clear; clc;

addpath(genpath('src'));
addpath(genpath('data'));

%% data preparation 
global data_path; 
% your directory should contain files like this 
% - 2012-05-26
%   l- groundtruth_2012-05-26.csv (gt pose)
%   l- velodyne_sync
%      l- <0xxxx.bin>
SequenceDate = '2013-04-05'; % ### Change this part to your date
ScanBaseDir = 'E:\working\SLAMdata\NCLT\'; % ### Change this part to your path 
data_path = strcat(ScanBaseDir, SequenceDate, '\velodyne_sync\');

%32线  1.29°这个数据仪器是倒着装的
%down_shape = [50, 60, 25];
%down_range =25:32;

 down_shape = [100, 120, 50];
 down_range =33:56;

skip_data_frame = 1;
[data_SHDs, data_orderkeys, data_poses] = loadData(down_shape ,down_range, skip_data_frame);

%% 1以z轴旋转不变 SHZE
revisit_criteria = 4; % in meter (recommend test for 5, 10, 20 meters)
keyframe_gap = 1; % for_fast_eval (if 1, no skip)

global num_candidates; num_candidates = 50;
% global num_node_enough_apart; num_node_enough_apart = 50; 

% Entropy thresholds 
middle_thres = 0.06;
thresholds1 = linspace(0, middle_thres, 50); 
thresholds2 = linspace(middle_thres, 1, 50);
thresholds = [thresholds1, thresholds2];
num_thresholds = length(thresholds);

% Main variables to store the result for drawing PR curve 

num_hits = zeros(1, num_thresholds); 
num_false_alarms = zeros(1, num_thresholds); 
num_correct_rejections = zeros(1, num_thresholds); 
num_misses = zeros(1, num_thresholds);

% main 
loop_log = [];

exp_poses = [];
exp_shds = { };
revisitness_index=[];
num_queries = length(data_poses);
for query_idx = 1:num_queries - 1
        
    % save to (online) DB
    query_shd = data_SHDs{query_idx};
    query_pose = data_poses(query_idx,:);

    exp_shds{end+1} = query_shd;
    exp_poses = [exp_poses; query_pose];
    
    if(rem(query_idx, keyframe_gap) ~= 0)
       continue;
    end

    if( length(exp_shds) < num_candidates )
       continue;
    end
    
    [revisitness, how_far_apart] = isRevisitGlobalLoc(query_pose, exp_poses(1:end-(num_candidates-1), :), revisit_criteria);

    if revisitness==1
        revisitness_index=[revisitness_index;query_idx];
    end
    %find candidates
	candidates = exp_shds(1 : (end-(num_candidates-1)));
    % find the nearest (top 1) via pairwise comparison
    nearest_idx = 0;
    min_dist = inf; % initialization 
    for ith_candidate = 1:length(candidates)
        candidate_img = candidates{ith_candidate};
        
        distance_to_query = shd_dist(query_shd, candidate_img);

        if( distance_to_query < min_dist)
            nearest_idx =ith_candidate;
            min_dist = distance_to_query;
        end     
    end 
   
    % prcurve analysis 
    for thres_idx = 1:num_thresholds
        threshold = thresholds(thres_idx);

        reject = 0;
        if( min_dist > threshold)
            reject = 1; 
        end

        if(reject == 1) 
            if(revisitness == 0)
                % TN: Correct Rejection
                num_correct_rejections(1, thres_idx) = num_correct_rejections(1, thres_idx) + 1;
            else            
                % FN: MISS
                num_misses(1, thres_idx) = num_misses(1, thres_idx) + 1; 
            end
        else
            % if under the theshold, it is considered seen.
            % and then check the correctness
            if( dist_btn_pose(query_pose, exp_poses(nearest_idx, :)) < revisit_criteria)
                % TP: Hit
                num_hits(1, thres_idx) = num_hits(1, thres_idx) + 1;
            else
                % FP: False Alarm 
                num_false_alarms(1, thres_idx) = num_false_alarms(1, thres_idx) + 1;            
            end
        end 
    end

    if( rem(query_idx, 100) == 0)
        disp( strcat(num2str(query_idx/num_queries * 100), ' % processed') );
    end
    
end

%save the log 
savePath = strcat("pr_result\SHDD ", num2str(down_shape(1))," ",num2str(down_shape(2))," ",num2str(down_shape(3))," ",num2str(revisit_criteria), "m/");
if((~7==exist(savePath,'dir')))
    mkdir(savePath);
end

save(strcat(savePath, 'revisitness_index.mat'), 'revisitness_index');
save(strcat(savePath, 'nCorrectRejections.mat'), 'num_correct_rejections');
save(strcat(savePath, 'nMisses.mat'), 'num_misses');
save(strcat(savePath, 'nHits.mat'), 'num_hits');
save(strcat(savePath, 'nFalseAlarms.mat'), 'num_false_alarms');

%% 2以SH-LCD
revisit_criteria = 4; % in meter (recommend test for 5, 10, 20 meters)
keyframe_gap = 1; % for_fast_eval (if 1, no skip)

global num_candidates; num_candidates = 50;
% global num_node_enough_apart; num_node_enough_apart = 50; 

% Entropy thresholds 
middle_thres = 0.06;
thresholds1 = linspace(0, middle_thres, 50); 
thresholds2 = linspace(middle_thres, 1, 50);
thresholds = [thresholds1, thresholds2];
num_thresholds = length(thresholds);

% Main variables to store the result for drawing PR curve 

num_hits = zeros(1, num_thresholds); 
num_false_alarms = zeros(1, num_thresholds); 
num_correct_rejections = zeros(1, num_thresholds); 
num_misses = zeros(1, num_thresholds);

% main 
loop_log = [];

exp_poses = [];
exp_orderkeys = [];
exp_shds = { };
revisitness_index=[];
num_queries = length(data_poses);
for query_idx = 1:num_queries - 1
        
    % save to (online) DB
    query_shd = data_SHDs{query_idx};
    query_ok = data_orderkeys(query_idx, :);
    query_pose = data_poses(query_idx,:);

    exp_shds{end+1} = query_shd;
    exp_poses = [exp_poses; query_pose];
    exp_orderkeys = [exp_orderkeys; query_ok];
    
    if(rem(query_idx, keyframe_gap) ~= 0)
       continue;
    end

    if( length(exp_shds) < num_candidates )
       continue;
    end

    tree = createns(exp_orderkeys(1:end-(num_candidates-1), :), 'NSMethod', 'kdtree'); % Create object to use in k-nearest neighbor search

    % revisitness 
    % is revisit
    [revisitness, how_far_apart] = isRevisitGlobalLoc(query_pose, exp_poses(1:end-(num_candidates-1), :), revisit_criteria);
    %disp([revisitness, how_far_apart])
    
    if revisitness==1
        revisitness_index=[revisitness_index;query_idx];
    end
    
    % find candidates 
    candidates = knnsearch(tree, query_ok, 'K', 30); 
    
    % find the nearest (top 1) via pairwise comparison
    nearest_idx = 0;
    min_dist = inf; % initialization 
    for ith_candidate = 1:length(candidates)
        candidate_node_idx = candidates(ith_candidate);
        candidate_img = exp_shds{candidate_node_idx};

        distance_to_query = shd_dist(query_shd, candidate_img);

        if( distance_to_query < min_dist)
            nearest_idx = candidate_node_idx;
            min_dist = distance_to_query;
        end     
    end 
   
    % prcurve analysis 
    for thres_idx = 1:num_thresholds
        threshold = thresholds(thres_idx);

        reject = 0;
        if( min_dist > threshold)
            reject = 1; 
        end

        if(reject == 1) 
            if(revisitness == 0)
                % TN: Correct Rejection
                num_correct_rejections(1, thres_idx) = num_correct_rejections(1, thres_idx) + 1;
            else            
                % FN: MISS
                num_misses(1, thres_idx) = num_misses(1, thres_idx) + 1; 
            end
        else
            % if under the theshold, it is considered seen.
            % and then check the correctness
            if( dist_btn_pose(query_pose, exp_poses(nearest_idx, :)) < revisit_criteria)
                % TP: Hit
                num_hits(1, thres_idx) = num_hits(1, thres_idx) + 1;
            else
                % FP: False Alarm 
                num_false_alarms(1, thres_idx) = num_false_alarms(1, thres_idx) + 1;            
            end
        end

    end

    if( rem(query_idx, 100) == 0)
        disp( strcat(num2str(query_idx/num_queries * 100), ' % processed') );
    end
    
end

%save the log 
savePath = strcat("pr_result\SHDDD ", num2str(down_shape(1))," ",num2str(down_shape(2))," ",num2str(down_shape(3))," ",num2str(revisit_criteria), "m/");
if((~7==exist(savePath,'dir')))
    mkdir(savePath);
end

save(strcat(savePath, 'revisitness_index.mat'), 'revisitness_index');
save(strcat(savePath, 'nCorrectRejections.mat'), 'num_correct_rejections');
save(strcat(savePath, 'nMisses.mat'), 'num_misses');
save(strcat(savePath, 'nHits.mat'), 'num_hits');
save(strcat(savePath, 'nFalseAlarms.mat'), 'num_false_alarms');

%% 3以全圆周旋转不变 SHE
revisit_criteria = 4; % in meter (recommend test for 5, 10, 20 meters)
keyframe_gap = 1; % for_fast_eval (if 1, no skip)

global num_candidates; num_candidates = 50;
% global num_node_enough_apart; num_node_enough_apart = 50; 

% Entropy thresholds 
middle_thres = 0.0004;
thresholds1 = linspace(0, middle_thres, 50); 
thresholds2 = linspace(middle_thres, 0.01, 50);
thresholds = [thresholds1, thresholds2];
num_thresholds = length(thresholds);

% Main variables to store the result for drawing PR curve 

num_hits = zeros(1, num_thresholds); 
num_false_alarms = zeros(1, num_thresholds); 
num_correct_rejections = zeros(1, num_thresholds); 
num_misses = zeros(1, num_thresholds);

% main 
loop_log = [];

exp_poses = [];
exp_orderkeys = [ ];
revisitness_index=[];
num_queries = length(data_poses);

for query_idx = 1:num_queries - 1
        
    % save to (online) DB
    query_ok = data_orderkeys(query_idx, :);
    query_pose = data_poses(query_idx,:);

    exp_poses = [exp_poses; query_pose];
    exp_orderkeys = [exp_orderkeys; query_ok];
    
    if(rem(query_idx, keyframe_gap) ~= 0)
       continue;
    end
    [mm,~]=size(exp_orderkeys);
    if( mm < num_candidates )
       continue;
    end
    
    % Create object to use in k-nearest neighbor search
    tree = createns(exp_orderkeys(1:end-(num_candidates-1), :), 'NSMethod', 'kdtree'); 
    % revisitness 
    % is revisit
    [revisitness, how_far_apart] = isRevisitGlobalLoc(query_pose, exp_poses(1:end-(num_candidates-1), :), revisit_criteria);

    if revisitness==1
        revisitness_index=[revisitness_index;query_idx];
    end
    
    % find candidates 
    candidates = knnsearch(tree, query_ok, 'K', 10); 
    
    % find the nearest (top 1) via pairwise comparison
    nearest_idx = 0;
    min_dist = inf; % initialization 
    for ith_candidate = 1:length(candidates)
        candidate_node_idx = candidates(ith_candidate);
        candidate_img = exp_orderkeys(candidate_node_idx,:);

        distance_to_query = shd_dist(query_ok, candidate_img);

        if( distance_to_query < min_dist)
            nearest_idx = candidate_node_idx;
            min_dist = distance_to_query;
        end     
    end 
   
    % prcurve analysis 
    for thres_idx = 1:num_thresholds
        threshold = thresholds(thres_idx);

        reject = 0;
        if( min_dist > threshold)
            reject = 1; 
        end

        if(reject == 1) 
            if(revisitness == 0)
                % TN: Correct Rejection
                num_correct_rejections(1, thres_idx) = num_correct_rejections(1, thres_idx) + 1;
            else            
                % FN: MISS
                num_misses(1, thres_idx) = num_misses(1, thres_idx) + 1; 
            end
        else
            % if under the theshold, it is considered seen.
            % and then check the correctness
            if( dist_btn_pose(query_pose, exp_poses(nearest_idx, :)) < revisit_criteria)
                % TP: Hit
                num_hits(1, thres_idx) = num_hits(1, thres_idx) + 1;
            else
                % FP: False Alarm 
                num_false_alarms(1, thres_idx) = num_false_alarms(1, thres_idx) + 1;            
            end
        end 
    end

    if( rem(query_idx, 100) == 0)
        disp( strcat(num2str(query_idx/num_queries * 100), ' % processed') );
    end
    
end
%save the log 
savePath = strcat("pr_result\SHD ", num2str(down_shape(1))," ",num2str(down_shape(2))," ",num2str(down_shape(3))," ",num2str(revisit_criteria), "m/");
if((~7==exist(savePath,'dir')))
    mkdir(savePath);
end

save(strcat(savePath, 'revisitness_index.mat'), 'revisitness_index');
save(strcat(savePath, 'nCorrectRejections.mat'), 'num_correct_rejections');
save(strcat(savePath, 'nMisses.mat'), 'num_misses');
save(strcat(savePath, 'nHits.mat'), 'num_hits');
save(strcat(savePath, 'nFalseAlarms.mat'), 'num_false_alarms');
