%% Technology Selection
%% Utility is available
utility_exists=1;

%% PV
%%%Solar PV Vector 
%%% Cap cost ($/kW)(1)
%%% Efficiency / Conversion Percent at 1 kW/m^2 (2)
%%% O&M ($/kWh)(3)
pv_v=[2000; 0.2 ; 0.011]; %(ldn) changed O&M cost from 0.001 to 0.011 (NREL source)

%% Storage
%%%Electrical Energy Storage vector
%%% Capital Cost ($/kWh) (1)
%%% Charge O&M ($/kWh) (2)
%%% Discharge O&M ($/kWh) (3)
%%% Minimum state of charge (0 to 1)(4)
%%% Maximum state of charge(0 to 1) (5)
%%% Maximum charge rate (kWh per 15 minute/kWh storage) (6)
%%% Maximum discharge rate (kWh per 15 min/kWh storage) (7)
%%% Charging efficiency (8)
%%% Discharging efficiency (9)
%%% State of charge holdover (10)

ees_v1=[119.04; 0.5; 0.5; 0.1; 1; 0.25; 0.25; .95; .95; .995]; %(ldn) changed charge/discharge O&M to 0.5 (PNNL study)
%ees_v1=[200; 0.001; 0.001; 0.1; 0.95; 0.25; 0.25; .95; .95; .995];
%ees_v2=[195; 0.001; 0.001; 0.25; 0.99; 0.3; 0.3; .9; .85; .999];
ees_v=ees_v1;

%%%Thermal Energy Storage Vector
%%% Capital Cost ($/m^3)
%%% Charge O&M ($/kWh)
%%% Discharge O&M ($/kWh)
%%% Minimum state of charge
%%% Maximum state of charge
%%% Maximum charge rate (kWh per 15 minute/m^3 storage)
%%% Maximum discharge rate(kWh per 15 minute/m^3 storage)
%%% Charging efficiency
%%% Discharging efficieny
%%% State of charge holdover
%%% Heat capacity time density of fluid
tes_v1=[50; 0.0001; 0.0001; 0.05; 0.99; .25; .25; .95; .95; .999; 4.1813*1000];
tes_v=[tes_v1];

%% DG
%%% Capital Cost ($/kW)(1)
%%% O&M ($/kWh)(2)
%%% Capacity Increment (kW); Capacity 1 MW -> 1 MWh/4 (15 min) (3)
%%% Electrical Efficiency (%)(4)
%%% Ramp Up Rate (%/min)(5)
%%% Ramp Down Rate (%/min)(6)
%%% Minimum Power Setting (% of Capacity Increment)(7)
%%% Max fuel utilizaiton (%)(8)

ramp_rate=.0001; %Changed in 08/02 to make FC more baseload
%ramp_rate=.01; % in percent of overall capacity per minute
ramp_rate_gt=0.5;

%fc_size = 1000;%kW %Works... 07/21/17
fc_size= 250;%kW

%%%DG with HR capabilities
dghr_v1=[3800; 0.03; fc_size/4; .47; ramp_rate; ramp_rate; 0.5; .9]; %Fuel Cell

% dghr_v1=[100/4; .47; .023; 2800; ramp_rate; ramp_rate; 0.5; 1; 1; .2];
% dghr_v2=[1600; .02; 65/4; .25; ramp_rate_gt; ramp_rate_gt; 0.8; .9];
% dghr_v2=[900; .01; 65/4; .25; ramp_rate_gt; ramp_rate_gt; 0.3; .9];
% dghr_v1=[4000; .023; 1000/4; .47; ramp_rate; ramp_rate; 0.5;.1];
% dghr_v2=[1400; .01;  13500/4; .32; ramp_rate_gt; ramp_rate_gt; 8/13.5;.1];
% dghr_v1=[2000; 0.023; 100/4; .47; ramp_rate; ramp_rate; 0.5; .9];

% ramp_rate=.01;
% ramp_rate_gt=0.75;
% dghr_v1=[500; 0.01; 500/4; .50; ramp_rate; ramp_rate; 0.95; .9];
% dghr_v2=[1000; .02; 65/4; .35; ramp_rate_gt; ramp_rate_gt; 0.8; .9];

