function [Contractor] = Repair_timeNintersection(Contractor, edge_change, TimeMatrix, time_vec, time_per_debris,node_intersection, surrounding,capacity,depot)

no_trips = size(edge_change,1);
change_check = true(no_trips,1);
%all_trips = (1:no_trips)';
updated_time_vec = time_vec;

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
        if time_of_nc >= q_t %If its time is worse than a certain threshold
            change_check(t)=0;
            [Contractor, change_check, updated_time_vec] = distributeTrip_TimeNIntersection(Contractor, nc, from, to,coll_debris, ...
                TimeMatrix, updated_time_vec,time_per_debris, change_check,surrounding);
            % break;
        end
    end
    
    %If there are still trips that are not subject to change
    %Those trips are of contractors with small time
    fi = find(change_check ==1);
    if isempty(fi) ~= 1
        for f = fi'
             nc = edge_change(f,3); cl = edge_change(f,4); tr = edge_change(f,5);
            if updated_time_vec(nc) <= q_t %Still smaller?
                nodes = unique(Contractor{nc}.trips{1,cl}{tr,1}); %nodes on that trip
                f_shared_nodes = node_intersection(1, nodes) > 0; %find shared nodes bu other contractors
                shared_nodes = nodes(f_shared_nodes);
                % try to find edges which's debris is collected by other
                % contractors - and steal that debris to increase time of the
                % small time thus reduce time of the big time
                profit_check = false;
                gas = 0;
                [Contractor,updated_time_vec] = stealDebris(Contractor, nc, cl, tr, shared_nodes, updated_time_vec, TimeMatrix, capacity,time_per_debris,profit_check,depot,gas);
            end
            change_check(f) = 0;
        end
    end
end
end

