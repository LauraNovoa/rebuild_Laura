clear all, close all, clc

acp_ops=load('results\Hyatt Irvine_acp.mat');
load('results\Hyatt Irvine_acs.mat');

time=time(1:8735);
elec=elec(1:8735,:);
heating=heating(1:8735);
cooling=cooling(1:8735);

axis_size=14;
label_size=16;
%% Building demand
close all,clc
figure
a1=subplot(3,1,1);
hold on
plot(time,4*elec(:,2),'Color',[0 0 1])
ylim([0 4.4*max(elec(:,2))])
set(gca,'FontSize',axis_size,...
    'XTick',[round(time(1))+.5:4:round(time(end))-.5])
datetick('x','ddd','keepticks')
xlim([time(1) time(end)])
ylabel('Elec','FontSize',label_size)
box on
hold off

a2=subplot(3,1,2);
hold on
plot(time,4*cooling,'Color',[0 0 1])
xlim([time(1) time(end)])
ylim([0 4.4*max(cooling)])
set(gca,'FontSize',axis_size,...
    'XTick',[round(time(1))+.5:4:round(time(end))-.5])
datetick('x','dd/mm','keepticks')
xlim([time(1) time(end)])
ylabel('Cool','FontSize',label_size)
box on
hold off

a3=subplot(3,1,3);
hold on
plot(time,4*heating,'Color',[0 0 1])
xlim([time(1) time(end)])
ylim([0 4.4*max(heating)])
set(gca,'FontSize',axis_size,...
    'XTick',[round(time(1))+.5:4:round(time(end))-.5])
datetick('x','dd/mm','keepticks')
xlim([time(1) time(end)])
ylabel('Heat','FontSize',label_size)
box on
hold off
linkaxes([a1 a2 a3], 'x')
% dim=

% h=annotation('textbox','String','Energy Demand (kW)','LineStyle','none','FontSize',label_size+2)
% set(h,'rotate',90)
%% Cooling from ACS
close all
figure
hold on
plot(time,acs_cool-acp_ops.acp_cool,'LineWidth',2)

hold off

figure
hold on
plot(time,acs_cool,'LineWidth',2,'Color',[.8 0 0])
plot(time,acp_ops.acp_cool,'LineWidth',2,'Color',[0 .5 0])


