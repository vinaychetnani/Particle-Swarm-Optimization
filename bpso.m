tic
clc
clear all;
ip=fopen('datacom.m','r++');
op=fopen('ge_op.m','w++');
qd=fscanf(ip,'%f',1);       %No of types of devices(14,8,6)
Tt=fscanf(ip,'%f',1);       %No of operational hours
dh=fscanf(ip,'%f',1);       %No of max hours a device will work
W=fscanf(ip,'%f',[3,Tt]);
U=fscanf(ip,'%f',[4+dh,qd]);
W=W';
U=U';
lf=W(:,2);                   %Forecasted Load
c=W(:,3);                    %Wholesale price(ct/kWh)
P=U(:,2);                    %First hour consumption
Nd=U(:,dh+2);                %No of devices of each type
wh=U(:,dh+3);                %Operation hours of each device continously
Io=U(:,dh+4);                %starting time of device
for i=3:dh+1
    P=horzcat(P,U(:,i));
end
% Calculation of Objective Function
Cp=max(c);
Cavg=sum(c)/24;
for t=1:Tt
    Obj(t)=(Cavg/Cp*sum(lf))/c(t);
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
for t=1:24
    count(t)=0;
    for k=1:qd
        if(Io(k)<=t)
            count(t)=count(t)+1;
            pos1(count(t))=k;            % pos1 contains the devive type or device number, in case of dataip it lies b/w 1-14 
        end
    end
    if count(t)~=0
        diff=lmm(t)-Obj(t);
        for i=1:count(t)
            low(i)=0;  
            if(diff>0)
                up(i)=Ndd(pos1(i));
            end
            if(diff<0)
                up(i)=Ndc(pos1(i));
            end
        end
        Number_of_quality_in_Bird=count(t);     %number of type of devices to be leing in the active hours
        availability_type='min';
        MinMaxRange=vertcat(low,up)';
        [gBest] = P_Swarm (diff,P,pos1,Bird_in_swarm, Number_of_quality_in_Bird, MinMaxRange, availability_type, velocity_clamping_factor, cognitive_constant, social_constant, Min_Inertia_weight, Max_Inertia_weight, max_iteration)

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
toc
stairs(Obj,'color','black');hold on
stairs(lfold,'color','red');hold on
stairs(lmm,'color','blue'); hold on
legend('y = DesLoad','y = ForLoad','y = ScdLoad')
% orig_price = sum(lfold.*c)/sum(lfold)
% final_price = sum(lmm.*c)/sum(lmm)    
% ((-final_price + orig_price)/orig_price)*100

% op = max(lfold)
% fp = max(lmm)
% per = (100*(op-fp))/op