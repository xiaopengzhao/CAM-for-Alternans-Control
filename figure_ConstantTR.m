close all
%% settings 
num_stim=k;  % total number of stimulations
order_of_stimu=k-5; % diagonal, plot which stimulation for figure 1

%% deal with data 
APD_49diag=zeros(xdim,num_stim);
APD_50diag=zeros(xdim,num_stim);
APD_49diag_time=zeros(xdim,num_stim);
APD_50diag_time=zeros(xdim,num_stim);
voltage_reorder=permute(voltage,[3 2 1]);
DI_reorder=permute(DI_save,[3 2 1]);
APD_reorder=permute(APD_save,[3 2 1]);

%% check the voltage, APD, DI of a single cell during whole simulation
loca_x=5; 
loca_y=loca_x;
figure(4)
plot(voltage_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

figure(5)
plot(DI_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

figure(6)
plot(APD_reorder(:,loca_x,loca_y),'r','LineWidth',1); 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

figure(7)
plot(realecg,'r','LineWidth',1); 
hold on
plot(Peaks_saved(:,1),Peaks_saved(:,2),'bo','LineWidth',1);
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);


for diag_ele=1:1:xdim  % different cells
    count49=1;  % count stimulation 
    count50=1;  % to avoid the first stimulation, which is added before simulation
    % thus, do not use 0
    
    record49=0; % order the nth 49th stimulation
    record50=0; % order the nth 50th stimulation
    
    for tim=1:1:t-500    
        if (voltage(diag_ele,diag_ele,tim)==1.0)  % count stimulation number
            count49=count49+1;
            count50=count50+1;
        end
        
        if (count49==stimulation_loop-1)
            record49=record49+1;
        % APD is determined before stimulation
        % when stimulated, APD is constant, record after 2 time step
            APD_49diag(diag_ele,record49)=APD_reorder(tim+5,diag_ele,diag_ele);
            APD_49diag_time(diag_ele,record49)=tim;
            count49=0;
        elseif (count50==stimulation_loop)
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
TR_plot=maxTR+decrease_step-order_of_stimu*decrease_step
DI_plot=(TR_plot-300)/1.5;
figure(1)
plot(sqrt(2):sqrt(2):xdim*sqrt(2),APD_50diag(:,order_of_stimu)/10,'r--','LineWidth',3); 
hold on
plot(sqrt(2):sqrt(2):xdim*sqrt(2),APD_49diag(:,order_of_stimu)/10,'b','LineWidth',1); 
legend('100th','99th')
xlabel(' distance ')
ylabel(' APD(ms)')
title(['APD along the diagonal line when TR=',num2str(TR_plot/10),' (equivalent BCL=',num2str(DI_plot/10+restitution(DI_plot)/10),')']) 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

%% APD of a cell under all BCL
BCL_inter=73:-1.875:72-1.875*(num_stim-1) ;

figure(2)
TR_plot=maxTR:-decrease_step:maxTR-num_stim*decrease_step+decrease_step;
DI_plot=(TR_plot-300)/1.5;

% plot with equivalent BCL
plot( DI_plot/10+restitution([DI_plot])/10,APD_50diag(loca_x,1:1:num_stim)/10,'r--','LineWidth',3); 
hold on
plot( DI_plot/10+restitution([DI_plot])/10,APD_49diag(loca_x,1:1:num_stim)/10,'b','LineWidth',1); 
legend('100th','99th')
xlabel('Equivalent BCL(ms)')
ylabel('APD(ms)')
title('Bifurcation of  cell (20,20)') 
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 12);

%% APD at (2,2)
figure(3)
APD_reorder=permute(APD_save,[3 2 1]);
plot(maxTR:-1:minTR,APD_reorder(time_50th_pulse,3,3),'r--','LineWidth',3); 
hold on
plot(maxTR:-1:minTR,APD_reorder(time_49th_pulse,3,3),'b','LineWidth',1); 
legend('50th','49th')
xlabel(' TR(ms) ')
ylabel(' APD(ms) ')
title('APD of cell (3,3)')   
set(gca, 'Fontname', 'Times New Roman', 'Fontsize', 14);

