%��г��任

%coeffs ��гϵ��  
%bw  �����bw
%lon   ����
%lat   γ��

%data  ���������

function [data]=SHT_inv(coeffs,bw,lon,lat,real_or_complex)

% ÿ����γ�������г���� 
Y=SH(bw,lon,lat,real_or_complex);
Y=conj(Y);

%�������任
data=Y*coeffs;

end