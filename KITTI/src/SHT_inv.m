%球谐逆变换

%coeffs 球谐系数  
%bw  输出的bw
%lon   经度
%lat   纬度

%data  输出的数据

function [data]=SHT_inv(coeffs,bw,lon,lat,real_or_complex)

% 每个经纬网点的球谐函数 
Y=SH(bw,lon,lat,real_or_complex);
Y=conj(Y);

%计算正变换
data=Y*coeffs;

end