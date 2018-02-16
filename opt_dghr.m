%% Cosntraints for DGHR
if isempty(dghr_v) == 0
    %%%Keeping track of if the op variables are set hourly or by the TOU rates
    hour_op=1;
    tou_op=1;
    for i=1:size(dghr_v,2)
        
       
        %%%Lower bounds
        Constraints=[Constraints       
            dghr_v(4,i)*dghr_fuel(:,i) + dghr_v(4,i)*dghr_fuelr(:,i) == dghr_elec(:,i)];
        
%             0 <= dghr_adopt(i)
%             0 <= dghr_elec(:,i)
%             0 <= dghr_fuel(:,i)     
        
        %%%Operational Constraints
        %% Hourly Operation
        if dg_op_select(i) == 0
            
            %%%Hour Ops
%             Constraints=[Constraints
%                 0 <= dghr_on(:,hour_op)
%                 0 <= dghr_start(:,hour_op)];
            
            Constraints=[Constraints
                dghr_on(2:length(dghr_on),hour_op)-dghr_on(1:length(dghr_on)-1,hour_op) <= dghr_start(:,hour_op) %%%DG Starts
                dghr_on(:,hour_op) <= dghr_adopt(i)]; %%Max number of DGHR On
            
            %%%Max Output
            for j=1:size(dghr_on,1)
                if rem(j,25) == 0
%                     [1 i j]
                end
                if 4*j<=length(dghr_elec)
                    Constraints=[Constraints
                        dghr_elec(1+4*(j-1):4*j,i) <= dghr_v(3,i)*dghr_on(j,hour_op)];  %%%Min/Max power set by # of operational DG

                else
                    Constraints=[Constraints
                        dghr_elec(1+4*(j-1):size(dghr_elec,1),i) <= dghr_v(3,i)*dghr_on(j,hour_op)];  %%%Min/Max power set by # of operational DG

                end
            end
            
            %%%Min Output
            for j=1:size(dghr_on,1)
                %%%Min/Max output determined by operational DG
                if 4*j<=length(dghr_elec)
                    Constraints=[Constraints
                        dghr_v(7,i)*dghr_v(3,i)*dghr_on(j,hour_op) <= dghr_elec(1+4*(j-1):4*j,i)];  %%%Min/Max power set by # of operational DG
                else
                    Constraints=[Constraints
                        dghr_v(7,i)*dghr_v(3,i)*dghr_on(j,hour_op) <= dghr_elec(1+4*(j-1):size(dghr_elec,1),i)];  %%%Min/Max power set by # of operational DG
                end
            end
            
            count=2;
            %%%Ramp Up / Down
            for j=1:size(dghr_on,1)
                for k=1:4
                    if count <= size(dghr_elec,1)
                        if count<=length(elec)
                            Constraints=[Constraints
                                 -dghr_v(6,i)*dghr_v(3,i)*dghr_on(j,hour_op) <= dghr_elec(count,i) - dghr_elec(count-1,i) <= dghr_v(5,i)*dghr_v(3,i)*dghr_on(j,hour_op)];
                            count=count+1;
                        end
                        
                    end
                end
            end
            
            
            hour_op=hour_op+1;
            
            %% TOU Operation
        elseif dg_op_select(i) == 1
            
%             %%%TOU Ops
%             Constraints=[Constraints
%                 0 <= dghr_on_tou(:,tou_op)
%                 0 <= dghr_start_tou(:,tou_op)];
            
            Constraints=[Constraints
                dghr_on_tou(2:length(dghr_on_tou),tou_op)-dghr_on_tou(1:length(dghr_on_tou)-1,tou_op) <= dghr_start_tou(:,tou_op) %% DGHR TOU Starts
                dghr_on_tou(:,tou_op) <= dghr_adopt(i)]; %%%MAx number of DGHR TOU On
            
            
            count=2;
            %%%MAx Output
            for j=1:length(tou_block)
                if j==1
                    start=1;
                    finish=tou_block(1);
                else
                    start=sum(tou_block(1:j-1))+1;
                    finish=sum(tou_block(1:j));
                end
                %%%Min/Max output determined by operational DG
                Constraints=[Constraints
                    dghr_v(7,i)*dghr_v(3,i)*dghr_on_tou(j,tou_op) <= dghr_elec(start:finish,i) <= dghr_v(3,i)*dghr_on_tou(j,tou_op)];  %%%Min/Max power set by # of operational DG
                
                %%%Ramping determined by number of active generators times ramping
                %%%capabilities
                for k=1:tou_block(j)
                    if count<=size(dghr_elec,1)
                        Constraints=[Constraints
                            -dghr_v(5,i)*dghr_v(3,i)*dghr_on_tou(j,tou_op) <=  dghr_elec(count,i) - dghr_elec(count-1,i) <= dghr_v(6,i)*dghr_v(3,i)*dghr_on_tou(j,tou_op)];
                        count=count+1;
                    end
                end
            end
            
        end
        
        
    end
end