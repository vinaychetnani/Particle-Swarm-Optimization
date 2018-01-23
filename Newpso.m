tic
clc
clear all;
ip=fopen('dataip.m','r++');
op=fopen('ge_op.m','w++');
qd=fscanf(ip,'%f',1);       %No of types of devices(14,8,6)
Tt=fscanf(ip,'%f',1);       %No of operational hours
dh=fscanf(ip,'%f',1);       %No of max hours a device will work
W=fscanf(ip,'%f',[3,Tt]);
U=fscanf(ip,'%f',[5+dh,qd]);
W=W';
U=U';
lf=W(:,2);                   %Forecasted Load
c=W(:,3);                    %Wholesale price(ct/kWh)
P=U(:,2);                    %First hour consumption
Nd=U(:,dh+2);                %No of devices of each type
wh=U(:,dh+3);                %Operation hours of each device continously
Io=U(:,dh+4);                %starting time of device
To=U(:,dh+5);               
for i=3:dh+1
    P = horzcat(P,U(:,i));
end
% Calculation of Objective Function
Cp=max(c);
Cavg=sum(c)/24;
for t=1:Tt
     % Obj(t)=(Cavg/Cp*sum(lf))/c(t);
    Obj(t) = sum(lf)/24;
end
fprintf(op,'Time Cost \n');
for i=1:Tt
    fprintf(op,'%d  %f\n',i,Obj(i));
end

%Generation of no of devices at each hour

%data initialisation for pSO

max_iteration=fscanf(ip,'%f',1);            %how many times readjust the position of the flock/swarm of birds its quest for food
velocity_clamping_factor=fscanf(ip,'%f',1); %velocity_clamping_factor (normally 2)
cognitive_constant=fscanf(ip,'%f',1);       %individual learning rate (normally 2)
social_constant=fscanf(ip,'%f',1);          %social parameter (normally 2)
Min_Inertia_weight=fscanf(ip,'%f',1);       %min of inertia weight (normally 0.4)
Max_Inertia_weight=fscanf(ip,'%f',1);       %max of inertia weight (normally 0.9)
Bird_in_swarm=fscanf(ip,'%f',1);            %Number of particle=agents=candidate
Bird_in_swarm=20;

lmm=zeros(1,Tt);                            %final load profile after optimization
slot=Tt-Io;
no=sum(slot)+qd;
Ndd=Nd;
Ndc=Nd;
lmm=lf;
lfold=lf;
Conn=zeros(qd,Tt);
Disconn=zeros(qd,Tt);
for tt = 1:1
    for t=1:24
        pos1 = [];
        count = []
        count(t)=0;
        for k=1:qd
            if(Io(k)<=t)
                count(t)=count(t)+1;
                pos1(count(t))=k;            % pos1 contains the devive type or device number, in case of dataip it lies b/w 1-14 
            end
        end
        low =[]
        up =[]
        if count(t)~=0
            diff=lmm(t)-Obj(t);
            for i=1:count(t)
                low(i)=0;
                if(diff>0)
                    up(i)=Ndd(pos1(i));
                end
                if(diff<=0)
                    up(i)=Ndc(pos1(i));
                end
            end
            Number_of_quality_in_Bird=count(t);    %number of type of devices to be leing in the active hours
            availability_type='min';
            MinMaxRange = []
            MinMaxRange=vertcat(low,up)';
            [gBest] = P_Swarm (op,diff,P,pos1,Bird_in_swarm, Number_of_quality_in_Bird, MinMaxRange, availability_type, velocity_clamping_factor, cognitive_constant, social_constant, Min_Inertia_weight, Max_Inertia_weight, max_iteration)

            gBest=round(gBest);
            % Pdd=0;
            Pdd=round(gBest)*P(pos1,:)
                if(diff>0)
                    lmm(t)=lmm(t)-Pdd(1);
                    for j=2:dh
                        mm=t+j;
                        if(mm>25)
                            mm=mm-24;
                        end
                        lmm(mm-1)=lmm(mm-1)-Pdd(j);
                    end
                    for nn=1:count(t)
                        Ndd(pos1(nn))=Ndd(pos1(nn))-gBest(nn);
                        Disconn(pos1(nn),t)=gBest(nn);
                    end
                end
             
                if(diff<0)
                    lmm(t)=lmm(t)+Pdd(1);
                    for j=2:dh
                        mm=t+j;
                        if(mm>25)
                            mm=mm-24;
                        end
                        lmm(mm-1)=lmm(mm-1)+Pdd(j);
                    end
                    for nn=1:count(t)
                        Ndc(pos1(nn))=Ndc(pos1(nn))-gBest(nn);
                        Conn(pos1(nn),t)=gBest(nn);
                    end
                end
            end
        end
    fprintf(op, 'ndd\n');
    for i = 1:qd
        fprintf(op, '%d ',Ndd(i));
    end
    fprintf(op, 'ndc \n');
    for i = 1:qd
        fprintf(op, '%d ',Ndc(i));
    end
    fprintf(op, '\n'); 
    fprintf(op, '\n Disconn \n');
    % orig_price = sum(lfold.*c)/sum(lfold)
    % final_price = sum(lmm.*c)/sum(lmm)    
    % ((-final_price + orig_price)/orig_price)*100

    % op = max(lfold)
    % fp = max(lmm)
    % per = (100*(op-fp))/op
    for i= 1:qd
        for t = 1:24
            fprintf(op, '%d ', Disconn(i,t));
        end
        fprintf(op,'\n');
    end
    fprintf(op,'\n');
    fprintf(op, '\n Conn \n');
    for i= 1:qd
        for t = 1:24
            fprintf(op, '%d ', Conn(i,t));
        end
        fprintf(op,'\n');
    end
