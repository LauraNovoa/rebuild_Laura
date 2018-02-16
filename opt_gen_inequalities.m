%% General Inequalities
%% Demand Charges
if utility_exists == 1
    %%%NonTOU Demand Charges
    for i=1:length(endpts)
        if i==1
            Constraints=[Constraints
                import(1:endpts(1))<=nontou_dc(i)];
        else
            Constraints=[Constraints
                import(endpts(i-1)+1:endpts(i))<=nontou_dc(i)];
        end
    end
    
    for i=1:length(summer_month)
        if summer_month(i)==1
            start=1;
            finish=endpts(summer_month(i));
        else
            start=endpts(summer_month(i)-1)+1;
            finish=endpts(summer_month(i));
        end
        
        for j=start:finish
            if weekday(time(j))~=1 && weekday(time(j))~=7
                if (datetimev(j,4)>=8&&datetimev(j,4)<12 )...
                        || (datetimev(j,4)>=18&&datetimev(j,4)<23)
                    Constraints=[Constraints
                        import(j)<=midpeak_dc(i)];
                elseif datetimev(j,4)>=12 && datetimev(j,4)<18
                    Constraints=[Constraints
                        import(j)<=onpeak_dc(i)];
                end
            end
            
        end
    end
end

%% Limiting Import and Export
 
export_limit = 500 % kWh
import_limit = 500 % kWh

Constraints=[Constraints, import <= import_limit];
 
Constraints=[Constraints, export_grid <= export_limit];
 
%% ldn 08/02/2017
%Limits FC to produce more than Net load = AEC load - PV - BESS_Dch

%Constraints=[Constraints, dghr_elec <= elec(1:endpts(length(endpts)),1) - pv_elec - ees_dchrg];
Constraints=[Constraints, dghr_elec <= elec(1:endpts(length(endpts)),1)];
%% Natural Gas
for i=1:length(endpts)
    Constraints=[Constraints
        lambda(1,i) - sig(1,i) <= 0
        lambda(2,i) - sig(1,i) - sig(2,i) <= 0
        lambda(3,i) - sig(2,i) - sig(3,i) <= 0
        lambda(4,i) - sig(3,i) <= 0];
