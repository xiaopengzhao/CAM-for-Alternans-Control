%This script will create a movie of the scenario run in simulation.m
%or simulation_nocontrol.m. Load the workspace you wish to run in
%line 6.

clear 
load ConstantBCL
% load ConstantDI
% load ConstantTR

figure();
v = VideoWriter(['Wave propagation','.avi']);
open(v);
cellular_automata(voltage, ydim, xdim, 1000, v, 'Wave propagation');
close(v);