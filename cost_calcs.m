%% Recording costs for individual components
clc
costs_import=opt_import'*import_price

costs_dc=util_mod*4*dc_nontou*sum(opt_dc_nontou)+util_mod*4*dc_on*opt_dc_on+util_mod*4*dc_mid*opt_dc_mid

costs_ng=sum(model.f(2023:2034).*x(2023:2034))

boil_om=sum(model.f(index_boil).*x(index_boil))

vc_om=sum(model.f(index_vc).*x(index_vc))

dghr_cap=model.f(index_fc_adopt).*x(index_fc_adopt)+model.f(index_gt_adopt).*x(index_gt_adopt)

dghr_om=sum(model.f(index_fc_elec).*x(index_fc_elec)+model.f(index_gt_elec).*x(index_gt_elec))

hru_cap=model.f(index_hru_adopt).*x(index_hru_adopt)+model.f(index_ductp_adopt).*x(index_ductp_adopt)

hru_op=sum(model.f(index_hru).*x(index_hru))

total_costs=costs_import+costs_dc+costs_ng+boil_om+vc_om+dghr_cap+dghr_om+hru_cap+hru_op

total_costs-fval