dghr_v= dghr_v1;
%dghr_v=[dghr_v1 dghr_v2];
% dghr_v=[];
%%%Turns on/off type of operation state seleciton between hourly state and
%%%TOU state (0 is hourly, 1 is TOU setup)
dg_op_select=[1]; % 1 = you have to have it ON for the TOU time window.

%% Heat Recovery
%%%HRU vector [Cap Cost ($/kW)
%%% O&M ($/kWh)
%%% efficiency (%)];
hru_v=[100; 0.001; 0.9];

%%%Ductwork used in parallel and in series linking to the HRU
%%%[Cap Cost ($/kW)]
%%% O&M ($/kWh)
%%% efficiency (%)];
ductp_v=[10; 0; 1;];
ducts_v=[10; 0; 1;];

%%%Absorption chiller vector [Cap Cost; 1
%%%O&M; 2
%%%COP; 3
%%%Ammount of heat required to transfer 1 kWh of heat to AC 4
%%%Cost to charge the AC($/kWh) 5
%%%Heat required to activate AC (kWh_storage / kWh_production) 6
%%%Heat retained from prior period 7
%%%Minimum cooling output from chiller]; 8
% acp_v=[170; 0.0266; 1.08; 1.78; 0.001; 0.6037; 0.95; 0.5];
% ac_v=[];

%%%Absorption chiller partial/simple model [Cap Cost; 1
%%%O&M; 2
%%%COP; 3
%%%Ammount of heat required to transfer 1 kWh of heat to AC 4
%%%Heat required to activate AC (kWh_capacity / kWh_storage) 5
%%%Minimum cooling output (% of max cooling output) 6
ac_v=[170; 0.0266; 1.08; 1.78; 0.6037; .8];
ac_v=[170; 0.0266; 1.08; 1.78; 0.6037; .4];

%%%Absorption chiller vector [Cap Cost; 1
%%%O&M; 2
%%%COP; 3
%%%Ammount of heat required to transfer 1 kWh of heat to AC 4
%%%Cost to charge the AC($/kWh) 5
%%%Heat required to activate AC (kWh_storage / kWh_production) 6
%%%Heat retained from prior period 7
%%%Minimum cooling output from chiller]; 8
%%%Index indicates partial or full constraint set (0 for all, 1 for winter only) 9
acp_v=[170; 0.0266; 1.08; 1.78; 0.001; 0.6037; 0.95; 0.5; 0];
% acp_v=[1; 0.01; 1.08; 1.78; 0.0001; 0.6037; 0.98; 0.5; 1];

%%%Simplified absorption chiller vector [ Cap Cost
%%%O&M ($/kWh)
%%%COP
%%%Ammount of heat required to transfer 1 kWh of heat to AC
acs_v=[170; 0.0266; 1.08; 1.78];
% acs_v=[0; 0.0266; 1.08; 1.78];


%% Legacy Technology

%%%Vapor Compression Chiller Vector
vc_cop=3.4;%VC COP
vc_om=0.0139734;%O&M of VC chiller ($/kWh)
% vc_om=ac_v(2)
vc_v=[vc_om; vc_cop];

%%%Boiler Vector
eff_b=0.9;%Efficiency of boiler
c_omb=0.001; %O&M Cost of Boiler

boil_v=[c_omb; eff_b];

%% Building information:
%%%[space available for PV (m^2)
%%%Cooling loop input (C)
%%%Cooling loop output (C)
%%%Building cooling side (C)
bldg_v=[10000000000; 10; 18; 15];

%% Open Tech %Comment the technologies you want to use
dghr_v=[];
hru_v=[];

ac_v=[];
acs_v=[];
acp_v=[];

% ees_v=[];
tes_v=[];

% pv_v=[];

ductp_v=[];
ducts_v=[];

% if isempty(hru_v)==1
%     ductp_v=[];
% end
% if (isempty(ac_v)==1 && isempty(acp_v)==1) || isempty(hru_v)==1
%     ducts_v=[];
% end