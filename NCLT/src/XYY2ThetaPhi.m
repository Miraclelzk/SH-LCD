function [ theta, phi ] = XYY2ThetaPhi(x, y, z )
    
    r= sqrt(x^2 + y^2 + z^2);
    theta = acos(z/r);
    
    if x>0
        if y>=0
            phi = atan(y./x);
        else
            phi=atan(y./x)+2.*pi;
        end
    elseif x==0
        if y>0
            phi =pi./2;
        else
            phi =3.*pi./2;
        end
    elseif x<0
        phi=atan(y./x)+pi;
    end
end

