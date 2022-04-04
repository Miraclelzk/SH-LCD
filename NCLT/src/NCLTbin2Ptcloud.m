function Ptcloud = NCLTbin2Ptcloud(BinPath)
%对于球谐的运算要将中心调整到扫描中心

%% Hardware Constants
SCALING = 0.005; % 5mm
OFFSET = -100.0;

%% Reading
fidBin = fopen(BinPath, 'r');
    XYZ_Raw = fread(fidBin, 'uint16');
    XYZ_Scaled = XYZ_Raw*SCALING + OFFSET;
fclose(fidBin);

XYZ = reshape(XYZ_Scaled, 4, []);
XYZ = transpose(XYZ(1:3, :));
X = XYZ(:, 1);
Y = XYZ(:, 2);
Z = -1.*XYZ(:, 3);
XYZ = [X, Y, Z];

Ptcloud = pointCloud(XYZ);
R=angle2dcm(-90.703/180*pi,0.166/180*pi,0.807/180*pi);
T=[0.002,-0.004,0.957];
tform1 = rigid3d(R,T);
Ptcloud = pctransform(Ptcloud,invert(tform1));

end % end of function
