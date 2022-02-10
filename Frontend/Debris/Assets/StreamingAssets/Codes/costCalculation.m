function [ COST_cluster, Contractor, collected_debris] = costCalculation(Contractor, Time, nc, cl,capacity)

%This is the total time (cost) calculation for a cluster of a contractor
%Recall that when I say cost basically it is the time 

no_trips=size(Contractor{nc}.trips{1,cl},1);
COST_trip=0;
COST_cluster=0;
collected_debris=0;

for i=1:no_trips
    trip=Contractor{nc}.trips{1,cl}{i,1};
    for node=1:length(trip)-1
       COST_trip=COST_trip+Time(trip(node),trip(node+1)); 
    end
    
    Contractor{nc}.trips{1,cl}{i,3}= COST_trip;
    COST_cluster = COST_cluster + COST_trip;
    COST_trip=0;
    
    collected_debris = collected_debris + (capacity - Contractor{nc}.trips{1,cl}{i,4});
end


end

