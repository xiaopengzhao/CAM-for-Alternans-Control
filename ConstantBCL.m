%% this program can generate the .mat file
%This function simulates wave propagation through heart tissue using constant BCL 
function[] = ConstantBCL()
%% parameter setting
addpath('subfunction')
maxBCL=3500;  
minBCL=2900;
decrease_step=100;    
xdim = 10; ydim = 10;

%%
locx= xdim/2;  locy= ydim/2; % voltage record location
stimTimes =[0]; time_50th_pulse=[]; time_49th_pulse=[]; 

for k=1:1:((maxBCL-minBCL)/decrease_step+1)
% each time the BCL=  maxBCL-(k-1)*decrease_step  
stimTimes = [stimTimes,[stimTimes(end)+maxBCL-(k-1)*decrease_step:maxBCL-(k-1)*decrease_step:stimTimes(end)+ (maxBCL-(k-1)*decrease_step)*50]];
time_50th_pulse=[time_50th_pulse,stimTimes(end)-1]   ;
time_49th_pulse=[time_49th_pulse,stimTimes(end-1)-1] ;
end

tfinal = stimTimes(end)+500;

DI_save  =zeros(xdim,ydim,tfinal);
APD_save =zeros(xdim,ydim,tfinal);

voltage1=zeros(1,tfinal);

%Initialization of variables
refractThreshold = 0.1;
excitationThreshold = 0.9;

t_step = 1;
%Initialize the tissue
voltage = zeros(xdim,ydim,tfinal+1);
DI=ones(xdim,ydim)*800;  % initial DI, fully rest cells
APD=restitution(DI);
duration=APD+DI;

% Apply the initial stimulation
for x = 1:3
   for y = 1:3
       DI(x,y) = duration(x,y) - APD(x,y);
       APD(x,y) = restitution(DI(x,y));
       voltage(x,y,1) = 1;
       duration(x,y)  = 0;
   end
end

%Apply wave propagation.
tend = 0;  
for numOfStim = 2:length(stimTimes) 
    tstart = tend + t_step;
    tend = stimTimes(numOfStim);  % for every stimulation time
    for t = tstart:t_step:tend
        for x = 1:xdim
            for y = 1:ydim
                propagationFunction(x,y,t);
            end
        end 
    DI_save (1:xdim,1:ydim,t)=DI;
    APD_save(1:xdim,1:ydim,t)=APD;
    voltage1(t)= voltage(locx, locy, t);
    end
    %Apply the stimulation at tend.
    for x = 1:3
        for y = 1:3
            stimFunction(x,y,tend); % old
        end
    end
end
 
%% let the far away cells to finish simulation
for t = tend+1:t_step:tend+5000
   for x = 1:xdim
      for y = 1:ydim
          propagationFunction(x,y,t);
      end
   end   
   DI_save (1:xdim,1:ydim,t)=DI;
   APD_save(1:xdim,1:ydim,t)=APD;
   voltage1(t)= voltage(locx, locy, t);
end

%%
%Save workspace
save('ConstantBCL','-v7.3')

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
        DI(x,y) = duration(x,y)+1 - APD(x,y);
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