opt_import=x(index_import);
opt_dc_nontou=x(index_nontou_dc);
opt_dc_on=x(index_on_dc)
opt_dc_mid=x(index_mid_dc)
for i=1:size(index_lambda,1)
    opt_ng_lamba(:,i)=x(index_lambda(i,1):index_lambda(i,2))';
end
for i=1:size(endpts,1)
    opt_ng_sos(:,i)=x(model.binary_variables(1+3*(i-1)):model.binary_variables(3*i))';
end
opt_vc_cool=x(index_vc);
opt_boil_heat=x(index_boil);

%% DGHR
if isempty(dghr_v)==0
    opt_fc_adopt=x(index_fc_adopt);
    opt_fc_elec=x(index_fc_elec);
    opt_fc_fuel=x(index_fc_fuel);
    opt_fc_on=x(index_fc_on);
    opt_fc_start=x(index_fc_start);
    
    opt_gt_adopt=x(index_gt_adopt);
    opt_gt_elec=x(index_gt_elec);
    opt_gt_fuel=x(index_gt_fuel);
    opt_gt_on=x(index_gt_on);
    opt_gt_start=x(index_gt_start);
end

%% HRU
if isempty(hru_v) == 0
    opt_hru_adopt=x(index_hru_adopt);
    opt_hru_heat=x(index_hru);
end
%% ductp
if isempty(ductp_v) == 0
    opt_ductp_adopt=x(index_ductp_adopt);
    opt_ductp_heat=x(index_ductp);
end

%% ducts
if isempty(ducts_v) == 0
    opt_ducts_adopt=x(index_ducts_adopt);
    opt_ducts_heat=x(index_ducts);
end

%% ACs 
if isempty(acs_v) == 0
    opt_acs_adopt=x(index_acs_adopt);
    opt_acs_cool=x(index_acs);
end

%% AC
if isempty(ac_v) == 0
    opt_ac_adopt=x(index_ac_adopt);
    opt_ac_cool=x(index_ac_cool);
    opt_ac_on=x(index_ac_op);
    opt_ac_start=x(index_ac_start);
    opt_ac_chrg=x(index_ac_chrg);
end