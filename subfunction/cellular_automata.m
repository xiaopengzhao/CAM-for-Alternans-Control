function [ ] = cellular_automata(voltage, xdim, ydim, tfinal, v, tl)
%For each timestep, a plot is surface plot is created of each heart
%cell can put into the movie.

x = linspace(1,xdim,xdim);
y = linspace(1,ydim,ydim);
[X,Y] = meshgrid(x,y);

for t = 1:tfinal+1
    for x = 1:xdim
        for y = 1:ydim
            Z(y,x) = voltage(y,x,t);
        end
    end

    surf(X,Y,Z)
    colorbar
    title(tl)
    xlabel(' x ')
    ylabel(' y ')
    view(2)
    M(t) = getframe(gcf);
    writeVideo(v,M(t));
end

end

