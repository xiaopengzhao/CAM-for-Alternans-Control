function [y] = restitution(Dn)
%This function graphs the action potential duration (APD) as a function
%of the diastolic interval.

%% 0.1 time step 
Amax = 3150;  % best is 310
tau = 500;
A0 = tau*exp(700/tau);

f = @(Dn) Amax - A0.*exp(-Dn./tau);
y = f(Dn);

end

