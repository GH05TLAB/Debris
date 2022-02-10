function [ Contractor, node_intersection_vec ] = ComputeIntersection2(Contractor, depot, surrounding )

node_intersection_matrix = surrounding > 0 ; 

%For each node how many different contractors are passing through it
node_intersection_vec = sum(node_intersection_matrix);

%since we want the extra number of contractors, subtract 1
node_intersection_vec= node_intersection_vec - 1; 

%Exclude the depot from the calculation - all of the cont. using it anyways
node_intersection_vec(depot) = 0; 

no_contractor = length(Contractor);

%In addition let's calculate the "intersection" value for all the trips
%so that we can see which trips (cycles) are the ones overlapping a lot
%with the other trips => bad cycles in terms of intersection
for nc = 1:no_contractor
    no_clusters = length(Contractor{nc}.cluster);
    for cl = 1:no_clusters
        no_trips = size(Contractor{nc}.trips{1,cl},1);
        for tr = 1:no_trips
            nodes = unique(Contractor{nc}.trips{1,cl}{tr,1});
            if ~isempty(nodes)
                % normalized in terms of the length (no of hops) of trips
                total_intersection = sum(node_intersection_vec(nodes))/ length(nodes);
            else 
                total_intersection=0;
            end
            %Put this ratio to the contractor 
            Contractor{nc}.trips{1,cl}{tr,6} = total_intersection; %6th column of trips indicates the intersection of trips
        end
    end
end

end

