%��г��γ�����任

%data  ����������
%lon   ����
%lat   γ��
%weight Ȩֵ
%�����bw
function [coeffs]=SHT_earth_f(data,lon_num,lat_num,lat_range,bw,real_or_complex)

lat_=size(lat_range,2);
n=lon_num*lat_;
%��γ�Ȳ����ķ�Χ�ڵ��λ��
thetastep = pi/lat_num/2;
phistep=2*pi/lon_num/2;

theta=zeros(n,1);
phi=zeros(n,1);
for i= 1:lat_
    for j=1:lon_num  
        theta((i-1)*lon_num+j)=(2*(lat_range(i)-1)+1)*thetastep;
    	phi((i-1)*lon_num+j)=(2*(j-1)+1)*phistep;   
    end   
end

% ÿ�������г���� 
Y=SH(bw,theta,phi,real_or_complex);
Y=Y.';

%����Ȩ
fudge = pi/(2*lat_num);
weight=ones(lat_,1);
for i=1:lat_
   tmpsum=0;
   for j=0:bw-1
        tmpsum=tmpsum+1/(2*j+1)*sin((2*j+1)*(2*(lat_range(i)-1)+1)*fudge);
   end  
   tmpsum=tmpsum*sin((2*(lat_range(i)-1)+1)*fudge);
   tmpsum=tmpsum*2*pi*4/lat_num/lon_num;
   weight(i)=tmpsum; 
end

w=weight(:,ones(lon_num,1));
w=w';
w1=reshape(w,lon_num*lat_,1);
%�������任
coeffs=Y*(data.*w1);
end