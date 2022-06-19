function [ap] = initial_wave_form(A,t)
%This function gives the action potential of a heart cell for a value of t
c = 0.001;
scal_factor=1;

tc = A / (log(0.9)-log(0.1*c)) /scal_factor;
f = @(t) exp(-t/tc) / (c+exp(-t/tc));

ap = f(t);

end

