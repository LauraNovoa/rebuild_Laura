%%% EES Constraints

if isempty(ees_v) == 0
    for i=1:size(ees_v,2)
        Constraints=[Constraints
            ees_soc(2:endpts(length(endpts)),i) == ees_v(10,i).*ees_soc(1:endpts(length(endpts))-1,i) + ees_v(8,i).*ees_chrg(2:endpts(length(endpts)),i) - (1/ees_v(9,i)).*ees_dchrg(2:endpts(length(endpts)),i) %%%EES Energy Balance
            ees_v(4,i)*ees_adopt(i) <= ees_soc(:,i) <= ees_v(5,i)*ees_adopt(i) %%%Min/Max EES SOC
            0 <= ees_chrg(:,i) <= ees_v(6,i)*ees_adopt(i) %%% Charging limited to adopted EES size
            0 <= ees_dchrg(:,i) <= ees_v(7,i)*ees_adopt(i)]; %%% Discharging limited to adopted EES size
    end
end

