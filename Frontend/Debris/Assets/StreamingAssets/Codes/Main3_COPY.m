
%This loops through the repair solution with different objectives




% After user makes the changes - repair algorithm

clc
clear

load('Contractor.mat') % indicates the previously given solution to the user that the user is goint to play with
load('ProblemData4.mat') %The problem data that is never going to change

[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);
OVERLAP1 = sum(sum(node_intersection_matrix)); %The total overlap

par1 = 0.1 ; par2=0.05; %The explanation of these parameters are inside the following function
[Contractor, BadCycles_profit, BadCycles_intersection] = detectBadTrips(Contractor, capacity, par1, par2);

%trip_id is just the matrix the user decides to delete
%I assumed he decides to delete all the 'bad' cycles we provide him in
%terms of profit/time 
%What kind of bad cycles to provide is a matter of questions
trip_id = BadCycles_profit;

%this is the previous dijkstra we had - nothing changed
NODES=1:no_nodes;
[distLabel, pred]=dijkstra(Time, depot, NODES);

%Get a profit and time vec to see the relative difference of contractor's
%values
profit_vec=zeros(1,no_contractor);
time_vec=zeros(1,no_contractor);

for i=1:no_contractor
    profit_vec(i) = Contractor{i}.TotalProfit;
    time_vec(i) = Contractor{i}.TotalTime;
end

%Objectives:
    % Min MAXTIME
    % Max MINPROFIT
MAXTIME1= max(time_vec);
MINPROFIT1 = min(profit_vec);

%10 replications on the game playing
%User deletes cycles and we repair/improve the perturbed solution, give
%another set of candidate bad cycles he deletes again....
%for replication = 1:10
for replication = 1:10  
    %The options user can select the solution to be improved
    %For now I defined it by hand - but this part is going to be decided by
    %the human
    %Which options he picks for the algorithm to improve?
    time_selected = true; 
    profit_selected = false; 
    intersection_selected =false;
    
    %     time_selected = boolean(rand(1) > 0.5);
    %     profit_selected = boolean(rand(1) > 0.5);
    %     intersection_selected = boolean(rand(1) > 0.5);
    
    %Considering the trip_id is the set of cycles(trips) deleted by 
    %repair solution based on the objectives to be improved defined by user
    [Contractor] = RepairSolution(Contractor, time_vec, profit_vec, trip_id, time_selected, ...
        profit_selected, intersection_selected, Time, time_per_debris, revenue_per_debris, ...
        gas_per_distance, distLabel, pred, capacity, depot);
    
%     for nc = 1:no_contractor
%         traversaltime_contractor=0; %Want to calculate the total time of a contractor - summation over all its clusters
%         total_debris = 0; %for each contractor
%         pathToDepot_C = 0;
%         
%         for i = 1:length(Contractor{nc}.Edges)
%             [total_traversal_time, Contractor, ~]=costCalculation(Contractor, Time, nc,i, capacity);
% %             
% %             no_trips=size(Contractor{1,nc}.trips{1,i},1);
% %             trips=1:no_trips;
% %             
% %             [Contractor]=cycleCancelling(Contractor,i,nc,trips); 
% %             %First improvement
% %             [Contractor]=Improvement(Contractor, i, nc);
% %             %another clean-up process
% %             [Contractor]=cycleCancelling(Contractor,i,nc,trips);
% %             [total_traversal_time_improved, Contractor, collected_debris]=costCalculation(Contractor, Time, nc,i, capacity);
%             
%             traversaltime_contractor = traversaltime_contractor + total_traversal_time_improved;
%             total_debris = total_debris + collected_debris;
% 
%         end
%         
%         time_to_collect = time_per_debris * total_debris;
%         Contractor{nc}.TotalTime=time_to_collect + traversaltime_contractor + pathToDepot_C;
%         Contractor{nc}.TotalProfit=(total_debris * revenue_per_debris) - ((traversaltime_contractor +pathToDepot_C) /2 *gas_per_distance);
%     end
    
    %In order to find the new ratios for intersection, calculate the
    %surrounding info on the updated solution
    [ surrounding ] = findSurrounding( Contractor );
    [Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);
    OVERLAP2 = sum(sum(node_intersection_matrix));
    

    profit_vec=zeros(1,no_contractor);
    time_vec=zeros(1,no_contractor);
    
    for i=1:no_contractor
        profit_vec(i) = Contractor{i}.TotalProfit;
        time_vec(i) = Contractor{i}.TotalTime;
    end
    
    %time and profit updated for the current iteration
    [MAXTIME2, contmaxtime]= max(time_vec);
    [MINPROFIT2, contminprofit] = min(profit_vec);
    
    %I just wanted to see how much improvement in minprofit and maxtime it makes
    %Its just for me to see, if you want you can discard this part
    fprintf('Iteration: %d \n',replication);
    fprintf('Intersection: %f, \t Improvement: %f \n',OVERLAP2, OVERLAP1-OVERLAP2);
    fprintf('Completion Time: %f, \t Improvement: %f, \t Contractor(max_time): %f \n',MAXTIME2, MAXTIME1-MAXTIME2, contmaxtime);
    fprintf('Min Profit: %f, \t Improvement: %f, \t Contractor(min_profit): %f \n',MINPROFIT2, MINPROFIT1-MINPROFIT2, contminprofit);
    
    OVERLAP1 = OVERLAP2;
    MAXTIME1 = MAXTIME2;
    MINPROFIT1 = MINPROFIT2;
    
    %Get the new bad trips to improve in the next iteration
    [Contractor, BadCycles_profit, BadCycles_intersection] = detectBadTrips(Contractor, capacity, par1,par2);
    trip_id = BadCycles_profit;
end