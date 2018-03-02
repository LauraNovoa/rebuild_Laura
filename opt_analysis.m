%% Checcking Demand Charges
load_now=1;

if load_now==1
    clear all, clc
    load('results\Long Beach VA_acp')
end
return
%%
%%%NonTOU DCs
for i=1:length(endpts)
    if i == 1
        start=1;
        finish=endpts(1);
    else
        start=endpts(i-1)+1;
        finish=endpts(i);
    end
    check_nonTOU_DC(i,:)=[max(value(import(start:finish))) value(nontou_dc(i))];
end

%%%TOU DC
count_mid=1;
count_on=1;
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
                    mid_load(count_mid,1)=value(import(j));
                    count_mid=count_mid+1;
                    elseif datetimev(j,4)>=12 && datetimev(j,4)<18
                        on_load(count_on,1)=value(import(j));
                        count_on=count_on+1;
                 end
            end
        end
        check_TOU_dc=[max(mid_load) value(midpeak_dc(i)) max(on_load) value(onpeak_dc)];
 end
 
%% Checking fuel use
for i=1:length(endpts)
    if i == 1
        start=1;
        finish=endpts(1);
    else
        start=endpts(i-1)+1;
        finish=endpts(i);
    end
    check_ng_use=[ng_use_v'*value(lambda(:,i)) ...
        c1*(sum((1/boil_v(2)).*value(boil(start:finish)))+sum(sum(value(dghr_fuel(start:finish,:)))))];
end

%% Plotting Electrical Operaiton
close all

figure
subplot(1,2,1)
hold on
plot((value(import)+sum(value(dghr_elec),2)).*4,'LineWidth',2,'Color',[0.8 0 0])
plot(sum(value(dghr_elec),2).*4,'LineWidth',2,'Color',[0 .5 0])
plot(value(dghr_elec(:,1)).*4,'LineWidth',2,'Color',[0 0 1])
legend('Import','GT','FC')
box on
ylabel('Elec (kW)','FontSize',16)
xlim([1 endpts(length(endpts))])
hold off

subplot(1,2,2)
hold on
plot((elec(1:endpts(length(endpts)),2)+value(vc_cool.*vc_cop)).*4,'LineWidth',2)
plot(elec(1:endpts(length(endpts)),2).*4,'LineWidth',2)
xlim([1 endpts(length(endpts))])
box on
hold off
%% Heating Operaiton
figure
subplot(1,2,1)
hold on
plot(value(boil)+sum(value(hru_heat),2),'LineWidth',2,'Color',[.0 0 .8])
plot(value(hru_heat),'LineWidth',2,'Color',[.8 0 0])
legend('Boil','HRU')
box on
xlim([1 endpts(length(endpts))])
title('Heating','FontSize',16)
hold off

subplot(1,2,2)
hold on
plot(value(ducts_heat+ductp_heat),'LineWidth',2,'Color',[0 0 .8])
plot(value(ducts_heat),'LineWidth',2,'Color',[0.8 0 .0])
box on
title('Heat from Ducts','FontSize',16)
legend('Ductp','Ducts')
xlim([1 endpts(length(endpts))])
hold off
%% Plotting Cooling Operation
figure
hold on
plot(value(vc_cool+acp_cool+acs_cool).*4,'LineWidth',2,'Color',[0 0 .8])
plot(value(acp_cool+acs_cool).*4,'LineWidth',2,'Color',[.8 0 0])
plot(value(acp_cool).*4,'LineWidth',2,'Color',[0 .5 0])
legend('VC','ACs','ACp')
ylabel('Cooling','FontSize',16)
box on
xlim([1 endpts(length(endpts))])
hold off


%% Plotting Min/Max of the generators
close all
dghr_op_15min=zeros(size(dghr_elec));

hour_count=1;
tou_count=1;

dghr_op_15min=[];
for j=1:size(dghr_v,2)
    if dg_op_select(j) == 0
        for i=1:length(dghr_on)
            dghr_op_15min(1+4*(i-1):4*i,j)=dghr_on(i,hour_count);
        end
        hour_count=hour_count+1;
    elseif dg_op_select(j) == 1
        
        for i=1:length(tou_block)
            if i==1
                start=1;
                finish=tou_block(1);
            else
                start=sum(tou_block(1:i-1))+1;
                finish=sum(tou_block(1:i));
            end
            
            for k=start:finish
                dghr_op_15min(k,j)=dghr_on_tou(i);
            end
            tou_count=tou_count+1;
        end
    end
end
figure
subplot(1,2,1)
hold on
plot(dghr_op_15min(:,1),'LineWidth',2,'Color',[0 0 1])
box on
xlim([1 endpts(length(endpts))])
title('DGHR Ops','LineWidth',16)
hold off

