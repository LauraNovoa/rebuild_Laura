%%%Determine ramp rate to use in the optimizaiton
if ramp_adjust_on == 1
    for i=1:size(dghr_v,2)
        %%%Energy generated per 15 minutes by a ramping generator
        %%%Energy produced by generator that can ramp to full power in under 15
        %%%minutes
        %%%Ramp up
        if dghr_v(5,i) >= 1/15
            dghr_v(5,i)=((15-1/dghr_v(5,i))+.5/dghr_v(5,i))/15;
        else
            dghr_v(5,i)=dghr_v(5,i)*15/2;
        end
        
        %%%Ramp down
        if dghr_v(6,i) >= 1/15
            dghr_v(6,i)=((15-1/dghr_v(6,i))+.5/dghr_v(6,i))/15;
        else
            dghr_v(6,i)=dghr_v(6,i)*15/2;
        end
    end
end