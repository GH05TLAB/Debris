function [Contractor,predicted_improvement] = Repair_time2(Contractor, edge_change, TimeMatrix, time_vec, time_per_debris,node_intersection,capacity,depot)

no_trips = size(edge_change,1);
change_check = true(no_trips,1);
%all_trips = (1:no_trips)';

updated_time_vec = time_vec;

%we are going to modify each trip the user asks to delete
%change_check sees if a trip is modified
q_t = mean(updated_time_vec);
while all(change_check) == 1
    
    %until you know all the selected trips are modified
    for t = 1: size(edge_change,1)
        from = edge_change(t,1); to = edge_change(t,2);
        nc = edge_change(t,3); %contractor
        cl = edge_change(t,4); %cluster
        tr = edge_change(t,5); %trip
        coll_debris = edge_change(t,6);
        %time_of_nc = Contractor{nc}.TotalTime; %contractor's time
        time_of_nc = updated_time_vec(nc);
        if time_of_nc >= q_t %If contractor's time is bad - larger than avg time over all cont.
            change_check(t)=0;
            [Contractor, change_check, updated_time_vec] = distributeTrip(Contractor, nc, from, to,coll_debris, ...
                TimeMatrix, updated_time_vec, time_per_debris, change_check);
        end
        
    end
    
    %If there are still trips that didn't get modified
    %Those trips are of contractors with small time ------- MAY NOT BE
    %because the costs are changing - at the time the check was done it had
    %small time but after all the changes that might not hold - So instead
    %of making it even bigger- don't change
    %I still want to modify these trips because thise would lead to the
    %decrease of time of the other contractors and eventually the
    %improvement of the overall objective
    fi = find(change_check ==1);
    if isempty(fi) ~= 1
        for f = fi'
            nc = edge_change(f,3); cl = edge_change(f,4); tr = edge_change(f,5);
            if updated_time_vec(nc) <= q_t %Still smaller?
%              try
                nodes = unique(Contractor{nc}.trips{1,cl}{tr,1}); %nodes on that trip
%                 catch
%                 4
%                 end
                f_shared_nodes = node_intersection(1, nodes) > 0; %find shared nodes by other contractors
                shared_nodes = nodes(f_shared_nodes);
                % try to find edges which's debris is collected by other
                % contractors - and steal that debris to increase time of the
                % small time thus reduce time of the big time
                
                profit_check = false; %To see the objective gas=0;
                gas=0;
%                try
                [Contractor,updated_time_vec] = stealDebris(Contractor, nc, cl, tr, shared_nodes, updated_time_vec, TimeMatrix, capacity,time_per_debris,profit_check,depot,gas);
%                 catch
%                     [Contractor,updated_time_vec] = stealDebris(Contractor, nc, cl, tr, shared_nodes, updated_time_vec, TimeMatrix, capacity,time_per_debris,profit_check,depot,gas);
%                 end
                end
            change_check(f) = 0;
        end
    end
    
    %Let's see if the time improvement in the updated_time_vec reflects the
    %actual improvement we see after route construction
    max1 = max(time_vec);
    max2 = max(updated_time_vec);
    predicted_improvement = max1- max2;
end
end

