function [ gBest ] = P_Swarm(op,diff,P,pos1,Bird_in_swarm, Number_of_quality_in_Bird, MinMaxRange, availability_type, velocity_clamping_factor, cognitive_constant, social_constant, Min_Inertia_weight, Max_Inertia_weight, max_iteration)
    
  N=Bird_in_swarm*max_iteration;
  q=0;

%{
	 distinguishing min and max range
%}
bird_min_range=MinMaxRange(:,1);
bird_max_range=MinMaxRange(:,2);
    
format long;
for i=1:Number_of_quality_in_Bird
    bird(:,i) = bird_min_range(i)+(bird_max_range(i)-bird_min_range(i))*rand(Bird_in_swarm,1);      %initialize bird values
end
Vmax = []
Vmin = []
Vmax = bird_max_range*velocity_clamping_factor;
Vmin = -Vmax;
Velocity  =[]
for i=1:Number_of_quality_in_Bird
    Velocity(:,i)=Vmin(i)+(Vmax(i)-Vmin(i))*rand(Bird_in_swarm,1);                                  %initialize velocity
end

for itr=1:max_iteration
    fprintf('Completed  %d  %% ...', uint8(q*100/N ))
    
    for p=1:Bird_in_swarm
        parameter=bird(p,:,itr);           % gives number of devices of each type to be connected
        if (size(parameter, 2) ~= size(pos1,2))
            fprintf(op, 'rrfrefreffefer  %d %d %d %d', size(parameter, 2) , size(pos1,2), size(bird_min_range,1), Number_of_quality_in_Bird);
        end
        availability(p,itr) = abs(abs(diff)-parameter*P(pos1,1));       %gives difference b/w power taken by load type and available power
        switch availability_type
                case 'min'
                    format long;
                    % te = 0
                    % te1 = 0
                    % for df = 1:Number_of_quality_in_Bird
                    %     if (availability(p,df) ~= 0)
                    %         te = 1
                    %         te1 = df
                    %     end
                    % end
                    % if (te == 0)
                    [pBest_availability,index]=min(availability(p,:));
                    pBest=bird(p,:,index);
                    % elseif (te1 ~= 0)
                    %     te2 = availability
                    if(p==1 && itr==1)
                        gBest=pBest;
                        gBest_availability=pBest_availability;
                    elseif availability(p,itr)<gBest_availability
                        gBest_availability=availability(p,itr);
                        gBest=bird(p,:,itr);
                    end
                otherwise
                    error('availability_type mismatch')
        end
        w(itr)=((max_iteration - itr)*(Max_Inertia_weight - Min_Inertia_weight))/(max_iteration-1) + Min_Inertia_weight;
        Velocity(p,:,(itr+1))=w(itr)*Velocity(p,:,itr) + social_constant*rand(1,Number_of_quality_in_Bird).*(gBest-bird(p,:,itr)) + cognitive_constant*rand(1,Number_of_quality_in_Bird).*(pBest-bird(p,:,itr));
        if (size(Vmin,1) ~= size(Velocity(p,:,(itr+1)), 2))
            fprintf(op, 'hfbrehfree %d %d %d %d %d', size(Velocity(p,:,(itr+1)), 2), size(Velocity(p,:,(itr)), 2), size(Vmin,1), size(Vmax,1), Number_of_quality_in_Bird);
        end
        Velocity(p,:,(itr+1))=MinMaxCheck(Vmin, Vmax, Velocity(p,:,(itr+1)));
          
        bird(p,:,(itr+1))= bird(p,:,itr) + Velocity(p,:,(itr+1));
        bird(p,:,(itr+1))=MinMaxCheck(bird_min_range, bird_max_range, bird(p,:,(itr+1)));
        q=q+1;
        end
    end
end
