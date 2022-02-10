function [Contractor] = Repair_profitTimeIntersection(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
                time_vec, revenue_per_debris,  capacity, depot, gas_per_distance, time_per_debris,...
                node_intersection_matrix)

no_edges = size(edge_change,1);
change_check = true(no_edges,1);
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
           [Contractor, change_check, updated_profit_vec] = distributeTrip_profitTimeIntersection(Contractor ,nc, from,to,coll_debris, ...
               TimeMatrix, updated_profit_vec, revenue_per_debris, change_check,  gas_per_distance,...
               depot, capacity, Contractor_original, time_vec, time_per_debris, surrounding);
        end
    end
    
end

end


