%% Altering DG capital cost to monthly payments
%% Financing CRAP
interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loan (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be payed off (Years)

%% Adjusting capital cost to the mthly payment
%%%DGHR
for i=1:size(dghr_v,2)
    dghr_v(1,i)=dghr_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%HRU
for i=1:size(hru_v,2)
    hru_v(1,i)=hru_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%ACP
% for i=1:size(acp_v,2)
%     acp_v(1,i)=acp_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
%         /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
%         req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
%         /((1+required_return)^(period*12)-1));
% end

%%%AC
for i=1:size(ac_v,2)
    ac_v(1,i)=ac_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%ACS
for i=1:size(acs_v,2)
    acs_v(1,i)=acs_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%ACp
for i=1:size(acp_v,2)
    acp_v(1,i)=acp_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%ductp
for i=1:size(ductp_v,2)
    ductp_v(1,i)=ductp_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%ducts
for i=1:size(ducts_v,2)
    ducts_v(1,i)=ducts_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%pv
for i=1:size(pv_v,2)
    pv_v(1,i)=pv_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%EES
for i=1:size(ees_v,2)
    ees_v(1,i)=ees_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end

%%%TES
for i=1:size(tes_v,2)
    tes_v(1,i)=tes_v(1,i)*((1-equity)*(interest*(1+interest)^(period*12))...
        /((1+interest)^(period*12)-1)+...%%%Money to pay back bank
        req_return_on*(equity)*(required_return*(1+required_return)^(period*12))...
        /((1+required_return)^(period*12)-1));
end