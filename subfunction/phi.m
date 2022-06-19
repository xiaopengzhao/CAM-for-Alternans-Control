function [potential] = phi(x_p,y_p,xdim,ydim,t,V)
%Calculates the potential phi at a specific location (x_p,y_p). The point
%(x_p,y_p) must be outside the domain.
%here x_p is pointA(1),y_p is pointA(2)
% for 50*50 CA, x_p=y_p=0 or 51
% xdim = ydim = 50, dimensional

gradV = zeros(xdim,ydim);
gradrr = zeros(xdim,ydim);

%gradient of 1/r
for x = 1:xdim
    for y = 1:ydim
        denom = ((x-x_p)^2+(y-y_p)^2)^(3/2);        
        gradrr(x,y) = ((x_p-x)+(y_p-y)*1i)/denom;
    end
end

%gradient of V at interior points
% V is voltage
for x = 2:xdim-1
    for y = 2:ydim-1
        gradV(x,y) = (V(x+1,y,t)-V(x-1,y,t))/2+(V(x,y+1,t)-V(x,y-1,t))/2*1i;
    end
end

%gradient of V at the left edge and the right edge
for y = 2:ydim-1
    gradV(1,y) = 0+(V(1,y+1,t)-V(1,y-1,t))/2*1i;
    gradV(xdim,y) = 0+(V(xdim,y+1,t)-V(xdim,y-1,t))/2*1i;
end

%gradient of V at the top boundary and bottom boundary
for x = 2:xdim-1
    gradV(x,1) = (V(x+1,1,t)-V(x-1,1,t))/2+0*1i;
    gradV(x,ydim) = (V(x+1,ydim,t)-V(x-1,ydim,t))/2+0*1i;
end

%corner points
gradV(1,1) = 0;
gradV(1,ydim) = 0;
gradV(xdim,1) = 0;
gradV(xdim,ydim) = 0;

dtmp = dot(gradV,gradrr);
% potential = sum(sum(dtmp));   % original
potential = sum(dtmp);        % one sum is enough

end




