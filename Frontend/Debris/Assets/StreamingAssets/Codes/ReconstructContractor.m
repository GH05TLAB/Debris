function [ Contractor ] = ReconstructContractor( Contractor,distLabel,Predecessor,time_per_debris, revenue_per_debris, gas_per_distance,depot,capacity, TimeMatrix)

for nc = 1:length(Contractor)
    %this function we had - based on the contractor assignment find the
    %connected clusters for each contractor and update Contractor
    try
        [Contractor] = findClusters(1, Contractor{nc}.TimeMatrix, nc, Contractor);
    catch
        [Contractor] = findClusters(1, Contractor{nc}.TimeMatrix, nc, Contractor);
    end
        
    traversaltime_contractor = 0; total_debris = 0;
    pathToDepot_C = 0;
    
    for i = 1:length(Contractor{nc}.Edges)%for each cluster! don't hang up on edges
        
        [C,I] = sort(distLabel(Contractor{nc}.cluster{i}), 'ascend');
        
        valid_new_depot = true; % Get the closest depot node with debris in its neighboring links
        iter = 1;
        
        %Find the depot for each cluster
        
        %%%% instead of this just simply get the node with the smallest
        %%%% distance label 
%         new_depot = I(1);
%         C_d = C(1);
        while valid_new_depot
            
            if iter <= length(I)
                new_depot= Contractor{nc}.cluster{i}(I(iter));
                C_d = C(iter);
            else   %none of the nodes in the cluster has a demand edge             
                new_depot= Contractor{nc}.cluster{i}(I(1));
                C_d = C(1);
                valid_new_depot = false;
            end
            
            %Don't make the depot that has no debris assigned in its
            %immeadiate neighboring links 
            if sum(Contractor{nc}.Debris(:,new_depot)) ~= 0
                valid_new_depot = false;
            else
                iter = iter + 1;
            end
        end
        
        % get the path from the depot to the new depot
        path=new_depot; p=new_depot;
        while p~=depot
            p=Predecessor(p);
            path=[p,path];
        end
        
        Contractor{nc}.pathtoDepot{i,1}=path;
        Contractor{nc}.pathtoDepot{i,2}=C_d; %distlabel of the new depot
        
        pathToDepot_C = pathToDepot_C + C_d;
        [Contractor] = routeConstruction(Contractor, capacity, TimeMatrix, path, Contractor{nc}.Debris,nc,distLabel,i);
        

    
        try
            no_trips=size(Contractor{1,nc}.trips{1,i},1); %%%NEW
            trips=1:no_trips;
            
            [Contractor]=cycleCancelling(Contractor,i,nc,trips);
            
            [Contractor]=Improvement(Contractor, i, nc);
            
            [Contractor]=cycleCancelling(Contractor,i,nc,trips);
            %Another improvement on the routes - deleting the unnecessary
            %detours and shortening the length of trips
            trip_length_th = 4;
            if isempty(Contractor{nc}.trips{i}) ~= 1 %If the cluster is composed of non-debris edges only
                % there won't be any trip resulting from routeConstruction
                [Contractor] = ImprovementShorten (Contractor, i,nc, trip_length_th);
            end
            
            %%%NEW
            
            
            [total_traversal_time, Contractor, collected_debris]=costCalculation(Contractor, TimeMatrix, nc,i, capacity);
            
            traversaltime_contractor = traversaltime_contractor + total_traversal_time;
            total_debris = total_debris + collected_debris;
        catch
            %'Error';
                        no_trips=size(Contractor{1,nc}.trips{1,i},1); %%%NEW
            trips=1:no_trips;
            
            [Contractor]=cycleCancelling(Contractor,i,nc,trips);
            
            [Contractor]=Improvement(Contractor, i, nc);
            
            [Contractor]=cycleCancelling(Contractor,i,nc,trips);
            %Another improvement on the routes - deleting the unnecessary
            %detours and shortening the length of trips
            trip_length_th = 4;
            if isempty(Contractor{nc}.trips{i}) ~= 1 %If the cluster is composed of non-debris edges only
                % there won't be any trip resulting from routeConstruction
                [Contractor] = ImprovementShorten (Contractor, i,nc, trip_length_th);
            end
            
            %%%NEW
            
            
            [total_traversal_time, Contractor, collected_debris]=costCalculation(Contractor, TimeMatrix, nc,i, capacity);
            
            traversaltime_contractor = traversaltime_contractor + total_traversal_time;
            total_debris = total_debris + collected_debris;
        end
    end
    
    time_to_collect = time_per_debris * total_debris;
    Contractor{nc}.TotalTime=time_to_collect + traversaltime_contractor + pathToDepot_C;
    Contractor{nc}.TotalProfit=(total_debris * revenue_per_debris) - ((traversaltime_contractor +pathToDepot_C) /2 *gas_per_distance);
    
    try
        Contractor{nc}.Edges = Contractor{nc}.Edges((~cellfun('isempty',Contractor{nc}.Edges)));
    catch
        Contractor{nc}.Edges = [];
    end
    try
        Contractor{nc}.trips = Contractor{nc}.trips((~cellfun('isempty',Contractor{nc}.trips)));
    catch
        Contractor{nc}.trips = [];
    end
    try
        Contractor{nc}.cluster= Contractor{nc}.cluster((~cellfun('isempty',Contractor{nc}.cluster)));
    catch
        Contractor{nc}.cluster = []
    end
    
end

