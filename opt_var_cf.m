%% Declaring decision variables and setting up cost function
yalmip('clear')
Objective=[];

%% Utility Electricity
if isempty(utility_exists)==0
    %Import decision variable
    import=sdpvar(endpts(length(endpts)),1,'full');
    %Demand decision variables
    nontou_dc=sdpvar(length(endpts),1,'full');
    onpeak_dc=sdpvar(length(summer_month),1,'full');
    midpeak_dc=sdpvar(length(summer_month),1,'full');
    
    Objective=import'*import_price+...%%%Electrical energy import cost
        sum(util_mod*4*dc_nontou*nontou_dc)+...%%%nonTOU DC
        sum(util_mod*4*dc_on*onpeak_dc)+...%%%On Peak DC
        sum(util_mod*4*dc_mid*midpeak_dc);%%%Mid peak DC

    %(ldn)Export decision variable
    export_grid=sdpvar(endpts(length(endpts)),1,'full'); 
    
    Objective=Objective+...
        (-1)*export_grid'*export_price; %%% (ldn) Revenue from energy export
    
    index2_import=[1 endpts(length(endpts))];
    index2_nontou_dc=[max(index2_import)+1 max(index2_import)+length(endpts)];
    if isempty(summer_month) == 0
        index2_on_dc=[max(index2_nontou_dc)+1 max(index2_nontou_dc)+length(summer_month)];
        index2_mid_dc=[max(index2_on_dc)+1 max(index2_on_dc)+length(summer_month)];
    else
        index2_mid_dc=index2_nontou_dc;
        
    end

else
    import=zeros(endpts(length(endpts)),1);
    nontou_dc=zeros(length(endpts),1);
    onpeak_dc=zeros(length(summer_month),1);
    midpeak_dc=zeros(length(summer_month),1);
end
%% Utility Natural Gas
lambda=sdpvar(4,length(endpts),1,'full');
sig=binvar(3,length(endpts),1,'full');

for i=1:length(endpts)
    Objective=Objective+...
        (ng_cost_v*lambda(:,i));
    
    index_lambda(i,:)=[max(index2_mid_dc)+1+4*(i-1) max(index2_mid_dc)+4*(i)];
    index_sos(i,:)=[max(index_lambda(i,:))+1+3*(i-1) max(index_lambda(i,:))+3*(i)];
end

%% Legacy Boiler
if isempty(boil_v)==0
    boil=sdpvar(endpts(length(endpts)),1,'full');
    boilr=sdpvar(endpts(length(endpts)),1,'full');
    
    Objective=Objective+ boil_v(1)*sum(boil) ... %%% O&M for typical boiler operation
        + c1*(1/boil_v(2))*rng_v(1)*boil_v(1)*sum(boilr); %%% O&M for renewable fired boiler
    
%     index2_boil=[max(max(index2_sos))+1 max(max(index2_sos))+endpts(length(endpts))];
else
    boil=zeros(endpts(length(endpts)),1);
    boilr=zeros(endpts(length(endpts)),1);
end
%% Legacy VC
if isempty(vc_v)==0
    vc_cool=sdpvar(endpts(length(endpts)),1,'full');
    
    Objective=Objective+vc_v(1)*sum(vc_cool);%%%VC Cooling Output
    
else
    vc_cool=zeros(endpts(length(endpts)),1);
end
%% Adopted Technologies
%%
%% Solar PV
if isempty(pv_v) == 0
    pv_elec=sdpvar(endpts(length(endpts)),size(pv_v,2),'full'); %(kWh)
    pv_adopt=sdpvar(1,size(pv_v,2),'full'); %(kW)
    
    for i=1:size(pv_v,2)
        Objective=Objective+...
            pv_v(3,i)*sum(pv_elec(:,i)) +... %%%O&M ($/kWh)
            cap_mod*pv_v(1,i)*length(endpts)*pv_adopt(i); %%% Capital(Payments)($/kW/month)
    end    
else
    pv_elec=zeros(endpts(length(endpts)),1);
