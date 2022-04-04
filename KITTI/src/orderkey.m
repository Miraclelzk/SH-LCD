function [ order_key ] = orderkey(SHD,bw)
    
	order_key=zeros(1,bw);
    for ll=1:bw
        %range
        range1= ll*(ll-1)/2 +1;
        range2=(ll+1)*ll/2;
        temp_SHD=SHD(range1:range2);
        order_key(ll)=norm(temp_SHD); 
    end
end