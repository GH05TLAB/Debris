function [Contractor] = Repair_profitNtime(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
                time_vec, revenue_per_debris, capacity, depot, gas_per_distance, time_per_debris, node_intersection)


no_edges = size(edge_change,1);
change_check = true(no_edges,1);
% all_trips = (1:no_trips)';
% iter=1;
% while_break = false;
Contractor_original = Contractor;

updated_profit_vec = profit_vec;

while all(change_check) == 1 
    
    %until you know all the selected trips are modified
    for t = 1: size(edge_change,1)
        from = edge_change(t,1); to = edge_change(t,2);
        nc = edge_change(t,3); %contractor
        cl = edge_change(t,4); %cluster
        tr = edge_change(t,5); %trip
        coll_debris = edge_change(t,6);

        %profit_of_nc = Contractor{nc}.TotalProfit; %contractor's profit

        if updated_profit_vec(nc) >= q_p
            change_check(t)=0;
            %To give the high profits contractors profit to the lower ones          
           [Contractor, change_check, updated_profit_vec] = distributeTrip_profitTime(Contractor ,nc, from,to,coll_debris, ...
               TimeMatrix, updated_profit_vec, revenue_per_debris, change_check,  gas_per_distance,...
               depot, capacity, Contractor_original, time_vec, time_per_debris);
        end
    end
    
    %If there are still trips that are not subject to change
    %Those trips are of contractors with small profit 
    % collect debris from the outer region of the cluster
    fi = find(change_check ==1);
    if isempty(fi) ~= 1
        for f = fi'
%             nc = trip_id(f,1); cl = trip_id(f,2); tr = trip_id(f,3); 
%             nodes = unique(Contractor{nc}.trips{1,cl}{tr,1}); %nodes on that trip
%             f_shared_nodes = node_intersection(nc, nodes) > 0; %find shared nodes bu other contractors
%             shared_nodes = nodes(f_shared_nodes); 
%             % try to find edges which's debris is collected by other
%             % contractors - and steal that debris 
%             [Contractor] = stealDebris(Contractor, nc, cl, tr, shared_nodes, updated_profit_vec, TimeMatrix, capacity);
            change_check(f) = 0;
        end
%     end
    
end

end

