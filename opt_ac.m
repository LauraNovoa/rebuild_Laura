%% ACs and AC Constraints

%% ACs
if isempty(acs_v) == 0
    for i=1:size(acs_v,2)
        Constraints=[Constraints
            acs_cool(:,i) <= acs_adopt(i)];
%         0 <= acs_cool(:,i)
%             0 <= acs_adopt(i)
    end
end

%% AC
if isempty(ac_v) == 0
    for i=1:size(ac_v,2)
        Constraints=[Constraints  
            ac_cool(1) == 0
            ac_cool(1:length(ac_op),i) <= ac_adopt(i)
            ac_cool(length(ac_op)+1:length(ac_cool),i) <= ac_adopt(i)            
            ac_cool(1:length(ac_op),i) <= 2*cooling_max.*ac_op(:,i) %%%AC Operational State
            ac_op(2:length(ac_op),i) - ac_op(1:length(ac_op)-1,i) <= ac_start(:,i) %%%AC Starting
            ac_v(5,i)*ac_adopt(i)  <= ac_chrg(:,i) + 2*cooling_max*(1 - ac_start(:,i))  %%%AC cooling is between 0 and installed AC capacity
            ac_v(6,i)*ac_adopt(i)  <= ac_cool(1:length(ac_op),i) + 2*cooling_max*(1 - ac_op(:,i))]; %%% AC output is limited by minimum chiller operation

    end
end

%% ACp
if isempty(acp_v) == 0
    for i=1:size(acp_v,2)
        Constraints=[Constraints
            acp_strg(1,i) <= 0.4*acp_v(6,i)*acp_adopt(i) %%%Requiring the first chiller storage setting to be less than fully charged  #1
            acp_strg(2:length(acp_strg),i) == acp_v(7,i).*acp_strg(1:length(acp_strg)-1,i) + acp_chrg(:,i) %%% Energy Balance for the AC  #2
            acp_strg(:,i) <= acp_v(6,i)*acp_adopt(i)]; %%%AC Storage is limited by adopted chiller size  #3

        
        if acp_v(end) == 1
            Constraints=[Constraints
                acp_cool(1:winter_time_count,i) <= (1/acp_v(6,i)).*acp_strg(1:winter_time_count,i) %%%Cooling output is limited by storage activation during the winter  
                acp_cool(1:winter_time_count,i) <= (2*cooling_max)*acp_op(:,i) %%%System is operaitonal whenever cooling is produced
                acp_v(8,i)*acp_adopt(i) <= acp_strg(:,i) + 2*cooling_max*(1-acp_op) %%%Cooling can only occur when the AC has been heated to a certian ammount
                acp_cool(2:winter_time_count,i) + acp_chrg(:,i) <= (1+acp_v(6,i)*(1-acp_v(7,i)))*acp_adopt(i) %%% energy into the system for cooling/charging is limited
                acp_cool(winter_time_count+1:endpts(length(endpts)),i) <= acp_adopt(i)]; %%%Cooling output is limited by adopted system during the summer
           
        elseif acp_v(end) == 0
            Constraints=[Constraints
                acp_cool(:,i) <= (1/acp_v(6,i)).*acp_strg(:,i) %%%Chiller output is limited by the charged state of the chiller  #4
                acp_cool(:,i) <= (2*cooling_max)*acp_op(:,i) %%%Chiller is operaitonal when cooling is produced  #5
                acp_v(6,i)*acp_v(8,i)*acp_adopt(i) <= acp_strg(:,i) + 2*cooling_max*(1-acp_op) %%%Chiller can be operational only if properly heated up  #6
                acp_cool(2:endpts(length(endpts)),i) + acp_chrg(:,i) <= (1+acp_v(6,i)*(1-acp_v(7,i)))*acp_adopt(i)]; %%% energy into the system for cooling/charging is limited  #7
            
        end
        
        
        
    end
end