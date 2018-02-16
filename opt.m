%% Generating Model
[model,recoverymodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
%% Cost Funciton Indicies
% indicies_opt_cf

%% Optimizing
if opt_now==1
%     options = cplexoptimset;
%     if isempty(max_nodes)==1
%         options.MaxNodes = 1000;
%     else
%         options.MaxNodes = max_nodes;
%     end
%     current_time=clock
%     options.Display='on';
%     options.Diagnostics='on';
%     options.PreInd=0;
    
    options = cplexoptimset('mip.limits.nodes', max_nodes,...
        'mip.strategy.file', 2)
%     ,...
%         'workmem',10000
    options.Display='on';
    options.Diagnostics='on';
    
    
    
%     options
    
    lb=zeros(size(model.f));
    ub=inf(size(lb));
    [x,fval,exitflag,output] = cplexmilp (model.f,model.Aineq,model.bineq,model.Aeq,model.beq,[],[],[],lb,ub,model.ctype',[],options);
    output
    exitflag
    fval
    
    %% Recovering data and assigning to the YALMIP variables
    assign(recover(recoverymodel.used_variables),x)
end

%% Optimizing thru YALMIP

opt_now_yalmip=0;
if opt_now_yalmip==1
    
    
    ops = sdpsettings('solver','Cplex','debug',1,'verbose',2,'warning',1,'savesolveroutput',1);
    ops = sdpsettings;
    ops.showprogress=1;
    ops.cplex.MaxNodes=max_nodes;
    ops.cplex.mip.limits.nodes=max_nodes;
    ops.clpex.options.Display='on';
    ops.cplex.options.Diagnostics='on';
    
    %% Lower Bound Constraints
    if utility_exists == 1
        Constraints=[Constraints
            0 <= import];
    end
    
    %%%Legacy Boiler
    if isempty(boil_v)==0
        Constraints=[Constraints
            0 <= boil];
    end
    
    %%%Legacy VC
    if isempty(vc_v) == 0
        Constraints=[Constraints
            0 <= vc_cool];
    end
    
    %%% DGHR
    if isempty(dghr_v) == 0
        for i=1:size(dghr_v,2)
            Constraints=[Constraints
                0 <= dghr_adopt(i)
                0 <= dghr_elec(:,i)
                0 <= dghr_fuel(:,i)
                0 <= dghr_on(:,i)
                0 <= dghr_start(:,i)];
        end
    end
    
    %%%HRU
    if isempty(hru_v) == 0
        i=1;
        Constraints=[Constraints
            0 <= hru_heat(:,i)
            0 <= hru_adopt(i)
            0 <= ductp_heat(:,i)
            0 <= ductp_adopt(i)];
    end
    %%%ACs
    if isempty(acs_v)==0
        i=1;
        Constraints=[Constraints
            0 <= acs_cool(:,i)
            0 <= acs_adopt(i)];
    end
    
    %%%AC
    if isempty(ac_v)==0
        i=1;
        Constraints=[Constraints
            0 <= ac_adopt(i)
            0 <= ac_op(:,i)
            0 <= ac_start(:,i)
            0 <= ac_chrg(:,i)
            0 <= ac_cool(length(ac_op)+1:length(ac_cool),i)];
    end
        
    
    
    optimize(Constraints,Objective,ops)
end
%
%
% %     options.Display='on';
% %     options.Diagnostics='on';
% %     options.PreInd=0;
% %     [x,fval,exitflag,output] = cplexmilp (model.f,model.Aineq,model.bineq,model.Aeq,model.beq,[],[],[],model.lb,model.ub,model.ctype',[],options);
% else
%     [model,recoverymodel] = export(Constraints,Objective,sdpsettings('solver','cplex'));
%     %     [model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective,ops)
%     
% end

if length(elec)<=25
    model.Aeq=full(model.Aeq);
    model.beq=full(model.beq);
    model.Aineq=full(model.Aineq);
    model.bineq=full(model.bineq);
end