function [Contractor, change_check, updated_profit_vec] = distributeTrip_profit(Contractor,nc, from,to,coll_debris, TimeMatrix,...
    updated_profit_vec,revenue_per_debris, change_check,gas_per_distance, depot, capacity)


% trip = Contractor{nc}.trips{1,cl}{tr,1};
% debris_trip = Contractor{nc}.trips{1,cl}{tr,2};
% 
% len_trip=1:length(trip);
% debris_roads = len_trip(debris_trip > 0);
% 
% transfered_nodes=[];

%for each road see which cluster is the most profitable to add the
%debris_road
%for i = 1:length(debris_roads)
    
    %from = trip(debris_roads(i)); to= trip(debris_roads(i) +1);
    %transfered_nodes = [transfered_nodes, from,to];
    %Transfer the debris from the current to the min cost contractor
    
    %coll_debris = debris_trip(debris_roads(i));
    %coll_debris = debris;
    
    %calculate the benefit to add it to each contractor
    ben = -Inf * zeros(length(Contractor),1);
    
    %Candidate contractors that the debris on from,to edge to be transfered
    con_vec = setdiff(1:length(Contractor),nc);
    for con = con_vec  
        %For each candidate contractor, see its best cluster the debris can
        %be transfered to
        [ Benefit, cluster_add_vec, Collected,path_node_close] = findClosestCluster( from, Contractor, con, TimeMatrix,...
                        coll_debris, depot, gas_per_distance, revenue_per_debris, to);

        ben(con) = Benefit;
        clust{con}=cluster_add_vec; %The set of closest clusters in contractor con
        collect{con} = Collected; %How much can you transfer to the associated cluster
        path{con}=path_node_close;
    end
    
    [~, I] = sort(updated_profit_vec, 'ascend');
    
    new_nc_notfound = true;
    iter = 1;
    while new_nc_notfound
        %Get the first min profit contractor that adding from,to edge would
        %have a positive benefit - this can't be the current contractor
        %since current contractor is selected to have a larger profit than
        %mean
        if ben(I(iter)) > 0
            nc_new = I(iter);
            cluster_add_vec = clust{nc_new};
            path_add = path{nc_new};
            ccc = collect{nc_new};
            new_nc_notfound = false;
            B = ben(nc_new);
        end
        iter = iter + 1;
        if iter > length(ben) && new_nc_notfound
            %If non of the contractors yield a positive benefit
            %Get the max profit contractor
            max_pr_con = I(length(updated_profit_vec));
            if max_pr_con ~=nc
               nc_new= max_pr_con; 
               
            else
                nc_new=I(length(updated_profit_vec)-1);
            end
            B = ben(nc_new);   
            cluster_add_vec = clust{nc_new};
            path_add = path{nc_new};
            ccc = collect{nc_new};
            new_nc_notfound = false;
            %B = ben(nc_new);
        end
    end
    
%Re-assignment of the debris edge to anothe contractor
Contractor{nc}.Debris(from,to) = Contractor{nc}.Debris(from,to) - coll_debris;
Contractor{nc}.Debris(to,from) = Contractor{nc}.Debris(to,from) - coll_debris;

%try
Contractor{nc_new}.Debris(from,to) = Contractor{nc_new}.Debris(from,to) + coll_debris;
Contractor{nc_new}.Debris(to,from) = Contractor{nc_new}.Debris(to,from) + coll_debris;
% catch
% Contractor{nc_new}.Debris(from,to) = Contractor{nc_new}.Debris(from,to) + coll_debris;
% Contractor{nc_new}.Debris(to,from) = Contractor{nc_new}.Debris(to,from) + coll_debris;
% end
Contractor{nc_new}.TimeMatrix(from,to) = TimeMatrix(to,from);
Contractor{nc_new}.TimeMatrix(to,from) = TimeMatrix(to,from);

%Adding it to the clusters so that the next edge can be considered on top
%of the previous change
try
    for ca = unique(cluster_add_vec)
        Contractor{nc_new}.cluster{ca} = [Contractor{nc_new}.cluster{ca}, [from,to]];
        lenpath = length(path_add);
        j=0;
        for i=1:lenpath-1
            j=i+1;
            from1 = path_add(i); to1 = path_add(j);
            Contractor{nc_new}.TimeMatrix(from1,to1) = TimeMatrix(to1,from1);
            Contractor{nc_new}.TimeMatrix(to1,from1) = TimeMatrix(to1,from1);
            if ~(any(Contractor{nc_new}.nodes==from1))
                Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, from1];
            end
        end
        if ~(any(Contractor{nc_new}.nodes==j)) && j ~=0%Do it once for the last node
                Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, path_add(j)];
        end
        
    end
catch
    %If a new cluster is created - edge is connected to depot instead of a
    %closest cluster
        Contractor{nc_new}.cluster{cluster_add_vec} = [from,to];    
        Contractor{nc_new}.trips{cluster_add_vec}{1}=[];
        Contractor{nc_new}.trips{cluster_add_vec}{2}=[];
        Contractor{nc_new}.trips{cluster_add_vec}{3}=[];
        Contractor{nc_new}.trips{cluster_add_vec}{4}=capacity;
end

itt = 1;
for ca = unique(cluster_add_vec) %Add a new trip to the cluster, specify the transfered debris
    tr_size = size(Contractor{nc_new}.trips{ca},1);
    Contractor{nc_new}.trips{1,ca}{tr_size+1,4} = - ccc(itt); % - coll_debris
    Contractor{nc_new}.trips{1,ca}{tr_size+1,1} = [from, to];
    itt = itt +1;
end

if ~(any(Contractor{nc_new}.nodes==from))
    Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, from];
end

if ~(any(Contractor{nc_new}.nodes==to))
    Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, to];
end

% Of course the traversal time should be added too - since we don't know it
% before constructing the routes, just add the debris collection time ,
% it is the big chunk of the time anyways, bigger than traversal time
updated_profit_vec (nc_new) = updated_profit_vec (nc_new) + B ;
updated_profit_vec (nc) = updated_profit_vec (nc) - B ;

% 
% no_cl = length(Contractor_original{nc_new}.cluster);
% ind_nc = find(trip_id(:,1) == nc_new);
% ncmin_trips = trip_id(ind_nc, :);
% 
% for y = [from,to] %To see if they merge to a cluster
%     for c = 1:no_cl %if they merge into a cluster
%         flag = any(Contractor_original{nc_new}.cluster{c}==y);
%         if flag == 1
%             ind_cl = ncmin_trips(:,2) == c;
%             change_check(ind_nc(ind_cl)) = 0; %eliminate the trips offered for change in that cluster
%             break;
%         end
%     end
% end

end

%end

