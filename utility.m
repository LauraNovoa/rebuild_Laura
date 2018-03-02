%% Loading Utility Informaiton

%%%Load SCE Energy Costs
ratedata = xlsread('SCE_Rate_Matrix.xlsx','GS8');

%%%Loading CO2 emission rates associated with the grid
load('co2_rates_example.mat');
co2_rates=co2_rates.*(0.650/mean(co2_rates));
grid_emissions(:,1)=co2_rates;

%%%%%%Natural Gas Prices%%%%%%
t1=0.8875;
t2=0.63164;
t3=0.46009;
tierv=[t1 t2 t3];

%%% Max gas use possible
if isempty(dghr_v) == 0
    max_gas=c1*(sum(elec(:,1))/min(dghr_v(4,:))+sum(heating)/boil_v(2));
elseif isempty(dghr_v) == 1 && isempty(boil_v) == 0
    max_gas=c1*(sum(heating)/boil_v(2));
end

ng_v=tierv;
if max_gas > 4167
    ng_use_v=[0;250;4167;max_gas];
else
    ng_use_v=[0;250;4167;5000];
end
    
ng_cost_v=0;
for i=1:length(tierv)
    ng_cost_v(i+1)=ng_cost_v(i)+(ng_use_v(i+1)-ng_use_v(i))*ng_v(i);
end

%%%RNG vector
%%%%%%%[Renewable Natural Gas Prices
%%%Carbon emissions per them of RNG (lbs/therm)]
rng_v=[1 2]; %%% $ per therm

%% Optimization/Analysis Constants

%%%Grid Electricity Cost ($/kWh)
e_rate=[ratedata(3:7,2)+ratedata(8:12,2)+(ratedata(1,2)+ratedata(2,2))*ones(5,1)];
%%%Demand Charge Vector
dc_nontou=ratedata(13,2); % Non Time of Use Demand Charge
dc_on=ratedata(14,2);%On Peak TOU DC
dc_mid=ratedata(15,2);%Mid Peak TOU DC
del1=dc_on+dc_mid-dc_nontou;%Demand Shifting
dc_v=[dc_nontou dc_on dc_mid del1];

tou_winter=[8;13;3];
tou_winter=[8  21];
tou_summer=[8;4;6;5;1];
tou_summer=[8 12 18 23];