%This script creates ECG graphs at 3 points outside of the heart tissue.
%Load the workspace you wish to use after running simulation

load ConstantBCL
% load ConstantDI
% load ConstantTR

pointA=[0,0]; pointB=[11,11]; % just test

t_figure=length(APD_save)-10;
for t = 1:t_figure
    potentialA = phi(pointA(1),pointA(2),xdim,ydim,t,voltage);  % voltage of left down corner
    potentialB = phi(pointB(1),pointB(2),xdim,ydim,t,voltage);  % voltage of right up corner
    ecg(t) = potentialB - potentialA;                           % voltage difference to create ECG
end
figure();
plot(1:t_figure,real(ecg));
xlabel(' Time (ms) ')
ylabel(' Voltage (V) ')
title('ECG')

