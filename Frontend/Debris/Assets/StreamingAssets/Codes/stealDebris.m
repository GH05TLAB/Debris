function [Contractor,obj_vec] = stealDebris(Contractor, nc, cl, tr, shared_nodes, obj_vec, TimeMatrix, capacity,per_debris,profit_check,depot,gas)

%obj_vec equals to time or profit based on the function you are in
%Basically it steals debris from the neighboring links
rem_cap = Contractor{nc}.trips{cl}{tr,4};

check = true;
[~, I] = sort(obj_vec, 'descend');
candidate_contractors = setdiff(I,nc); %sorted descending from max profit OR max time 
break_flag=false;

while check % while your capacity is not full continue stealing
    
    for s = shared_nodes
        for cc = candidate_contractors %Start from the largest profit contractor
            neigh = find(Contractor{cc}.Debris(s,:)>0); %Indicates the debris collected by contractor cc
            for n = 1: length(neigh) %If no neighbor - it won't get into this if
                stolen_debris = min (rem_cap, Contractor{cc}.Debris(s,neigh(n)));
                Contractor{cc}.Debris(s,neigh(n)) = Contractor{cc}.Debris(s,neigh(n)) - stolen_debris;
                Contractor{cc}.Debris(neigh(n),s) = Contractor{cc}.Debris(neigh(n),s) - stolen_debris;
                
                Contractor{nc}.Debris(s,neigh(n)) = Contractor{nc}.Debris(s,neigh(n)) + stolen_debris;
                Contractor{nc}.Debris(neigh(n),s) = Contractor{nc}.Debris(neigh(n),s) + stolen_debris;
                
                Contractor{nc}.TimeMatrix(s,neigh(n)) = TimeMatrix(s,neigh(n));
                Contractor{nc}.TimeMatrix(neigh(n),s) = TimeMatrix(s,neigh(n));
                
                
                if ~(any(Contractor{nc}.nodes==neigh(n)))
                    Contractor{nc}.nodes = [Contractor{nc}.nodes, neigh(n)];
                end

                               
                rem_cap = rem_cap - stolen_debris;
                if rem_cap < 0.1 * capacity %You stole enough debris
                    break_flag = true;
                    break;
                end
                
                obj_vec (nc) = obj_vec (nc) + per_debris *(stolen_debris);
                obj_vec(cc) = obj_vec (cc) - per_debris *(stolen_debris);
                
                if profit_check==true
                    no_nodes = size(TimeMatrix,1);
                    [ dist, ~ ] = dijkstra( TimeMatrix, depot, (1:no_nodes));
                     obj_vec (nc) = obj_vec (nc) - dist(s) *(gas);
                     obj_vec(cc) = obj_vec (cc) + dist(s) *(gas);
                end
            end
            
            if break_flag == true; break; end
            
        end
        
        if break_flag == true; break; end
    end
    check = false;
end


end

