%% Clearing Crap
clear bldgdata time elec heating cooling
%% Bulding Loader
[bldglist,bldglist]=xlsread('buildinglist_hr.xlsx');
%%%Building in list to be analyzed (leave empty if UCI)
bldglist

%% Engage a building number if testing is being done with constraints
if testing==1
%     bldgnum=2;
end
%% Information of days to be selected from building load
summer_days=[22 8];
summer_weekend_start=5;
winter_days=[43 18];
winter_weekend_start=3;

if isempty(bldgnum)==1 %%%IF empty, use the UCI Load
    filenameholder='UCI_Campus_2012';
    %% Load building data using clustering method
    
    [bldgdata]=bldgdata_cluster_filter_uci(filenameholder,summer_days,summer_weekend_start,winter_days,winter_weekend_start);
    
    %%%Time from building data
    time=bldgdata(:,1);
    
    %%%Electrical demand - kWh
    elec(:,1)=bldgdata(:,2)*250;
    %%%Cooling demand - kWh
    cooling=bldgdata(:,4)*250;
    %%%Electricity for non-cooling
    elec(:,2)=elec(:,1)-cooling./vc_cop;
    %%%Heating demand - kWh
    heating=bldgdata(:,3)*250;
    
    for i=1:size(elec,1)
        for j=1:size(elec,2)
            if elec(i,j)<0
                elec(i,j)=0;
            end
        end
        if heating(i)<0
            heating(i)=0;
        end
        if cooling(i)<0
            cooling(i)<0;
        end
    end    

else  %%% If a building load is being examined other than UCI
    filenameholder=char(bldglist(bldgnum))
    %% Load building data using clustering method
    [bldgdata]=bldgdata_cluster_filter(filenameholder,summer_days,summer_weekend_start,winter_days,winter_weekend_start);
    %%% Limiting the building data size when building/modifying parts of
    %%% the code
    %     bldgdata=[bldgdata(5760:5953,:)
    %         zeros(size(bldgdata,2))];
    %%%Time from building data
    time=bldgdata(:,1);
    
    %%%Electrical demand - kWh
    elec(:,1)=bldgdata(:,2);
    %%%Cooling demand - kWh
    cooling=bldgdata(:,4);
    %%%Electricity for non-cooling
    elec(:,2)=elec(:,1)-cooling./vc_v(2);
    %%%Heating demand - kWh
    heating=bldgdata(:,3);
    
    for i=1:size(elec,1)
        for j=1:size(elec,2)
            if elec(i,j)<0
                elec(i,j)=0;
            end
        end
        if heating(i)<0
            heating(i)=0;
        end
        if cooling(i)<0
            cooling(i)<0;
        end
    end
    
    
end

%% Date and endpts information
%%%Date vectors for all time stamps
datetimev=datevec(time);
%%%Determining endpoints for all months - end pt is the (last) data entry for a given month
counter=1;
for i=2:length(time)
    if datetimev(i,2)~=datetimev(i-1,2) %looks at second colum of datevec(month) 
        endpts(counter,1)=i-1;
        counter=counter+1;
    end
end

%% Loading the currently used solar data
solar=xlsread('solar_m2.xlsx');
%%% Converting average solar power per 15 minutes to energy available
%%% per 15 minutes
solar=solar./4;

%%%Trimming solar data to match the simulation length
solar=solar(1:endpts(length(endpts)));

%% Moving Average Window
filter_data=elec;
% window=4;
% filter_data = zeros(size(elec));
% %%%At each point, take the average of the surrounding points
% for i=window+1:size(elec,1)-window
%     for j=1:size(elec,2)
%         filter_data(i,j)=mean(elec(i-window:i+window,j));
%     end
% end
% 
% filter_data(1:4,:)=elec(1:4,:);
% filter_data(length(elec)-3:length(elec),:)=elec(length(elec)-3:length(elec),:);
% 
% 
elec=filter_data;

%% Testing Data
dc_mod=1;
cap_mod=1;
util_mod=1;
if testing == 1
    cap_mod=length(time);
    
    time=[time(288:960)
        time(3648:4319)
        time(6337:7008)
        0];
    elec=[elec(288:960,:)
        elec(3648:4319,:)
        elec(6337:7008,:)
        0 0];
    heating=[heating(288:960)
        heating(3648:4319)
        heating(6337:7008)
        0];
    cooling=[cooling(288:960)
        cooling(3648:4319)
        cooling(6337:7008)
        0];
    
    cap_mod=length(time)/cap_mod;
    util_mod=cap_mod;
    
