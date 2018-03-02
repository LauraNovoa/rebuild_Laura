%% PV Constraints
if isempty(pv_v) == 0
    for i=1:size(pv_v,2)
        
        %Constraints= [Constraints  
           %pv_elec(:,i) == solar.*pv_adopt(i)]; %PV Output follows PV profile
            
        %Constraints=[Constraints 
            %0>=pv_elec(:,i)]; %PV Output is greater than zero 
          
            %(ldn) fixing a bug
            if usecluster ==1 
                solar_15 = solar;
            end
            
        %PV Output is greater than zero and smaller than the max PV output
        %profile
        Constraints=[Constraints
            0<=pv_elec(:,i)<=solar_15.*pv_adopt(i)]; 
    end
    
    Constraints=[Constraints
        pv_adopt./pv_v(2,:) <= bldg_v(1)]; %%% Area available for PV adoption
end