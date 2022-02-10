function [Contractor_updated] = ImprovementShorten (Contractor, cl,nc, trip_length_th )

no_trips = size(Contractor{nc}.trips{cl},1);
Contractor_updated = Contractor;

TM = Contractor{nc}.TimeMatrix;
NODES = Contractor{nc}.cluster{cl};

depot_not_found = 1; i=1;
while depot_not_found
    if isempty(Contractor{nc}.trips{cl}{i,1})==1
        i = i+1;
    else
        depot = Contractor{nc}.trips{cl}{i,1}(1);
        depot_not_found = 0;
    end
end
% try %just in case if the first trip is empty
%     depot = Contractor{nc}.trips{cl}{1,1}(1); %Depot for that cluster - fist node of the trips
% catch
%     try 
%         depot = Contractor{nc}.trips{cl}{2,1}(1); %Depot for that cluster - fist node of the trips
%     catch
%         depot = Contractor{nc}.trips{cl}{3,1}(1); %Depot for that cluster - fist node of the trips
%     end
% end



[~, pred_initial]=dijkstra(TM , depot, NODES);


for t = 1:no_trips
    
    first_node_index = 1; %start from the beginning of the trip
    trip = Contractor{nc}.trips{cl}{t,1};
    
    debris_edges = find(Contractor{nc}.trips{cl}{t,2} > 0);
    if ~isempty(debris_edges)
    trip_shortened = true;
    iter = 1;
    next_node_index = debris_edges(iter);
    first_node_updated = first_node_index - 1;
    change_check = false;
    
    %find the traversal routes bw 2 debris_roads and replace it with the
    %shorest path instead 
    while trip_shortened
        if next_node_index - first_node_index > trip_length_th %If the path between them is long
            %Find the shortest path between these two nodes 
            %Change the possibly longer path with the shortest path
            
            if first_node_index ~=1
                try
                    [~, pred]=dijkstra(TM , trip(first_node_index), NODES);
                catch
                    [~, pred]=dijkstra(TM , trip(first_node_index), NODES);
                end
            else
                pred = pred_initial;
            end
            
            path=[]; p=trip(next_node_index);
            while p~= trip(first_node_index)
                p=pred(p);
                path=[p,path];
            end
            
           trip_rest = Contractor{nc}.trips{cl}{t,1}(next_node_index:end);
           debris_rest = Contractor{nc}.trips{cl}{t,2}(next_node_index:end);  
           
           %creating the updated_contractor
           trip_before = Contractor_updated{nc}.trips{cl}{t,1}(1:first_node_updated);
           debris_before = Contractor_updated{nc}.trips{cl}{t,2}(1:first_node_updated);
           
           Contractor_updated{nc}.trips{cl}{t,1} =  [trip_before, path, trip_rest];
           Contractor_updated{nc}.trips{cl}{t,2} =  [debris_before, zeros(1,length(path)), debris_rest];
           
           first_node_updated = length(path) + length(trip_before) + 1;
        else    
            first_node_updated = first_node_updated + (next_node_index - first_node_index +1);
        end
        
        if (next_node_index + trip_length_th) > length(trip) || iter >= length(debris_edges) %You have scanned the whole trip
            trip_shortened = false;
        else           
            iter = iter + 1;
            first_node_index = next_node_index + 1;
            
            next_node_index = debris_edges(iter);
            
        end
    end
end
end
end