end
%% Electrical Energy Storage
if isempty(ees_v) == 0
    %%% Adopted EES Size (kWh)
    ees_adopt=sdpvar(1,size(ees_v,2),'full');
    %%% EES Charging (kWh)
    ees_chrg=sdpvar(endpts(length(endpts)),size(ees_v,2),'full');
    %%% EES Discharging (kWh)
    ees_dchrg=sdpvar(endpts(length(endpts)),size(ees_v,2),'full');
    %%% EES SOC (kWh)
    ees_soc=sdpvar(endpts(length(endpts)),size(ees_v,2),'full');
    
    %%%EES Cost Function Addition
    for i=1:size(ees_v,2)
        Objective=Objective+...
            cap_mod*length(endpts)*ees_v(1)*ees_adopt(i)+... %%%EES Capital Investment (Payments) ($/kWh)
            ees_v(2)*sum(ees_chrg(:,i))+... %%% EES Charging O&M ($/kWh)
            ees_v(3)*sum(ees_dchrg(:,i)); %%% EES Discharging O&M ($/kWh)
    end
    
else
    ees_chrg=zeros(endpts(length(endpts)),1);
    ees_dchrg=zeros(endpts(length(endpts)),1);
end

%% DGHR
if isempty(dghr_v)==0
    
    dghr_elec=sdpvar(endpts(end),size(dghr_v,2),'full');
    dghr_fuel=sdpvar(endpts(end),size(dghr_v,2),'full');
    dghr_fuelr=sdpvar(endpts(end),size(dghr_v,2),'full');
    
    
    dghr_adopt=intvar(1,size(dghr_v,2),'full');
    
    op_select=[0 0];
    
    %%%Determining number of op variables to set
    for i=1:size(dghr_v,2)
        if dg_op_select(i)==0
            op_select(1)=op_select(1)+1;
        else
            op_select(2)=op_select(2)+1;
        end
    end
    
    %%%Hourly Operation
    if op_select(1)>0
        %%%Operaitonal States
        dghr_on=intvar(ceil(endpts(length(endpts))/4),op_select(1),'full');
        %%%Starting Index
        dghr_start=intvar(ceil(endpts(length(endpts))/4)-1,op_select(1),'full');
    end
    
    %%%Time of use operation
    if op_select(2)>0
        %%%Operaitonal States
        dghr_on_tou=intvar(length(tou_block),op_select(2),'full');
        %%%Starting Index
        dghr_start_tou=sdpvar(length(tou_block)-1,op_select(2),'full');
    end
    
    for i=1:size(dghr_v,2)
        Objective=Objective + sum(dghr_v(2,i).*dghr_elec(:,i)) ... %%% O&M
            + cap_mod*4*length(endpts)*dghr_v(1,i)*dghr_v(3,i).*dghr_adopt(i) ... %%%Capital Cost
            + c1*rng_v(1)*sum(dghr_fuelr(:,i)); %%% Renewable Fuel Cost
        
        if deep_test == 1       
            if dghr_v(4,i) == .47
                Objective=Objective+0.0532*sum(dghr_on(:,i))+0.00532*sum(dghr_start(:,i))+0.000532*sum(dghr_fuel(:,i));
            else                
                Objective=Objective+0.0632*sum(dghr_on(:,i))+0.00632*sum(dghr_start(:,i))+0.000632*sum(dghr_fuel(:,i));
            end
        end        
    end

    
else
    dghr_elec=zeros(endpts(end),1);
    dghr_fuel=zeros(endpts(end),1);
    dghr_fuelr=zeros(endpts(end),1);
    dghr_adopt=0;
end

%% HRU
if isempty(hru_v)==0
    for i=1:size(hru_v,2)
        %%%Adopted HRU
        hru_adopt=sdpvar(1,size(hru_v,2),'full');
        %%%HRU Output
        hru_heat=sdpvar(endpts(length(endpts)),size(hru_v,2),'full');
        
        Objective=Objective+...
            hru_v(2,i)*sum(hru_heat(:,i))+...
            cap_mod*4*hru_v(1)*length(endpts)*hru_adopt(i);
    end
else
    hru_heat=zeros(endpts(length(endpts)),1);
end

%% Ductp
if isempty(ductp_v) == 0
    for i=1:size(ductp_v,2)
        %%%Adopted Ductp Size
        ductp_adopt=sdpvar(1,size(ductp_v,2),'full');
        %%%Ductp Output
        ductp_heat=sdpvar(endpts(length(endpts)),size(ductp_v,2),'full');
        
        Objective=Objective+...
            ductp_v(2,i)*sum(ductp_heat(:,i))+...
            cap_mod*4*ductp_v(1,i)*length(endpts)*ductp_adopt(i);
    end
else
    ductp_heat=zeros(endpts(length(endpts)),1);
