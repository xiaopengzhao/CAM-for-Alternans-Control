
t=0:1:4500;

initial_wave_form_gra(t)

function [] = initial_wave_form_gra(t)
%This function graphs the initial wave form

y = zeros(1, length(t));
for i=1:length(t)
    y(i) = initial_wave_form(3000, t(i));
end

figure();
plot(t/10, y);
xlabel(' Time (ms) ')
ylabel(' Action potential (V) ')
title(' Voltage Waveform (APD=300)')
saveas(gcf, 'initial_wave_form_graph.png')

end

