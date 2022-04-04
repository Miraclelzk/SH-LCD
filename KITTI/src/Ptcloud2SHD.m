function [ D,data ] = Ptcloud2SHD( ptcloud, num_lon, num_lat,lat_range, bw )
%% Preprocessing
num_points = ptcloud.Count;

thetastep = pi/ num_lat;
phistep= 2*pi/num_lon;


lat_=size(lat_range,2);
%% vacant bins
cell_bins = cell(lat_, num_lon);
cell_bin_counter = ones(lat_, num_lon);

enough_large = 500; % for fast and constant time save, We contain maximum 500 points per each bin.
enough_small = -10000;
for ith_lat = 1:lat_
   for ith_lon = 1:num_lon
        bin = enough_small * ones(enough_large, 3);
        cell_bins{ith_lat, ith_lon} = bin;
   end
end
%% Save a point to the corresponding bin 
for ith_point =1:num_points

    % Point information 
    ith_point_xyz = ptcloud.Location(ith_point,:); 
    %
    temp_r=norm(ith_point_xyz);
    if temp_r<3 || temp_r>80
        continue;
    end

    [ith_point_theta, ith_point_phi ]= XYY2ThetaPhi(ith_point_xyz(1), ith_point_xyz(2), ith_point_xyz(3));
    
    % Find the corresponding theta index    
    tmp_theta_index = ceil(ith_point_theta/thetastep);
    if(tmp_theta_index > lat_range(lat_) || tmp_theta_index < lat_range(1))
        continue;
    else
        theta_index = tmp_theta_index-lat_range(1)+1;
    end
    
    % Find the corresponding phi index 
    tmp_phi_index = ceil(ith_point_phi/phistep);
    if(tmp_phi_index == 0)
        phi_index = 1;
    elseif(tmp_phi_index > num_lon || tmp_phi_index < 1)
        phi_index = num_lon;
    else
        phi_index = tmp_phi_index;
    end
    
    % Assign point to the corresponding bin cell 
    try
        corresponding_counter = cell_bin_counter(theta_index, phi_index); % 1D real value.
    catch
        continue;
    end
    cell_bins{theta_index, phi_index}(corresponding_counter, :) = ith_point_xyz;
    %counter
    cell_bin_counter(theta_index, phi_index) = cell_bin_counter(theta_index, phi_index) + 1; % increase count 1
end

%% bin to data 
data = zeros(lat_ ,num_lon);

min_num_thres = 5; % a bin with few points, we consider it is noise.
% Find maximum Z value of each bin and Save into img 
for ith_lat = 1:lat_
    for ith_lon = 1:num_lon
 
        value_of_the_bin = 0;            
        points_in_bin_ij = cell_bins{ith_lat, ith_lon};
        nums_in_bin_ij =cell_bin_counter(ith_lat, ith_lon);
        %if only 5 points in bin ,we consider it is noise
        if( IsBinHaveMoreThanMinimumPoints(points_in_bin_ij, min_num_thres, enough_small) )
            temp_point=points_in_bin_ij(1:nums_in_bin_ij-1,:);
            temp_r=sqrt(sum(temp_point.^2,2));
            %max
            value_of_the_bin = mean(temp_r);
        else
            value_of_the_bin = 0;             
        end
        %靠近地面前4个不能大于8
        if ith_lat > lat_-4 && value_of_the_bin > 8
            data(ith_lat, ith_lon) = 0;    
        else
            data(ith_lat, ith_lon) = value_of_the_bin;
        end        
    end
end


%% data to Descriptor

data1=reshape(data.',lat_*num_lon,1);

TheCoeff=SHT_earth_f(data1,num_lon,num_lat,lat_range,bw,'complex');

%描述子多
D=SH2SHD(TheCoeff,bw);

end% end of main function

function bool = IsBinHaveMoreThanMinimumPoints(mat, minimum_thres, enough_small)

min_thres_point = mat(minimum_thres, :);

if( isequal(min_thres_point, [ enough_small, enough_small, enough_small]) )
    bool = 0;
else
    bool = 1;
end

end
