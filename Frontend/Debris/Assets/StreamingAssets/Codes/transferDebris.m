function [Contractor, transfer_check, Cycles] = transferDebris(Contractor,nc, Cycles,c, from , to , debris, v,t,i, road_no)
% Transfer debris between 2 trips
transfer_check=1;

% Find if that road is inside the non-empty trip
pt = Contractor{nc}.trips{1,i}{t,1} ;
find_from = (pt == from);
find_to = (pt == to);

% to see of (from,to) or (to,from) appears in the empty trip t
ff1=[0, find_from]; ff2=[find_from,0]; 
ft1=[find_to,0]; ft2=[0,find_to];

sum1=ff1 +ft1; sum2=ff2+ft2; % to see of the places of to and from will overlap

v_index= Cycles{c,3}(1)+ road_no -1;

space = Contractor{nc}.trips{1,i}{t,4};

if sum(sum1>1) ~= 0
    ind_t = find((sum1>1) ==1);
    ind_t=ind_t(1);
    
    transfered_debris=min(debris,space);
    Contractor{nc}.trips{1,i}{t,2}(ind_t-1)= Contractor{nc}.trips{1,i}{t,2}(ind_t-1) + transfered_debris;
    Contractor{nc}.trips{1,i}{v,2}( v_index ) = Contractor{nc}.trips{1,i}{v,2}(v_index ) - transfered_debris;
    Contractor{nc}.trips{1,i}{t,4}= Contractor{nc}.trips{1,i}{t,4} - transfered_debris;
    Contractor{nc}.trips{1,i}{v,4}= Contractor{nc}.trips{1,i}{v,4} + transfered_debris;
    
    % See if the other cycles are affected by this - 
    cyc = [1: c-1,c+1:size(Cycles,1)];
    for i=cyc
        coverage= Cycles{i,3}; 
        min_i=coverage(1); max_i=coverage(2)-1;
        if v_index <= max_i && v_index>=min_i
            cycle_index= v_index - min_i + 1;
            Cycles{i,2}(1,cycle_index) = Cycles{i,2}(1,cycle_index)-transfered_debris; 
        end
        
    end

elseif sum(sum2>1) ~= 0
    ind_t = find((sum2>1) ==1);
    ind_t=ind_t(1);
    
    transfered_debris=min(debris,space);
    Contractor{nc}.trips{1,i}{t,2}(ind_t-1)= Contractor{nc}.trips{1,i}{t,2}(ind_t-1) + transfered_debris;
    Contractor{nc}.trips{1,i}{v,2}(v_index) = Contractor{nc}.trips{1,i}{v,2}(v_index) - transfered_debris;
    Contractor{nc}.trips{1,i}{t,4}= Contractor{nc}.trips{1,i}{t,4} - transfered_debris;
    Contractor{nc}.trips{1,i}{v,4}= Contractor{nc}.trips{1,i}{v,4} + transfered_debris;
    
    cyc = [1: c-1,c+1:size(Cycles,1)];
    for i=cyc
        coverage= Cycles{i,3}; 
        min_i=coverage(1); max_i=coverage(2)-1;
        if v_index <= max_i && v_index>=min_i
            cycle_index= v_index - min_i + 1;
            Cycles{i,2}(1,cycle_index) = Cycles{i,2}(1,cycle_index)-transfered_debris; 
        end
        
    end
    
else transfer_check = 0;
end


end