subplot(1,2,2)
hold on
plot(dghr_op_15min(:,2),'LineWidth',2,'Color',[0 0 1])
box on
xlim([1 endpts(length(endpts))])
hold off

close all
figure 
subplot(1,2,1)
hold on
plot(dghr_v(5,1)*dghr_v(3,1)*dghr_op_15min(2:length(dghr_op_15min),1),'LineWidth',2,'Color',[0 0 1])
plot(-dghr_v(6,1)*dghr_v(3,1)*dghr_op_15min(2:length(dghr_op_15min),1),'LineWidth',2,'Color',[0 0 1])
plot(value(dghr_elec(2:length(dghr_elec),1)-dghr_elec(1:length(dghr_elec)-1,1)),'LineWidth',1,'Color',[.8 0 0])
box on
xlim([1 endpts(length(endpts))])
title('Ramping Limits','LineWidth',16)
hold off

subplot(1,2,2)
hold on
plot(dghr_v(5,2)*dghr_v(3,2)*dghr_op_15min(2:length(dghr_op_15min),2),'LineWidth',2,'Color',[0 0 1])
plot(-dghr_v(6,2)*dghr_v(3,2)*dghr_op_15min(2:length(dghr_op_15min),2),'LineWidth',2,'Color',[0 0 1])
plot(value(dghr_elec(2:length(dghr_elec),2)-dghr_elec(1:length(dghr_elec)-1,2)),'LineWidth',1,'Color',[.8 0 0])
box on
xlim([1 endpts(length(endpts))])
title('Ramping Limits','LineWidth',16)
hold off





figure
subplot(1,2,1)
hold on
plot(dghr_v(3,1)*dghr_op_15min(:,1),'LineWidth',2,'Color',[0 0 1])
plot(dghr_v(7,1)*dghr_v(3,1)*dghr_op_15min(:,1),'LineWidth',2,'Color',[0 0 1])
plot(value(dghr_elec(:,1)),'LineWidth',1,'Color',[.8 0 0])
box on
xlim([1 endpts(length(endpts))])
title('Min/Max Power Output','LineWidth',16)
hold off

subplot(1,2,2)
hold on
plot(dghr_v(3,2)*dghr_op_15min(:,2),'LineWidth',2,'Color',[0 0 1])
plot(dghr_v(7,2)*dghr_v(3,2)*dghr_op_15min(:,2),'LineWidth',2,'Color',[0 0 1])
plot(value(dghr_elec(:,2)),'LineWidth',1,'Color',[.8 0 0])
box on
xlim([1 endpts(length(endpts))])
hold off


% for i=1:length(dghr_on)
%     for j=1:4
%         dghr_op_15min=[dghr_op_15min
%             value(dghr_on(i,:))];
%     end
% end
% 
% close all
% figure
% subplot(1,2,1)
% hold on
% plot(dghr_v(3,:).*dghr_op_15min,'LineWidth',2)
% plot(dghr_v(7,:).*dghr_v(3,:).*dghr_op_15min,'LineWidth',2)
% 
% hold off
        
%% HEat Captured vs available heat