end
%% Ducts
if isempty(ducts_v) == 0 && (isempty(acs_v) == 0 || isempty(ac_v) == 0 || isempty(acp_v) == 0)
    for i=1:size(ducts_v,2)
        %%%Adopted ducts Size
        ducts_adopt=sdpvar(1,size(ducts_v,2),'full');
        %%%ducts Output
        ducts_heat=sdpvar(endpts(length(endpts)),size(ducts_v,2),'full');
        
        Objective=Objective+...
            ducts_v(2,i)*sum(ducts_heat(:,i))+...
            cap_mod*4*ducts_v(1,i)*length(endpts)*ducts_adopt(i);
    end
else
    ducts_heat=zeros(endpts(length(endpts)),1);
end
%% ACs
if isempty(acs_v) == 0
    for i=1:size(acs_v,2)
        %%%Adopted ACs Size
        acs_adopt=sdpvar(1,size(acs_v,2),'full');
        %%%ACs cooling output
        acs_cool=sdpvar(endpts(length(endpts)),size(acs_v,2),'full');
        
        Objective=Objective+...
            acs_v(2,i)*sum(acs_cool(:,i))+...
            cap_mod*4*acs_v(1,i)*length(endpts)*acs_adopt(i);
    end
else
    acs_cool=zeros(endpts(length(endpts)),1);
end
%% AC
if isempty(ac_v) == 0
    
    winter_time_count=0;
    for i=1:size(datetimev,1)
        if (datetimev(i,2)<6 || datetimev(i,2)>=10) && datetimev(i,1)~=0
            winter_time_count=winter_time_count+1;
        end
    end
    
    for i=1:size(ac_v,2)
        %%%Adopted AC Size
        ac_adopt=sdpvar(1,size(ac_v,2),'full');
        %%%AC Cooling Output
        ac_cool=sdpvar(endpts(length(endpts)),size(ac_v,2),'full');
        %%% AC Operation
        ac_op=binvar(winter_time_count,size(ac_v,2),'full');
        %%%AC start
        ac_start=sdpvar(winter_time_count-1,size(ac_v,2),'full');
        %%%AC Starting Energy
        ac_chrg=sdpvar(winter_time_count-1,size(ac_v,2),'full');
        
        Objective=Objective+...
            ac_v(2,i)*sum(ac_cool(:,i))+...
            cap_mod*4*ac_v(1,i)*length(endpts)*ac_adopt(i);        
%                     (1/10).*ac_v(2,i)*sum(ac_chrg(:,i))+...
        if deep_test == 1
            Objective=Objective+...
                0.762*sum(ac_op)+...
                0.0762*sum(ac_start);            
        end
    end
else
    ac_cool=zeros(endpts(length(endpts)),1);
end

%% ACp
if isempty(acp_v) == 0
    winter_time_count=0;
    for i=1:size(datetimev,1)
        if (datetimev(i,2)<6 || datetimev(i,2)>=10) && datetimev(i,1)~=0
            winter_time_count=winter_time_count+1;
        end
    end
    
    %%%Adopted ACp
    acp_adopt=sdpvar(1,size(acp_v,2),'full');
    %%% ACp Output
    acp_cool=sdpvar(endpts(length(endpts)),size(acp_v,2),'full');
    
    %%%Declaring variables based on if the thermal mass is associated with
    %%%the entire data set or jsut during winter
    if acp_v(end) == 1
        %%% ACp charging
        acp_chrg=sdpvar(winter_time_count-1,size(acp_v,2),'full');        
        %%%ACp Storage
        acp_strg=sdpvar(winter_time_count,size(acp_v,2),'full');
        %%%ACp op
        acp_op=binvar(winter_time_count,size(acp_v,2),'full');
       
    elseif acp_v(end) == 0
        %%% ACp charging
        acp_chrg=sdpvar(endpts(length(endpts))-1,size(acp_v,2),'full');        
        %%%ACp Storage
        acp_strg=sdpvar(endpts(length(endpts)),size(acp_v,2),'full');
        %%%ACp op
        acp_op=binvar(endpts(length(endpts)),size(acp_v,2),'full');
                
    end
        
    for i=1:size(acp_v,2)
        Objective=Objective+...
            acp_v(2,i)*sum(acp_cool(:,i))+...
            acp_v(5,i)*sum(acp_chrg(:,i))+...
            cap_mod*4*acp_v(1,i)*length(endpts)*acp_adopt(i);

    end
    
else
    acp_cool=zeros(endpts(length(endpts)),1);
end

