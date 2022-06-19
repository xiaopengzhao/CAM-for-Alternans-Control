%% this program is just used to generate the .mat file
%This function simulates wave propagation through heart tissue using constant TR control.

function[] = ConstantTR()
clear; clc;
addpath('subfunction')
%% parameter setting
maxTR=1500;   
minTR=10;
decrease_step=50;
xdim = 10; ydim = 10;

%%
cell_num_threshold=3;
paced_area=3;
tfinal =round((800+restitution(800))/2*(maxTR-minTR)/decrease_step*50);
locx= xdim/2;  locy= ydim/2;  % voltage record location
pointA=[0,0]; pointB=[xdim+1,ydim+1]; 

% define control parameters
peak_thresh_posit= 0.0005;    
peak_thresh_negat=-0.0005;
Detect_after= 300; 

DI=ones(xdim,ydim)*830;
APD=restitution(DI);
duration=(APD+DI);
    
%% system initialization
DI_save  =zeros(xdim,ydim,tfinal);
APD_save =zeros(xdim,ydim,tfinal);
voltage = zeros(xdim,ydim,tfinal+1); 
ecg= zeros(1,tfinal+1); 
voltage1=zeros(1,tfinal);
voltage2=zeros(1,tfinal);

Peaks_saved  =zeros( round((maxTR-minTR)/decrease_step*50),2);
TR_save=zeros( tfinal,2);
t_stimulation=zeros( round((maxTR-minTR)/decrease_step*50),1);
t_condblock=zeros(20,1);
time_50th_pulse=zeros( round((maxTR-minTR)/decrease_step),1); 
time_49th_pulse=zeros( round((maxTR-minTR)/decrease_step),1);  

%Initialization of variables
refractThreshold = 0.1;
excitationThreshold = 0.9;

%Initialize the tissue
t_step = 1;

%Apply the initial stimulation
for x = 1:paced_area
   for y = 1:paced_area
       DI(x,y) = duration(x,y) - APD(x,y);
       APD(x,y) = restitution(DI(x,y));
       voltage(x,y,1) = 1;
       duration(x,y) = 0;
   end
end

%% Apply TR control propagation
% here we directly use TR control 
t_up=1;
CB_count=1;
count_stim=1;
count_peak=1;
count_50pulse=1;
count_49pulse=1;
peak_time=-10^5;
for k=1:1:((maxTR-minTR)/decrease_step+1) % for different TR=maxTR-k values
    TR_value=maxTR-(k-1)*decrease_step;
for stim=1:1:50  % stimulation_loop stimulation for each TR
for t = t_up:t_step:t_up+30000  % under every stimulation, find a time to add TR control
        for x = 1:xdim
            for y = 1:ydim
                propagationFunction(x,y,t);
            end
        end 
        
%% data storage
    DI_save (1:xdim,1:ydim,t)=DI;
    APD_save(1:xdim,1:ydim,t)=APD;
    voltage1(t)= voltage(locx, locy, t);
    TR_save(t,:)=[t,maxTR-(k-1)*decrease_step];
    
%% below is control part
% 1  Calculate ECG value here for each time step 
    potentialA = phi(pointA(1),pointA(2),xdim,ydim,t,voltage);  % voltage of left down corner
    potentialB = phi(pointB(1),pointB(2),xdim,ydim,t,voltage);  % voltage of right up corner
    ecg(t)=potentialB - potentialA;    
    realecg=real(ecg);  

% 2 find peak
% when only count positive peak
%   if  (t>t_up+Detect_after)&&  (realecg(t-1) > realecg(t)) && (realecg(t-1) > realecg(t-2))  && (realecg(t-1) > peak_thresh_posit) 
% when count both positive and negative peak
  if  ((t>t_up+Detect_after)&&  (realecg(t-1) > realecg(t)) && (realecg(t-1) > realecg(t-2))  && (realecg(t-1) > peak_thresh_posit) ) ||...
      ((t>t_up+Detect_after)&&  (realecg(t-1) < realecg(t)) && (realecg(t-1) < realecg(t-2))  && (realecg(t-1) < peak_thresh_negat) )    
        Peaks_saved(count_peak,:)=[t-1,realecg(t-1)];
        count_peak=count_peak+1;
        peak_time=t-1;
  end

% It is verified that this logic '(t-Peaks_saved(count_peak-1,1)==3800)' is reasonable
% befor the stimulation is given, another new peak alreay appears 
%   if  ismember([t-peak_time],[maxTR-(k-1)*decrease_step, maxTR-(k-2)*decrease_step, maxTR-(k-3)*decrease_step]) % can also add more  
% because 'peak_time' will update to -10^5, thus this is ineffective，so, actually we should use t_stimulation(count_stim-1,1)
%   if  (t-peak_time==maxTR-(k-1)*decrease_step)||(t-t_stimulation(count_stim-1,1)==3800)  % old logic
  
  if  (t-peak_time==TR_value)
        for x = 1:paced_area
          for y = 1:paced_area  
          stimFunction(x,y,t);      
          end
        end
        
        if  (t-peak_time>(maxTR-(k-1)*decrease_step))
            t_condblock(CB_count)=t;
            CB_count=CB_count+1;
        end 
        t_stimulation(count_stim)=t;
        count_stim=count_stim+1;
        
        if voltage(1,1,t+1) ==1 
          break
        else
           TR_value=TR_value+decrease_step;
           continue 
       end
  end
end
% peak_time=-10^5;
if  (stim==50)
       time_50th_pulse(count_50pulse)=t-1;
       count_50pulse=(count_50pulse)+1;
elseif (stim==50-1)
       time_49th_pulse(count_49pulse)=t-1;
       count_49pulse=count_49pulse+1;
end
t_up=t+1;
end
end

%% Save workspace
save('ConstantTR','-v7.3')

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
    %becomes 1V and duration is reset.
        duration(x,y) = duration(x,y) + t_step;  % because this is a new time step
        DI(x,y) = duration(x,y) - APD(x,y);
        APD(x,y) = restitution(DI(x,y));
        voltage(x,y,t+1) = 1;
        duration(x,y) = 0;
    end

    function [] = propagationFunction(x,y,t)
    %Checks to see if the action potential of a cell is below the
    %refractory threshold. If it is, its neighbors are checked in
    %check4excitation.
        if(voltage(x,y,t) <= refractThreshold)
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
        if(val >= cell_num_threshold)
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
