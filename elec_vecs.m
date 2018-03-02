%% Elec import/export price
%% Rates at which electricity can be bought/sold back to the grid
export_price=[];
import_price=[];
for i=1:endpts(end);
    %%%Day of week
    daynum=weekday(time(i,1));
    if datetimev(i,2)>=6&&datetimev(i,2)<10
        %%%Summer On
        if datetimev(i,4)>=12&&datetimev(i,4)<18
            export_price(i,1)=e_rate(1)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(1);
            %%%Summer Mid Early
        elseif datetimev(i,4)>=8&&datetimev(i,4)<12
            export_price(i,1)=e_rate(2)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(2);
            %%%Summer Mid Late
        elseif datetimev(i,4)>=18&&datetimev(i,4)<23
            export_price(i,1)=e_rate(2)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(2);
            %%%Summer Off
        else
            export_price(i,1)=e_rate(3)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(3);
        end
        %%% Summer Weekends
        if daynum==1||daynum==7
            export_price(i,1)=e_rate(3)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(3);
        end
        %%%Winter ~ Everything Else
    else
        %%%Winter Mid
        if datetimev(i,4)>=8&&datetimev(i,4)<21
            export_price(i,1)=e_rate(4)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(4);
            %%%Winter weekends
            if daynum==1||daynum==7
                export_price(i,1)=e_rate(5)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(5);
            end
            %%%Winter Off
        else
            export_price(i,1)=e_rate(5)-(ratedata(1,2)+ratedata(2,2));
            import_price(i,1)=e_rate(5);
        end
    end
end
