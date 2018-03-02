%% Utility Indexes
index_import=find((model.f == e_rate(5)) |...
    (model.f == e_rate(4)) |...
    (model.f == e_rate(3)) |...
    (model.f == e_rate(2)) |...
    (model.f == e_rate(1)));

index_nontou_dc=find(model.f == util_mod*4*dc_nontou);

index_on_dc=find(model.f == util_mod*4*dc_on);
index_mid_dc=find(model.f == util_mod*4*dc_mid);

%% Legacy Tech
index_boil=find(model.f == boil_v(1));
if length(index_boil) == 2*endpts(length(endpts))
    index_boil=index_boil(1:length(index_boil)/2);
end

index_vc=find(model.f == vc_v(1));

%% FC Ops
index_fc_adopt=find(model.f == cap_mod*4*length(endpts)*dghr_v(1,1)*dghr_v(3,1));
index_fc_elec=find(model.f == dghr_v(2,1));

index_fc_fuel=find(model.f == 0.000532);
model.f(index_fc_fuel)=0;

index_fc_on=find(model.f == 0.0532);
model.f(index_fc_on)=0;

index_fc_start=find(model.f == 0.00532);
model.f(index_fc_start)=0;

%% GT Ops
index_gt_adopt=find(model.f == cap_mod*4*length(endpts)*dghr_v(1,2)*dghr_v(3,2));
index_gt_elec=find(model.f == dghr_v(2,2));

index_gt_fuel=find(model.f == 0.000632);
model.f(index_gt_fuel)=0;

index_gt_on=find(model.f == 0.0632);
model.f(index_gt_on)=0;

index_gt_start=find(model.f == 0.00632);
model.f(index_gt_start)=0;

%% HRU Ops
if isempty(hru_v) == 0
    index_hru_adopt=find(model.f == cap_mod*4*hru_v(1)*length(endpts));    
        
    index_hru=find(model.f == hru_v(2,1));
    
    if length(index_hru) == 2*endpts(length(endpts))
        index_hru=index_hru(length(index_hru)/2+1:length(index_hru));
    end
end
%% Ductp Ops
if isempty(ductp_v) == 0
    index_ductp_adopt=find(model.f == cap_mod*4*ductp_v(1)*length(endpts));
    index_ductp=find(model.f == ductp_v(2,1));
end

%% Ducts Ops
if isempty(ducts_v) == 0
    index_ducts_adopt=find(model.f == cap_mod*4*ducts_v(1)*length(endpts));
    index_ducts=find(model.f == ducts_v(2,1));
end
%% ACs
if isempty(acs_v) == 0
    index_acs_adopt=find(model.f == cap_mod*4*acs_v(1,1)*length(endpts));
    index_acs=find(model.f == acs_v(2,1));
end
%% AC
if isempty(ac_v) == 0
    index_ac_adopt=find(model.f == cap_mod*4*ac_v(1,1)*length(endpts));
    index_ac_cool=find(model.f == ac_v(2,1));
    
    index_ac_op=find(model.f == 0.762);
    model.f(index_ac_op)=0;
    
    index_ac_start=find(model.f == 0.0762);
    model.f(index_ac_start)=0;
    
    index_ac_chrg=find(model.f == (1/10).*ac_v(2,1));
end

%% ACp
if isempty(acp_v) == 0
    
    
    
end