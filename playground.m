%% Conversion of DER optimizaiton to YALMIP formulation
%%% Rewrites the optimization from playground using yalmip
clc,
clear all, close all

%%  Stuff
%%%therm to kWh conversion (therm/kWh)
c1=1/29.31;

%%%Decision to optimize or analyze system(1=opt now)
opt_now=1;

%%%Run analysis file (1=yes, 0=no)
analysis_now=0;

%%% Save data from run
save_now=0;

%%%Bldgnum for analysis
bldgnum=14; %(ldn) 14 for AEC_ECM % 15-min data from 01/01/2015 00:00:00 to 12/31/2015 23:45:00
%(ldn) 13 for AEC

%%% Testing new constraints (1 = yes, 0 = no)
testing=0;

%%%Moving average on building energy profile
filtering=0;

%%%Node limit for optimization
max_nodes=100;
% max_nodes=1000;

%%%Converting YALMIP variables
convert_yalmip=1;

%%% Adding paths
empty_paths=0;
%% Adding any paths
addpath_list
%% Tech Selection 
tech_select
req_return_on=0;
tech_payment
ramp_adjust_on=1;
dg_ramp_conversion

%% Loading building data
close all
usecluster = 0; %1 for using the clustered methodology, 0 for optimizing for the entire year %(ldn)
bldg_loader
bldglist

%% Utility Data
utility
utility_tiers

%% Electricity Energy Costs
elec_vecs

%% Setting up variables and cost functions
deep_test=0;
opt_var_cf

%% General Equality Constraints
tic
opt_gen_equalities
gen_eq=toc

%% General Inequalities
tic
opt_gen_inequalities
gen_ineq=toc

%% DGHR Constraints
tic
opt_dghr
dghr_eq=toc

%% PV Constraints
tic
opt_pv
pv_eq=toc

%% HRU Constraints
tic 
opt_hru
hru_eq=toc

%% AC Constraints
tic 
opt_ac
ac_eq=toc

%% EES Constraints
tic 
opt_ees
ees_eq=toc
%% Optimize
clc
opt
if isempty(hru_v) == 0 && isempty(dghr_v) == 0
    value(dghr_adopt)
    value(hru_adopt)
    if isempty(acp_v) == 0
        acp_adopt=value(acp_adopt)
    elseif isempty(acs_v) == 0
        acs_adopt = value(acs_adopt)
    end
    bldgnum
end
%% Sorting Results
% opt_sort
%% Checking Results
if analysis_now == 1
    opt_analysis
end

%% Convert YALMIP Variables
if convert_yalmip == 1
    yalmip_conversion
end
%% Saving Results

filenameholder=char(bldglist(bldgnum));
if isempty(acs_v) == 0 && save_now == 1 && sum(dg_op_select)==0
    save_name=strcat('results\',filenameholder,'_acs');
    save(save_name)
elseif isempty(acs_v) == 0 && save_now == 1 && sum(dg_op_select)>0
    save_name=strcat('results\',filenameholder,'_acs_hourly');
    save(save_name)
elseif isempty(acp_v) == 0 && save_now == 1
    save_name=strcat('results\',filenameholder,'_acp');
    save(save_name)
end

%% (ldn) Printing Optimization Results and System Dynamics
pv_adopt
dghr_adopt
ees_adopt
ees_kW_adopt = max(ees_chrg)*4

%Calculating curtailment
curt = (solar_15*pv_adopt)- pv_elec;

x = 1:1:endpts(max(size(endpts)));
soc = 100*(ees_soc./ees_adopt);

%Plot dynamics for the entire year
figure
plot(x,pv_elec,'Color','b')
if dghr_adopt~=0;
hold on
plot(x,dghr_elec,'Color','r')
end
hold on
plot(x,import,'Color','g')
hold on
plot(x,export_grid,'Color','k')
hold on
[ax, h1, h2] = plotyy(x,ees_chrg,x,soc);
ylabel(ax(2),'SOC (%)')
legend(ax(2),'SOC (%)')
set(h1,'Color','c')
set(h2,'Color','m')
set(ax, 'xtick', [])
hold on
plot(x,ees_dchrg,'Color','y')
hold on
plot(x,bldgdata(1:max(size(x)),2),'Color','r')
hold on
title('15-min Energy Dynamics(kWh) ') 
ylabel('Energy (kWh)')
axis tight

if dghr_adopt~=0;
legend('PV','Fuel Cell','Import','Export','BESS Charge', 'BESS Discharge','AEC Loads') 
else
legend('PV','Import','Export','BESS Charge','BESS Discharge','AEC Loads') 
end

%% (ldn) Plotting Dynamics for a given interval "dlength" 
dlength= 10; %chooses number of days to plot
 
figure
plot(x(1:dlength*96),pv_elec(1:dlength*96),'Color',rgb('DarkOrange'))
hold on
if dghr_adopt~=0;
plot(x(1:dlength*96),dghr_elec(1:dlength*96),'Color','r')
hold on
end
plot(x(1:dlength*96),import(1:dlength*96),'Color','g')
hold on
plot(x(1:dlength*96),export_grid(1:dlength*96),'Color','k')
hold on
[ax, h1, h2] = plotyy(x(1:dlength*96),ees_chrg(1:dlength*96),x(1:dlength*96),soc(1:dlength*96));
ylabel(ax(2),'SOC (%)')
legend(ax(2),'SOC (%)')
set(h1,'Color','c')
set(h2,'Color','m')
%set(ax, 'Visible', 'off')
hold on
plot(x(1:dlength*96),ees_dchrg(1:dlength*96),'Color','y')
hold on
plot(x(1:dlength*96),bldgdata(1:dlength*96,2),'Color',rgb('Indigo'))
hold on 
plot(x(1:dlength*96),curt(1:dlength*96),'Color', rgb('Crimson'))
title('15-min Energy Dynaimcs(kWh) ') 
xlabel('15-min intervals')
ylabel('Energy (kWh)')
ylim([0 15000])

if dghr_adopt~=0;
legend('PV','Fuel Cell','Import','Export','BESS Charge', 'BESS Discharge','AEC Loads','Curtailed') 
else
legend('PV','Import','Export','BESS Charge','BESS Discharge','AEC Loads','Curtailed') 
end