end
%% Heat Recovery from DG
if isempty(dghr_v) ==0  &&...
        (isempty(hru_v) == 0)
    
    %%%Availabe DG heat coefficients
    dghr_avail_heat=zeros(size(dghr_fuel));
    for i=1:size(dghr_fuel,1)
        dghr_avail_heat(i,:)=(dghr_v(8,:)-dghr_v(4,:));
    end
    
    %%%Effectiveness of duct directly to HRU
    if isempty(ductp_v) == 0
        ductp_eff=zeros(size(ductp_heat));
        for i=1:size(ductp_eff,1)
            ductp_eff(i,:)=1./ductp_v(3,:);
        end
    else
        ductp_eff=zeros(size(import,1),1);
    end
    
    %%% Effective ACs COP
    if isempty(acs_v) == 0
        acs_cop=zeros(size(acs_cool));
        for i=1:size(acs_cop,1)
            acs_cop(i,:)=acs_v(4,:)./acs_v(3,:);
        end
    else
        acs_cop=zeros(size(import,1),1);
    end
    
    if isempty(ac_v) == 0
        %%%Effective AC COP
        if isempty(ac_v) == 0
            ac_cop=zeros(size(ac_cool));
            ac_chrg_eff=zeros(size(ac_chrg));
            for i=1:size(ac_cop,1)
                ac_cop(i,:)=ac_v(4,:)./ac_v(3,:);
                if i <= length(ac_chrg)
                    ac_chrg_eff(i,:)=ac_v(4,:);
                end
            end
        end
        
        
        Constraints=[Constraints
            sum(ductp_eff(1,:).*ductp_heat(1,:),2) + sum(acs_cop(1,:).*acs_cool(1,:),2) + sum(ac_cop(1,:).*ac_cool(1,:),2) <= sum(dghr_avail_heat(1,:).*dghr_fuel(1,:),2)
            sum(ductp_eff(2:winter_time_count,:).*ductp_heat(2:winter_time_count,:),2) + sum(acs_cop(2:winter_time_count,:).*acs_cool(2:winter_time_count,:),2) + sum(ac_cop(2:winter_time_count,:).*ac_cool(2:winter_time_count,:),2) + sum(ac_chrg_eff.*ac_chrg,2) <= sum(dghr_avail_heat(2:winter_time_count,:).*dghr_fuel(2:winter_time_count,:),2)
            sum(ductp_eff(winter_time_count+1:length(import),:).*ductp_heat(winter_time_count+1:length(import),:),2) + sum(acs_cop(winter_time_count+1:length(import),:).*acs_cool(winter_time_count+1:length(import),:),2) + sum(ac_cop(winter_time_count+1:length(import),:).*ac_cool(winter_time_count+1:length(import),:),2) <= sum(dghr_avail_heat(winter_time_count+1:length(import),:).*dghr_fuel(winter_time_count+1:length(import),:),2)];
        
    elseif isempty(acp_v) == 0
        acp_cop=zeros(size(acp_cool));
        acp_chrg_eff=zeros(size(acp_chrg));
        for i=1:size(acp_cop,1)
            acp_cop(i,:)=acp_v(4,:)./acp_v(3,:);
            if i <= length(acp_chrg)
                acp_chrg_eff(i,:)=acp_v(4,:);
            end
        end
        if acp_v(end) == 0
            Constraints=[Constraints
                sum(ductp_eff(1,:).*ductp_heat(1,:),2) + sum(acs_cop(1,:).*acs_cool(1,:),2) + sum(acp_cop(1,:).*acp_cool(1,:),2) <= sum(dghr_avail_heat(1,:).*dghr_fuel(1,:),2)
                sum(ductp_eff(2:endpts(end),:).*ductp_heat(2:endpts(end),:),2) + sum(acs_cop(2:endpts(end),:).*acs_cool(2:endpts(end),:),2) + sum(acp_cop(2:endpts(end),:).*acp_cool(2:endpts(end),:),2) + sum(acp_chrg_eff.*acp_chrg,2) <= sum(dghr_avail_heat(2:endpts(end),:).*dghr_fuel(2:endpts(end),:),2)];
            
        elseif acp_v(end) == 1
            Constraints=[Constraints
                sum(ductp_eff(1,:).*ductp_heat(1,:),2) + sum(acs_cop(1,:).*acs_cool(1,:),2) + sum(acp_cop(1,:).*acp_cool(1,:),2) <= sum(dghr_avail_heat(1,:).*dghr_fuel(1,:),2)
                sum(ductp_eff(2:winter_time_count,:).*ductp_heat(2:winter_time_count,:),2) + sum(acs_cop(2:winter_time_count,:).*acs_cool(2:winter_time_count,:),2) + sum(acp_cop(2:winter_time_count,:).*acp_cool(2:winter_time_count,:),2) + sum(acp_chrg_eff.*acp_chrg,2) <= sum(dghr_avail_heat(2:winter_time_count,:).*dghr_fuel(2:winter_time_count,:),2)
                sum(ductp_eff(winter_time_count+1:endpts(end),:).*ductp_heat(winter_time_count+1:endpts(end),:),2) + sum(acs_cop(winter_time_count+1:endpts(end),:).*acs_cool(winter_time_count+1:endpts(end),:),2) + sum(acp_cop(winter_time_count+1:endpts(end),:).*acp_cool(winter_time_count+1:endpts(end),:),2) <= sum(dghr_avail_heat(winter_time_count+1:endpts(end),:).*dghr_fuel(winter_time_count+1:endpts(end),:),2)];
            
        end
    else
        Constraints=[Constraints
            sum(ductp_eff.*ductp_heat,2) + sum(acs_cop.*acs_cool,2) <= sum(dghr_avail_heat.*dghr_fuel,2)];
        
    end
end
%% Heat Recovered from AC
if isempty(dghr_v) == 0 &&...
        (isempty(acs_v) == 0 || isempty(ac_v) == 0 || isempty(acp_v) == 0) && ...
        isempty(ducts_v) == 0
    
    %%%Ducts effectiveness
    ducts_eff=zeros(size(ducts_heat));
    for i=1:size(ducts_eff,1)
        ducts_eff(i,:)=1./ducts_v(3,:);
    end
    
    %%%heat remaning from ACs
    if isempty(acs_v) == 0
        acs_rem_heat=zeros(size(acs_cool));
        for i=1:size(acs_rem_heat,1)
            acs_rem_heat=(acs_v(4,:)-1)./acs_v(3,:);
        end
    else
        acs_rem_heat=zeros(size(import,1),1);
    end
    
    %%%heat remaning from AC
    if isempty(ac_v) == 0
        ac_rem_heat=zeros(size(ac_cool));
        for i=1:size(ac_rem_heat,1)
            ac_rem_heat=(ac_v(4,:)-1)./ac_v(3,:);
        end
    else
        ac_rem_heat=zeros(size(import,1),1);
    end
    
    %%%heat remaning from ACp
    if isempty(acp_v) == 0
        acp_rem_heat=zeros(size(acp_cool));
        for i=1:size(acp_rem_heat,1)
            acp_rem_heat=(acp_v(4,:)-1)./acp_v(3,:);
        end
    else
        acp_rem_heat=zeros(size(import,1),1);
    end
    
    Constraints=[Constraints
        sum(ducts_eff.*ducts_heat,2) <= sum(ac_rem_heat.*ac_cool,2) + sum(acs_rem_heat.*acs_cool,2) + sum(acp_rem_heat.*acp_cool,2)];
end