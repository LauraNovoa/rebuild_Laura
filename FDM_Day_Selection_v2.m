
%%%Adding cplex path to matlab folder
% addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio125\cplex\matlab\x64_win64')
% %% Loading Building Data
% filenameholder='UCI Cal IT2';
% xls_filename=strcat('U:\Matlab_Reader\Building Data\',filenameholder,'.xlsx');
% 
% [bldgdata]= xlsread(xls_filename);
% %%%Converting all building demand to kWh
% %%%Heating demand - kWh
% bldgdata(:,3)=bldgdata(:,3)*293.1;
% %%%Cooling
% bldgdata(:,4)=bldgdata(:,4)*293.1;
% 
% datetimev=datevec(bldgdata(:,1));
% 
% %%%Cutting off last partial day
% for i=1:length(datetimev)
%     j=length(datetimev)+1-i;
%     if datetimev(j,3)~=datetimev(j-1,3)
%         bldgdata=bldgdata(1:j-1,:);
%         datetimev=datevec(bldgdata(:,1));
%         break
%     end
%  end
%  
%  %%%Eliminating tail if the last date is messed up
%  if datetimev(length(datetimev),5)>50
% %      datetimev=datetimev(1:length(datetimev)-1,:);
%      bldgdata=bldgdata(1:length(datetimev)-1,:);
%         datetimev=datevec(bldgdata(:,1));
%  end
%  
function [bldgdata_new,output,day_endpts,y_val_info,z_mat]=FDM_Day_Selection_v2(bldgdata,cluster_num)
datetimev=datevec(bldgdata(:,1));
 %%%Checking the length of each individual day in the data set
 count=1;
 for i=2:length(datetimev)-1
     if i==2
         start=1;
     end
     if datetimev(i,3)~=datetimev(i-1,3)
         finish=i;
         day_delta(count)=finish-start;
         start=finish;
         count=count+1;
     end
     if i==length(datetimev)-1
         finish=length(datetimev)+1;
         day_delta(count)=finish-start;
     end
 end
 
 day_mean=mean(day_delta);

 %% Assembling power demand matrix
 edit_zero=0;
 edit_zero2=0;
 for i=1:length(day_delta)
     start=(i-1)*24*4+1;
     finish=(i)*24*4;
     if finish>length(bldgdata)
         finish
         length(bldgdata)
         edit_zero=3*(finish-length(bldgdata));
         edit_zero2=1;
         finish=length(bldgdata);
         
     finish
     
     size(bldgdata(start:finish,2)')
     
     size(bldgdata(start:finish,3)')
     size(bldgdata(start:finish,4)')
     size(power_m)
     end
%      length(bldgdata)
%      i
%      length(day_delta)
     power_m(i,:)=[bldgdata(start:finish,2)'...
         bldgdata(start:finish,3)'...
         bldgdata(start:finish,4)'...
         zeros(edit_zero2,edit_zero)];
 end
 
 %% Assembling the dissimilarity matrix
 %%%Minkowski distance, r>=1
 r=2;
 
 dissimilarity=zeros(length(day_delta));
 tic
 for i=1:length(dissimilarity)
     for j=1:length(dissimilarity)
         delta=0;
         for k=1:size(power_m,2)
             delta=delta+abs(power_m(i,k)-power_m(j,k))^r;
         end
         delta=delta^(1/r);
         dissimilarity(i,j)=delta;
     end
 end
 toc
 A=triu(dissimilarity);
 B=tril(dissimilarity)';
 C=A-B;
 
%  tf = issymmetric(dissimilarity)
 %% Building cost function
 %%%d*Z matrix portion of cost function
%  clear cost_func
 
 counter=1;
 for i=1:length(dissimilarity)
     for j=1:length(dissimilarity)     
         
         cost_func(counter)=dissimilarity(i,j);
         counter=counter+1;
     end
 end
 %%%y portion of cost function
 y_location=length(cost_func)+1;
 cost_func=[cost_func zeros(1,length(dissimilarity))];
 %% Equality constraint to ensure that all days belong to a cluster
 %%%A portion will have n x n entries
 cluster_eq=zeros(length(dissimilarity)*length(dissimilarity),3);
 counter=1;

 for i=1:length(dissimilarity)
     for j=1:length(dissimilarity)
         %%%Row entry - the line that equality falls on in the constraint
         cluster_eq(counter,1)=i;
         %%%Column entry
         cluster_eq(counter,2)=length(dissimilarity)*(j-1)+i;
         %%%Value entry
         cluster_eq(counter,3)=1;
         counter=counter+1;
     end
 end
 Beq=ones(max(cluster_eq(:,1)),1);
 eq_index=max(cluster_eq(:,1));
 %% Equality constraint to ensure that the number of clusters being examined is acheived
 
 cluster_eq2=zeros(length(dissimilarity),3);
 for i=1:length(dissimilarity)
     cluster_eq2(i,1)=eq_index+1;
     cluster_eq2(i,2)=y_location+i-1;
     cluster_eq2(i,3)=1;
 end
 
 Beq=[Beq; cluster_num];
 %% Assembling equality matrix
 eqs=[cluster_eq;
     cluster_eq2];
 
 Aeq=sparse(eqs(:,1),eqs(:,2),eqs(:,3),length(Beq),length(cost_func));
 
 %% Inequality constraint to ensure that an object can only be assigned to another object i if object i is a representative object
 
 cluster_ineq=zeros(length(dissimilarity)*length(dissimilarity),3);
 cluster_ineq2=zeros(length(dissimilarity)*length(dissimilarity),3);
 
 counter=0;
 counter1=0;
 for i=1:length(cluster_ineq)
     %%%Row placement of z value
     cluster_ineq(i,1)=i;
     %%%Column placement of z value
     cluster_ineq(i,2)=i;
     %%%Value at this locaiton of z value
     cluster_ineq(i,3)=1;
     %%%Row placement of y value
     cluster_ineq2(i,1)=i;
     %%%Column placement of z value
     cluster_ineq2(i,2)=y_location+counter;
     cluster_ineq2(i,3)=-1;
     counter1=counter1+1;
     if counter1==length(dissimilarity)         
         counter=counter+1;
         counter1=0;
     end
 end
 
 ineqs=[cluster_ineq;
     cluster_ineq2];
 
 B=zeros(length(dissimilarity)*length(dissimilarity),1);
 
 A=sparse(ineqs(:,1),ineqs(:,2),ineqs(:,3),length(B),length(cost_func));
 
 %% Optimizaiton
 tic
 [x,fval,exitflag,output] = cplexbilp(cost_func,A,B,Aeq,Beq);
 toc
 exitflag
 output
 
 y_vals=x(y_location:length(x));
 
 z_mat=vec2mat(x(1:y_location-1),length(dissimilarity));
 %% Seperating Data Information
 
 q=2;
 count=1;
%  y_vals_length=length(y_vals);
%  y_vals_sum=sum(y_vals);
%  y_vals;
%  [y_vals_max,yval_max_location]=max(y_vals)
 for i=1:length(y_vals)
     %      if y_vals(i)==1
     if y_vals(i)>0.99
         euc_sum=0;
         %%% Days to be used as custer centers
         y_val_info(count,1)=i;
         %%%Number of days in the cluster
         y_val_info(count,2)=sum(z_mat(i,:));
         
         %%%Determine euclidian distance between the objects in a cluster
         %%%and the center of the cluster
         for j=1:size(z_mat,2)
             if z_mat(i,j)==1
                 euc=0;
                 for k=1:size(power_m,2)
                     %%%Squares of euclidian distance
                     euc=euc+(power_m(i,k)-power_m(j,k))^2;
                 end
                 %%%Taking the square root to find the euclidian distance
                 euc=euc^(1/2);
                 %%%Summing the euclidian distances together
                 euc_sum=euc_sum+euc^q;
             end
         end
         %%%Dispersion around the clusters (eq 13)
         y_val_info(count,3)=(euc_sum^(1/q))/y_val_info(count,2);
                  
         count=count+1;
         
     end
     
%      if y_vals(i)>0 y_vals(i)~=1
%          errors=y_vals(i)
%          errors_location=i
%      end
 end
 
 yvals_info_length=length(y_val_info);
 
 
 t=2;
 %%%Determining distance between all cluster centers (eq 14)
 centroid_distance=zeros(size(y_val_info,1),size(y_val_info,1));
 for i=1:size(y_val_info,1)
     for j=1:size(y_val_info,1)
         delta=0;
         for k=1:size(power_m,2)
%              power_m(y_val_info(i,1),k)
%              power_m(y_val_info(j,1),k)
             delta=delta+abs(power_m(y_val_info(i,1),k)-power_m(y_val_info(j,1),k))^t;             
         end
         centroid_distance(i,j)=delta^(1/t);

     end
 end
 
 compactness=zeros(size(y_val_info,1),size(y_val_info,1));
 %%%Simple measure of compactness of the partitions (eq 15)
 for i=1:size(y_val_info,1)
     for j=1:size(y_val_info,1)
         if i~=j
             compactness(i,j)=(y_val_info(i,3)+y_val_info(j,3))/centroid_distance(i,j);
         end
     end
 end
%          for k=1:size(power_m,2)
max_compactness=0;
for i=1:size(compactness,1)
    max_compactness=max_compactness+max(compactness(i,:));
end

max_compactness=max_compactness/cluster_num;
        
%% Building data set

count=1;
for i=2:size(datetimev,1)
    if datetimev(i,3)~=datetimev(i-1,3)
        day_endpts(count,1)=i-1;
        count=count+1;
    end
    if i==size(datetimev,1)
        day_endpts(count,1)=i;
    end
end


bldgdata_new=[];
for i=1:size(y_val_info)
    day_index=y_val_info(i,1);
    if day_index==1
        start=1;
        finish=day_endpts(day_index);
    else
        start=day_endpts(day_index-1)+1;
        finish=day_endpts(day_index);
    end
    bldgdata_new=[bldgdata_new
        bldgdata(start:finish,:)];
    
    y_val_info(i,4)=weekday(bldgdata(start,1));
end

