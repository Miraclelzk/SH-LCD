function [ D ] = SH2SHD( coeff, bw )
%     D=zeros(bw,1);
%     for ll=1:bw
%         %range
%         range1=ll*(ll-1)+1-(ll-1);
%         range2=ll*(ll-1)+1+(ll-1);
%         temp_coeff=coeff(range1:range2);
%         D(ll)=norm(temp_coeff); 
%     end

    D=zeros((1+bw).*bw/2,1);
    counter=1;
    for ll=1:bw
        for mm=1:ll
            %range
            range1=ll*(ll-1)+1-(mm-1);
            range2=ll*(ll-1)+1+(mm-1);
            
            temp_coeff=abs(coeff(range1)).^2+abs(coeff(range2)).^2;
            
            D(counter)=sqrt(temp_coeff); 
            counter=counter+1;
        end
    end
end