end

%% Filtering Data
if filtering == 1
    %%% Moving Average Window
    window=3;
    filter_data_elec = zeros(size(elec));
    filter_data_cooling = zeros(size(cooling));
    filter_data_heating = zeros(size(heating));
    %%%At each point, take the average of the surrounding points
    for i=window+1:size(elec,1)-window
        for j=1:size(elec,2)
            filter_data_elec(i,j)=mean(elec(i-window:i+window,j));
        end
        filter_data_cooling(i,1)=mean(cooling(i-window:i+window,1));
        filter_data_heating(i,1)=mean(heating(i-window:i+window,1));
    end
    
    filter_data_elec(1:4,:)=elec(1:4,:);
    filter_data_elec(2015:2018,:)=elec(2015:2018,:);
    
    filter_data_cooling(1:4,:)=cooling(1:4,:);
    filter_data_cooling(2015:2018,:)=cooling(2015:2018,:);
    
     filter_data_heating(1:4,:)=heating(1:4,:);
    filter_data_heating(2015:2018,:)=heating(2015:2018,:);
    
    % elec=filter_data;
    
    % ind=12;
    % if isempty(ind) == 0
    %     time=[time(1:ind)
    %         0];
    %     elec=[elec(1:ind,:)
    %         0 0];
    %     heating=[heating(1:ind)
    %         0];
    %     cooling=[cooling(1:ind)
    %         0];
    % end
    
    for j=1:size(elec,2)
        for i=2:length(filter_data_elec)-1
            if filter_data_elec(i,j)<30
                i
                filter_data_elec(i,j)=filter_data_elec(i-1,j);
            end
        end
    end
    
    figure
    a1=subplot(1,3,1)
    hold on
    plot(elec(:,2),'Color',[0 0 1])
    plot(filter_data_elec(:,2),'Color',[.8 0 0])
    hold off
    
    a2=subplot(1,3,2)
    hold on
    plot(cooling,'Color',[0 0 1])
    plot(filter_data_cooling,'Color',[.8 0 0])
    hold off
    
    a3=subplot(1,3,3)
    hold on
    plot(heating,'Color',[0 0 1])
    plot(filter_data_heating,'Color',[.8 0 0])
    hold off
    
    A=[a1 a2 a3];
    linkaxes(A,'x')
    
    elec=filter_data_elec;
    cooling=filter_data_cooling;
    heating=filter_data_heating;
elseif filtering == 2
    %%%Only filtering really low data
    figure
    hold on
    plot(elec(:,2))
    for i=2:length(elec)-1
        if elec(i,2)<mean(elec(:,2))*.2
            elec(i,2)=(elec(i-1,2)+elec(i+1,2))/2;
        end
    end
    plot(elec(:,2),'r')
    hold off
end

if bldgnum==5
    for i=10:length(elec)-10
        if elec(i,2)<65
            i
            elec(i,2)=elec(i-1,2);
%             elec(i,2)=mean(elec(i-10:i+10,2));
        end
    end
end

%% Number of days in the simulation
day_count=1;
for i=2:size(datetimev,1)
    if datetimev(i-1,3)~=datetimev(i,3)
        day_count=day_count+1;
    end
end
%% Locating Summer Months
summer_month=[];
counter=1;
counter1=1;
% endpts
if length(endpts)>1
    for i=2:endpts(length(endpts))
        if datetimev(i,2)~=datetimev(i-1,2)
            counter=counter+1;
            if datetimev(i,2)>=6&&datetimev(i,2)<10
                summer_month(counter1,1)=counter;
                counter1=counter1+1;
            end
        end
    end
else
    if datetimev(1,2)>=6&&datetimev(1,2)<10
        summer_month=counter
    end
end

%% Building cooling Max Load
cooling_max=max(cooling);

%% plotting building loads
figure
subplot(1,3,1)
plot(elec(:,2))
xlim([1 length(elec)])
subplot(1,3,2)
plot(cooling)
xlim([1 length(elec)])
subplot(1,3,3)
plot(heating)
xlim([1 length(elec)])