end
for de = 1:qd
    if (Ndc(de) == 0)
        continue
    else
        cou = 0
        te= Io(de);
        te1 = To(de);
        te2 = wh(de);
        while(Ndc(de) >0 && cou <10)
            cou = cou +1;
            tein = te;
            te3 = lf(te)- lmm(te);
            for tr1 = te+1: te1
                if (lf(tr1)- lmm(tr1) > te3)
                    te3 = lf(tr1) - lmm(tr1);
                    tein = tr1;
                end
            end
            n = fix((lf(tein)-lmm(tein))/ P(de,1));
            if (n >= Ndc(de))
                lmm(tein) = lmm(tein) + Ndc(de)*P(de,1);
                if (te2 == 2)
                    lmm(tein+1) = lmm(tein+1) + Ndc(de)*P(de,2);
                elseif(te2 == 3)
                    lmm(tein+1) = lmm(tein+1) + Ndc(de)*P(de,2);
                    lmm(tein+2) = lmm(tein+2) + Ndc(de)*P(de,3);
                end
                Ndc(de) = 0;
            else
                Ndc(de) = Ndc(de)- n;
                lmm(tein) = lmm(tein) + n*P(de,1);
                if (te2 == 2)
                    lmm(tein+1) = lmm(tein+1) + n*P(de,2);
                elseif(te2 == 3)
                    lmm(tein+1) = lmm(tein+1) + n*P(de,2);
                    lmm(tein+2) = lmm(tein+2) + n*P(de,3);
                end
            end
        end
        if (Ndc(de) ~= 0)
            tein = te;
            te3 = lf(te)- lmm(te);
            for tr1 = te+1: te1
                if (lf(tr1)- lmm(tr1) > te3)
                    te3 = lf(tr1) - lmm(tr1);
                    tein = tr1;
                end
            end
            tein1 = te;
            te4 = lf(te)- lmm(te);
            for tr2 = te+1:te1
                if ((lf(tr2) -lmm(tr2) > te4) && (lf(tr2) -lmm(tr2) < te3))
                    te4 = lf(tr2) - lmm(tr2);
                    tein1 = tr2;
                end
            end
            lmm(tein) = lmm(tein) + fix(Ndc(de)/2)*P(de,1);
            lmm(tein1) = lmm(tein1) + fix(Ndc(de)/2)*P(de,1);
            if (te2 == 2)
                lmm(tein+1) = lmm(tein+1) + fix(Ndc(de)/2)*P(de,2);
                lmm(tein1+1) = lmm(tein1+1) + fix(Ndc(de)/2)*P(de,2);
            elseif(te2 == 3)
                lmm(tein+1) = lmm(tein+1) + fix(Ndc(de)/2)*P(de,2);
                lmm(tein+2) = lmm(tein+2) + fix(Ndc(de)/2)*P(de,3);
                lmm(tein1+1) = lmm(tein1+1) + fix(Ndc(de)/2)*P(de,2);
                lmm(tein1+2) = lmm(tein1+2) + fix(Ndc(de)/2)*P(de,3);
            end
            Ndc(de) = 0;
        end
    end