close all
figure
hold on
if isempty(acp_v) == 0
    plot(value(sum(ductp_eff(2:endpts(end),:).*ductp_heat(2:endpts(end),:),2)+sum(acp_cop(2:endpts(end),:).*acp_cool(2:endpts(end),:),2)+sum(acp_chrg_eff.*acp_chrg,2)),'LineWidth',2,'Color',[0 0 .8])
    plot(value(sum(ductp_eff(2:endpts(end),:).*ductp_heat(2:endpts(end),:),2)+sum(acp_cop(2:endpts(end),:).*acp_cool(2:endpts(end),:),2)),'LineWidth',2,'Color',[0 .5 0])
    plot(value(sum(ductp_eff(2:endpts(end),:).*ductp_heat(2:endpts(end),:),2)),'LineWidth',2,'Color',[.8 0 0])
    % plot(
    plot(value(sum(dghr_avail_heat(2:endpts(end),:).*dghr_fuel(2:endpts(end),:),2)),'Color',[0 0 0])
    
elseif isempty(acs_v) == 0
    plot(value(sum(ductp_eff.*ductp_heat,2) + sum(acs_cop.*acs_cool,2)),'Color',[0 0 .8])
    plot(value(sum(acs_cop.*acs_cool,2)),'Color',[.8 0 0])
    plot(value(sum(dghr_avail_heat.*dghr_fuel,2)),'Color',[0 0 0])
end

hold off
%% Absorption Chiller Operation
if isempty(ac_v) == 0
    figure
    subplot(2,2,1)
    hold on
    plot(value(ac_adopt).*value(ac_op),'LineWidth',2,'Color',[0 0 .8])
%     plot(value(ac_adopt).*value(ac_start),'LineWidth',2,'Color',[.8 0 0])
  title('AC Charging','FontSize',16)
  legend('AC Active')
    xlim([1 winter_time_count])
    box on
    hold off
    
    
    subplot(2,2,3)
    hold on
    %     plot(value(ac_adopt).*value(ac_op),'LineWidth',2,'Color',[0 0 .8])
    plot(value(ac_adopt).*value(ac_start),'LineWidth',2,'Color',[.8 0 0])
    title('AC Charging','FontSize',16)
    xlim([1 winter_time_count])
    legend('AC Start')
    box on
    hold off
    
    
    subplot(2,2,[2])
    hold on
    plot(value(ac_cool(2:winter_time_count)),'LineWidth',2,'Color',[0 0 .8])
%     plot(value(ac_chrg),'LineWidth',2,'Color',[.8 0 0])
    title('AC Charging','FontSize',16)
    xlim([1 winter_time_count])
    legend('AC Cooling Output')
    box on
    hold off
    
    subplot(2,2,[4])
    hold on
    plot(value(ac_adopt).*ac_v(5).*value(ac_start),'LineWidth',2,'Color',[0 0 .8])
    plot(value(ac_chrg),'LineWidth',2,'Color',[.8 0 0])
    title('AC Charging','FontSize',16)
    xlim([1 winter_time_count])
    legend('AC Chrg by Size','AC Chrg')
    box on
    hold off

    close all
%%%Heat Recovered
figure
hold on
plot(sum(value(dghr_avail_heat(2:winter_time_count,:).*dghr_fuel(2:winter_time_count,:)),2),'LineWidth',1,'Color',[0 0 .0])
plot(value(sum(ductp_eff(2:winter_time_count,:).*ductp_heat(2:winter_time_count,:),2) + sum(ac_cop(2:winter_time_count,:).*ac_cool(2:winter_time_count,:),2) + sum(ac_chrg_eff.*ac_chrg,2)),'LineWidth',2,'Color',[0 0 .8])
plot(value(sum(ductp_eff(2:winter_time_count,:).*ductp_heat(2:winter_time_count,:),2) + sum(ac_chrg_eff.*ac_chrg,2)),'LineWidth',2,'Color',[.8 0 0])
plot(value(sum(ductp_eff(2:winter_time_count,:).*ductp_heat(2:winter_time_count,:),2)) ,'LineWidth',2,'Color',[0 .5 0])
xlim([1 winter_time_count])
    legend('Avail. Heat','AC Chrg','AC Cool','Ductp')
    box on
    hold off
end

%% ACp
close all
if isempty(acp_v) == 0
    figure % #2
    hold on
    plot(value(acp_v(7,1).*acp_strg(1:length(acp_strg)-1,1) + acp_chrg(:,1)),'LineWidth',2,'Color',[0 .5 0])
    plot(value(acp_strg(2:length(acp_strg))),'LineWidth',1,'Color',[0 0 0])
    hold off
    
    figure %  #2
    hold on
    yyaxis left
    plot(value(acp_strg),'LineWidth',2,'Color',[0 .5 0])
    
    yyaxis right
    plot(value(acp_chrg),'LineWidth',1,'Color',[.8 0 0])
    ylim([0 1.1*max(acp_chrg)])
    hold off
    
    figure  %  #3
    hold on
    plot(value(acp_strg),'LineWidth',2,'Color',[0 0 .8])
    plot(value(acp_adopt)*acp_v(6).*ones(length(acp_strg),1),'LineWidth',1,'Color',[0 0 0])
    hold off
    
    figure %  #4
    hold on 
    plot(value(acp_cool),'LineWidth',2,'Color',[0 0 .8])
    plot(value(acp_strg).*(1/acp_v(6)),'LineWidth',1,'Color',[0 0 0])
    
    hold off
    
    figure %  #5
    hold on
    plot(value(acp_cool),'LineWidth',2,'Color',[0 0 .8])
    plot(value(acp_op).*(2*cooling_max),'LineWidth',1,'Color',[0 0 0])
    
    hold off
    
    
    figure %   #6
    hold on
    plot(value(acp_adopt)*acp_v(8)*acp_v(6).*ones(length(acp_strg),1),'LineWidth',1,'Color',[0 0 0])
    plot(2*cooling_max*(1-value(acp_op)),'LineWidth',2,'Color',[0 .5 0])
    plot(value(acp_strg),'LineWidth',2,'Color',[.8 0 0])
    
    hold off
    
    figure %  #7
    hold on
    plot(value(acp_cool(2:endpts(length(endpts))) + acp_chrg),'LineWidth',2,'Color',[.8 0 0])
    plot(value(acp_cool(2:endpts(length(endpts)))),'LineWidth',2,'Color',[0 .5 0])
    plot((1+acp_v(6)*(1-acp_v(7)))*value(acp_adopt).*ones(length(acp_strg),1),'LineWidth',1,'Color',[0 0 0])
    
    hold off

    
end
