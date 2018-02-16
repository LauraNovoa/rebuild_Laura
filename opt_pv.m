%% PV Constraints
if isempty(pv_v) == 0
    for i=1:size(pv_v,2)
        Constraints=[Constraints
            0<=pv_elec(:,i)<=solar.*pv_adopt(i)]; %PV Output is greater than zeros
    end
    
    Constraints=[Constraints
        pv_adopt./pv_v(2,:) <= bldg_v(1)]; %%% Area available for PV adoption
end