end
for de = 1:qd
    if (Ndd(de) == 0)
        continue
    else
        cou = 0
        te= Io(de);
        te1 = To(de);
        te2 = wh(de);
        while(Ndd(de) >0 && cou <10)
            cou = cou +1;
            tein = te;
            te3 = lmm(te)- Obj(te);
            for tr1 = te+1: te1
                if (lmm(tr1)- Obj(tr1) > te3)
                    te3 = lmm(tr1) - Obj(tr1);
                    tein = tr1;
                end
            end
            n = fix((lmm(tein)-Obj(tein))/ P(de,1));
            if (n >= Ndd(de))
                lmm(tein) = lmm(tein) - Ndd(de)*P(de,1);
                if (te2 == 2)
                    lmm(tein+1) = lmm(tein+1) - Ndd(de)*P(de,2);
                elseif(te2 == 3)
                    lmm(tein+1) = lmm(tein+1) + Ndd(de)*P(de,2);
                    lmm(tein+2) = lmm(tein+2) + Ndd(de)*P(de,3);
                end
                Ndd(de) = 0;
            else
                Ndd(de) = Ndd(de)- n;
                lmm(tein) = lmm(tein) - n*P(de,1);
                if (te2 == 2)
                    lmm(tein+1) = lmm(tein+1) - n*P(de,2);
                elseif(te2 == 3)
                    lmm(tein+1) = lmm(tein+1) - n*P(de,2);
                    lmm(tein+2) = lmm(tein+2) - n*P(de,3);
                end
            end
        end
        if (Ndd(de) ~= 0)
            tein = te;
            te3 = lmm(te)- Obj(te);
            for tr1 = te+1: te1
                if (lmm(tr1)- Obj(tr1) > te3)
                    te3 = lmm(tr1) - Obj(tr1);
                    tein = tr1;
                end
            end
            tein1 = te;
            te4 = lmm(te)- Obj(te);
            for tr2 = te+1:te1
                if ((lmm(tr2) -Obj(tr2) > te4) && (lmm(tr2) -Obj(tr2) < te3))
                    te4 = lmm(tr2) - Obj(tr2);
                    tein1 = tr2;
                end
            end
            lmm(tein) = lmm(tein) - fix(Ndd(de)/2)*P(de,1);
            lmm(tein1) = lmm(tein1) - fix(Ndd(de)/2)*P(de,1);
            if (te2 == 2)
                lmm(tein+1) = lmm(tein+1) - fix(Ndd(de)/2)*P(de,2);
                lmm(tein1+1) = lmm(tein1+1) - fix(Ndd(de)/2)*P(de,2);
            elseif(te2 == 3)
                lmm(tein+1) = lmm(tein+1) - fix(Ndd(de)/2)*P(de,2);
                lmm(tein+2) = lmm(tein+2) - fix(Ndd(de)/2)*P(de,3);
                lmm(tein1+1) = lmm(tein1+1) - fix(Ndd(de)/2)*P(de,2);
                lmm(tein1+2) = lmm(tein1+2) - fix(Ndd(de)/2)*P(de,3);
            end
            Ndd(de) = 0;
        end
    end
end
toc
plot(Obj,'color','black');hold on
plot(lfold,'color','red');hold on
plot(lmm,'color','blue'); hold on
legend('y = Objective','y = Before DSM','y = After DSM')
fprintf(op, 'ndd\n');
for i = 1:qd
    fprintf(op, '%d ',Ndd(i));
end
fprintf(op, 'ndc \n');
for i = 1:qd
    fprintf(op, '%d ',Ndc(i));
end
teaise = sum(lf)/24
fprintf(op, '%f' ,teaise);
% fprintf(op, '\n'); 
% fprintf(op, '\n Disconn \n');
% orig_price = sum(lfold.*c)/sum(lfold)
% final_price = sum(lmm.*c)/sum(lmm)    
% ((-final_price + orig_price)/orig_price)*100

% op = max(lfold)
% fp = max(lmm)
% per = (100*(op-fp))/op
% for i= 1:14
%     for t = 1:24
%         fprintf(op, '%d ', Disconn(i,t));
%     end
%     fprintf(op,'\n');
% end
% fprintf(op,'\n');
% fprintf(op, '\n Conn \n');
% for i= 1:14
%     for t = 1:24
%         fprintf(op, '%d ', Conn(i,t));
%     end
%     fprintf(op,'\n');
% end
an1 = max(lf);
an2 = max(lmm);
an3 = ((an1-an2)*100)/an1;
an4 = sum(lmm.*(c));
an5 = sum(lf.*c);
an6 = (an5 - an4)/(an5);
an7 = an6*100;
fprintf(op, '\n \n %f %f %f %f %f %f' , an1, an2 , an3 ,an4, an5 , an7);