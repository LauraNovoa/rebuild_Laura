%% HRU Constraints
if isempty(hru_v) == 0
    for i=1:size(hru_v,2)
        Constraints=[Constraints
            hru_heat(:,i) <= hru_adopt(i)]; %%%Min/Max HRU Size
        
%         0 <= hru_heat(:,i)
%             0 <= hru_adopt(i)
    end
    
    for i=1:size(ductp_v,2)
        if isempty(ductp_v) == 0
            Constraints=[Constraints
                ductp_heat(:,i) <= ductp_adopt(i)];
%             0 <= ductp_heat(:,i)
%                 0 <= ductp_adopt(i)
        end
    end
    
    for i=1:size(ducts_v,2)
        if isempty(ducts_v) == 0 && (isempty(ac_v) == 0 || isempty(acs_v) == 0 || isempty(acp_v) == 0)
            Constraints=[Constraints
                ducts_heat(:,i) <= ducts_adopt(i)];  
%             0 <= ducts_heat(:,i)
%                 0 <= ducts_adopt(i)
        end
    end
    
    %%%Heat into HRU from Ductp/ducts
    hru_eff=zeros(size(hru_heat));
    for i=1:size(hru_eff,1)
        hru_eff(i,:)=1./hru_v(3,:);
    end
    
    Constraints=[Constraints
        sum(hru_eff.*hru_heat,2) <= sum(ductp_heat,2) + sum(ducts_heat,2)];
end