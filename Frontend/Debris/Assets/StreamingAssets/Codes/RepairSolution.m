function [Contractor, predicted_improvement] = RepairSolution(Contractor, time_vec, profit_vec, edge_change, ti, pr, in, TimeMatrix, ...
    time_per_debris, revenue_per_debris, gas_per_distance, capacity, depot)

predicted_improvement = 0;

% Consider the time and profit values above or below a threshold 
%The general idea here is to improve the MAXTIME and MINPROFIT or the
%OVERLAP. Note that, for MAXTIME and MINPROFIT it means we are trying to
%have similar values for different contractors

%The improvements that we made so far (the one that I send to you) +
%ImprovementShorten which is called after routeConstruction are
%improvements for all contractors, i.e. decreasing the time for each
%individual contractor versus in repair algorithms we are tryin to make the
%overall value better by transfering the load in between contractors
q_p = mean(profit_vec);
q_t = mean(time_vec);

%These are also calculated in the beginning of Main3, but for different
%replications their value will change so we have to calculate again
[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);

%There are 7 cases:
    % time , profit, intersection
    % time + profit, time+inter, profit + inter
    %time + profit + intersection
    %I suggest you to check it starting it from the single objectives since
    %the combinations of them are based on the ideas from the single repair
    
if ti== true
    
    if pr== true
        
        if in == true
            %Time + Profit + intersection
            %NOT WORKING - USER CANT CLICK All 3 options
            [Contractor] = Repair_profitTimeIntersection(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
                time_vec, revenue_per_debris,  capacity, depot, gas_per_distance, time_per_debris,...
                node_intersection_matrix);
        else
            % Time + Profit
            [Contractor] = Repair_profitNtime(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
                time_vec, revenue_per_debris,  capacity, depot, gas_per_distance, time_per_debris,...
                node_intersection_matrix);
        end
    elseif in == true
        % Time + Intersection
        [Contractor] = Repair_timeNintersection(Contractor, edge_change, TimeMatrix,...
            time_vec, time_per_debris,node_intersection_matrix, surrounding,capacity,depot);
    else
        %Time
        [Contractor,predicted_improvement] = Repair_time2(Contractor, edge_change, TimeMatrix, time_vec,...
            time_per_debris,node_intersection_matrix,capacity,depot);
    end
    
elseif pr == true
    if in ==true
        %Profit + Intersection
        
        [Contractor] = Repair_profitNintersection(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
            revenue_per_debris, node_intersection_matrix, capacity, depot, gas_per_distance,surrounding);
    else
        % Profit
        
        [Contractor] = Repair_profit(Contractor, q_p, edge_change, TimeMatrix, profit_vec,...
            revenue_per_debris, capacity, depot, gas_per_distance,time_vec);
    end
else
    %Intersection
    [Contractor] = Repair_intersection(Contractor, edge_change, TimeMatrix, surrounding);
end

end


