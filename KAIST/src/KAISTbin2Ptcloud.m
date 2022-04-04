function Ptcloud = KAISTbin2Ptcloud(LeftBinPath,RightBinPath)
%将坐标变换到两个雷达的中心
%% Left


left_fid = fopen(LeftBinPath, 'rb'); 
left_raw_data = fread(left_fid, [4 inf], 'single'); fclose(left_fid);
left_points = left_raw_data(1:3,:)'; 
Lcloud = pointCloud(left_points);

%zyx
Rl=angle2dcm(137.39/180*pi,44.75/180*pi,1.45/180*pi);
Tl=[-0.01,0.38,0];
tforml = rigid3d(Rl,Tl);
Lcloud = pctransform(Lcloud,tforml);

%% Right
right_fid = fopen(RightBinPath, 'rb'); 
right_raw_data = fread(right_fid, [4 inf], 'single'); fclose(right_fid);
right_points = right_raw_data(1:3,:)'; 
Rcloud = pointCloud(right_points);
%zyx
Rr=angle2dcm(45.53/180*pi,135.43/180*pi,179.63/180*pi);
Tr=[0.01,-0.42,0.01];
tformr = rigid3d(Rr,Tr);
Rcloud = pctransform(Rcloud,tformr);

points=[Lcloud.Location;Rcloud.Location];

Ptcloud = pointCloud(points); 

end % end of function
