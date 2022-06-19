%% this program is just used to generate the .mat file
%This function simulates wave propagation through heart tissue using constant DI control.
function[] = ConstantDI()
clear;
clc
addpath('subfunction')
%% parameter setting
maxDI=801;
minDI=1;
decrease_step=50;
xdim = 10; ydim = 10; 

%% 
locx= xdim/2;  locy= ydim/2; % voltage record location
tfinal= 20000; 
DI=ones(xdim,ydim)*maxDI;
APD=restitution(DI);
duration=(APD+DI);

%% system initial
refractThreshold = 0.1;
excitationThreshold = 0.9;
DI_save  =zeros(xdim,ydim,tfinal);
APD_save =zeros(xdim,ydim,tfinal);
       
voltage = zeros(xdim,ydim,tfinal+1);
voltage1=zeros(1,tfinal);
DI_cent_save=zeros(1,tfinal);
APD_cent_save=zeros(1,tfinal);
duration_save=zeros(1);
time_50th_pulse=[]; time_49th_pulse=[]; 
t_step = 1;

% Initialize the tissue
% Apply the initial stimulation
for x = 1:3
    for y = 1:3
       DI(x,y) = duration(x,y) - APD(x,y);
       APD(x,y) = restitution(DI(x,y));
       voltage(x,y,1)= 1;
       duration(x,y) = 0;
    end
end

%% Apply wave propagation.
%here add control
t_up=1;

for k=1:1:((maxDI-minDI)/decrease_step+1)   % for different DI=maxDI-k values
for stim=1:1:50  % stimulation_loop stimulation for each DI
    DI_control=0;  
    
for t = t_up:t_step:t_up+10^7  % apply constant DI for one time
        for x = 1:xdim
            for y = 1:ydim
                propagationFunction(x,y,t);
            end
        end
%% data storage
    DI_save (1:xdim,1:ydim,t)=DI;
    APD_save(1:xdim,1:ydim,t)=APD;
    duration_save(1:xdim,1:ydim,t)=duration;
    DI_cent_save(t)=DI(locx, locy);
    APD_cent_save(t)=APD(locx, locy);
    voltage1(t)= voltage(locx, locy, t);
 
%% below is control part
        if (voltage(3,3,t)<=refractThreshold) % use pacemaker cell voltage
        DI_control= DI_control+1;
        end
     if  (DI_control==maxDI-(k-1)*decrease_step)   % control target DI=26-k
        for x = 1:3
          for y = 1:3
               stimFunction(x,y,t);          
          end
        end   
     break
    else
       continue 
     end    
 end
 t_up=t+1;
  if  (stim==50)
       time_50th_pulse=[time_50th_pulse,t-1];
  elseif (stim==49)
       time_49th_pulse=[time_49th_pulse,t-1]; 
  end
end
end
 

%% let the far away cells to finish simulation
for t = t_up:t_step:t_up+1000
   for x = 1:xdim
      for y = 1:ydim
          propagationFunction(x,y,t);
      end
   end   
   DI_save (1:xdim,1:ydim,t)=DI;
   APD_save(1:xdim,1:ydim,t)=APD;
   voltage1(t)= voltage(locx, locy, t);
end

%% Save workspace
save('ConstantDI','-v7.3')

%==== Stimulation & Propagation Functions ====
    function [] = stimFunction(x,y,t)
    %Checks to see if the action potential of the pacemaker cell is below
    %the refractory threshold so it can be stimulated
         if(voltage(x,y,t) <= refractThreshold)
              DI(x,y) = duration(x,y) - APD(x,y); 
              APD(x,y) = restitution(DI(x,y));
              voltage(x,y,t+1) = 1;
              duration(x,y) = 0;
        end
    end

    function [] = depolarization(x,y,t)
    %The cell is depolarized. The DI from the previous beat is calculated
    %and the APD is determined for the next beat. Action potential
        duration(x,y) = duration(x,y) + t_step;  % because this is a new time step, 
        DI(x,y) = duration(x,y) - APD(x,y);
        APD(x,y) = restitution(DI(x,y));
        voltage(x,y,t+1) = 1;
        duration(x,y) = 0;
    end

    function [] = propagationFunction(x,y,t)
    %Checks to see if the action potential of a cell is below the
    %refractory threshold. If it is, its neighbors are checked in
    %check4excitation.
        if(voltage(x,y,t+1-t_step) <= refractThreshold)
            b = check4excitation(x,y,t); %check neighboring cells
            if(b == 1)
                depolarization(x,y,t);
            else
                evolution(x,y,t);
            end
        else
            evolution(x,y,t);
        end
    end

    function [b] = check4excitation(x,y,t)
    %Checks to see how many neighboring cells of the cell being evaluated
    %are excited. If at least 3 neighbors are excited, the evaluated cell
    %will become excited.
        val = 0;
        for i=x-1:x+1
            for j=y-1:y+1
                %Skip cells outside of the tissue
                %Skip the cell being evaluated
                if(i == 0 || j == 0)
                    continue;
                end
                if(i > xdim || j > ydim)
                    continue
                end
                if(i == x && j == y)
                    continue
                end
                if(voltage(i,j,t) > excitationThreshold)
                    val = val + 1;
                end
            end
        end 
        %If at least 3 neighboring cells are excited, the evaluated cell
        %becomes excited.
        if(val >= 3)
                 b = 1;
        else
            b = 0;
        end
    end

    function [] = evolution(x,y,t)
    %Duration updates if the cell does not stimulate at t, and the action
    %potential at t is calculated.
        duration(x,y) = duration(x,y) + t_step;
        voltage(x,y,t+1) = initial_wave_form(APD(x,y), duration(x,y));
    end
end
