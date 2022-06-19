close all
%% settings 
num_stim=18;  % total number of stimulations
order_of_stimu=13; % diagonal, plot which stimulation for figure 1
loca_x=5;  % all BCL, plot which cell, for figure 2

%% deal with data 
APD_49diag=zeros(xdim,num_stim);
APD_50diag=zeros(xdim,num_stim);
APD_49diag_time=zeros(xdim,num_stim);
APD_50diag_time=zeros(xdim,num_stim);

APD_reorder=permute(APD_save,[3 2 1]);

for diag_ele=1:1:xdim  % different cells
    count49=-1;  % count stimulation 
    count50=-1;
    record49=0; % order the nth 49th stimulation
    record50=0; % order the nth 50th stimulation
    
    for tim=1:1:t-500    % different time
        
        if (voltage(diag_ele,diag_ele,tim)==1.0)  % count stimulation number
            count49=count49+1;
            count50=count50+1;
        end
        
        if (count49==69)
            record49=record49+1;
        % APD is determined before stimulation
        % when stimulated, APD is constant, record after 2 time step
            APD_49diag(diag_ele,record49)=APD_reorder(tim+5,diag_ele,diag_ele);
            APD_49diag_time(diag_ele,record49)=tim;
            count49=0;
        elseif (count50==70)
            record50=record50+1;
            APD_50diag(diag_ele,record50)=APD_reorder(tim+5,diag_ele,diag_ele);
            APD_50diag_time(diag_ele,record49)=tim;
            count49=0; % do not let count49 increase
            count50=0; % reset it 
        else
            continue
        end
            
    end
end

%% APD along the diagonal under one BCL
BCL_value=71-order_of_stimu
figure(1)
plot(sqrt(2):sqrt(2):xdim*sqrt(2),APD_50diag(:,order_of_stimu),'r--','LineWidth',3); 
hold on
plot(sqrt(2):sqrt(2):xdim*sqrt(2),APD_49diag(:,order_of_stimu),'b','LineWidth',1); 
legend('50th','49th')
xlabel(' distance ')
ylabel(' APD(ms)')
title(['APD along the diagonal line when BCL=',num2str(BCL_value)]) 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

%% APD of a cell under all BCL
figure(2)
plot(70:-1:70-num_stim+1,APD_50diag(loca_x,1:1:num_stim),'r--','LineWidth',3); 
hold on
plot(70:-1:70-num_stim+1,APD_49diag(loca_x,1:1:num_stim),'b','LineWidth',1); 
legend('50th','49th')
xlabel('BCL(ms)')
ylabel(' APD(ms)')
title('Bifurcation of  cell (25,25)') 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

%% APD at (2,2)
figure(3)
APD_reorder=permute(APD_save,[3 2 1]);
plot(70:-1:50,APD_reorder(time_50th_pulse,2,2),'r--','LineWidth',3); 
hold on
plot(70:-1:50,APD_reorder(time_49th_pulse,2,2),'b','LineWidth',1); 
legend('50th','49th')
xlabel(' BCL(ms) ')
ylabel(' APD(ms) ')
title('APD of cell (2,2)')   
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 14);

%% check the voltage, APD, DI of a single cell during whole simulation
loca_y=loca_x;
voltage_reorder=permute(voltage,[3 2 1]);
DI_reorder=permute(DI_save,[3 2 1]);
APD_reorder=permute(APD_save,[3 2 1]);

figure(4)
plot(voltage_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

figure(5)
plot(DI_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

figure(6)
plot(APD_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);
