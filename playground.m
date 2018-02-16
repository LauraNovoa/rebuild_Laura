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
bldgnum=13;
% 13 for AEC

%%% Testing new constraints (1 = yes, 0 = no)
testing=0;

%%%Moving average on building energy profile
filtering=2;

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

%% Optimization Results
pv_adopt
dghr_adopt
ees_adopt

%Plot dynamics for the entire year
figure
plot(pv_elec,'Color','b')
hold on
plot(dghr_elec,'Color','r')
hold on
plot(import,'Color','g')
hold on
plot(export_grid,'Color','k')
hold on
plot(ees_chrg,'Color','c')
hold on
plot(ees_dchrg,'Color','y')
hold on
plot(bldgdata(:,2),'Color','m')
title('15-min Energy Dynamics(kWh) ') 
ylabel('Energy [kWh]')
legend('PV','Fuel Cell','Import','Export','BESS Charge', 'BESS Discharge','AEC Loads') 

length= 14; %chooses number of days to plot
 
figure
plot(pv_elec(1:length*96),'Color','b')
hold on
plot(dghr_elec(1:length*96),'Color','r')
hold on
plot(import(1:length*96),'Color','g')
hold on
plot(export_grid(1:length*96),'Color','k')
hold on
plot(ees_chrg(1:length*96),'Color','c')
hold on
plot(ees_dchrg(1:length*96),'Color','y')
hold on
plot(bldgdata(1:length*96,2),'Color','m')
title('15-min Energy Dynaimcs(kWh) ') 
ylabel('Energy [kWh]')
legend('PV','Fuel Cell','Import','Export','BESS Charge', 'BESS Discharge','AEC Loads') 