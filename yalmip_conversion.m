if convert_yalmip == 1
    %% Objective
    Objective=value(Objective);
    %% Utility Variables
    if isempty(utility_exists) == 0
        import=value(import);
        export_grid = value(export_grid);
        nontou_dc=value(nontou_dc);
        onpeak_dc=value(onpeak_dc);
        midpeak_dc=value(midpeak_dc);
    end
    %% Natural Gas
    lambda=value(lambda);
    sig=value(sig);
    %% Legacy Tech
    if isempty(boil_v)==0
        boil=value(boil);
    end
    if isempty(vc_v)==0
        vc_cool=value(vc_cool);
    end
    
    %%  DGHR
    if isempty(dghr_v)==0
        dghr_elec=value(dghr_elec);
        dghr_fuel=value(dghr_fuel);
        dghr_adopt=value(dghr_adopt);
        if op_select(1)>0
            dghr_on=value(dghr_on);
            dghr_start=value(dghr_start);
        end
        if op_select(2)>0
            dghr_on_tou=value(dghr_on_tou);
            dghr_start_tou=value(dghr_start_tou);
        end
    end
    %% HRU
    if isempty(hru_v)==0
        hru_adopt=value(hru_adopt);
        hru_heat=value(hru_heat);
    end
    %% Ductp
    if isempty(ductp_v) == 0
        ductp_adopt=value(ductp_adopt);
        ductp_heat=value(ductp_heat);
    end
    %% Ducts
     if isempty(ducts_v) == 0 && (isempty(acs_v) == 0 || isempty(ac_v) == 0 || isempty(acp_v) == 0)
       ducts_adopt=value(ducts_adopt);
        ducts_heat=value(ducts_heat);
    end
    %% ACs
    if isempty(acs_v) == 0
        acs_adopt=value(acs_adopt);
        acs_cool=value(acs_cool);
    end
    %% AC
    if isempty(ac_v) == 0
        ac_adopt=value(ac_adopt);
        ac_cool=value(ac_cool);
        ac_op=value(ac_op);
        ac_start=value(ac_start);
        ac_chrg=value(ac_chrg);
    end
    %% ACp
    if isempty(acp_v) == 0.
        acp_adopt=value(acp_adopt);
        acp_cool=value(acp_cool);
        acp_chrg=value(acp_chrg);
        acp_strg=value(acp_strg);
        acp_op=value(acp_op);
    end
    
    %% EES
    if isempty(ees_v) == 0
        ees_adopt=value(ees_adopt);
        ees_chrg=value(ees_chrg);
        ees_dchrg=value(ees_dchrg);
        ees_soc=value(ees_soc);
    end
    
    %% PV
    if isempty(pv_v) == 0
        pv_elec=value(pv_elec);
        pv_adopt=value(pv_adopt);
    end
end