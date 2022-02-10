function [ Benefit, cluster_add, collection,path_to_node] = findClosestCluster( node, Contractor, con, TimeMatrix, coll_debris,...
    depot, gas_per_distance, revenue_per_debris, node_to)

%Benefit is the profit gained by adding node to the closest cluster of
%contractor nc
%Note that if there is not enough leftover in that cluster node is assigned
%to the next closest cluster with sufficient leftover cap

%See which contractors are already traversing (from,to) edge

no_nodes = size(TimeMatrix,1);

[ dist, pred ] = dijkstra( TimeMatrix, node, (1:no_nodes));
nodes_con = Contractor{con}.nodes;

%find the closest node
iter = 1;

[S , I_m] = sort(dist(nodes_con), 'ascend');
fs = S < dist(depot); %Instead of merging into a farther cluster than depot
% road to depot directly

%Find the closest node to our "node" 
if sum(fs)==0 %If the closest is depot
    node_close = depot;
else
    I_m = I_m(fs);
    node_close = nodes_con(I_m(iter));
end


if node~=node_close
    path_to_node=node_close; p=node_close;
    while p~=node
        p=pred(p);
        path_to_node=[p,path_to_node];
    end
else path_to_node=[];
end

cluster_not_found = true;
cluster_add = [];
while cluster_not_found
    %Find the cluster of node_close
    no_cluster = length(Contractor{con}.cluster);
    for cl_no = 1:no_cluster
        if any(Contractor{con}.cluster{cl_no}==node_close)
            cluster_add = [cluster_add, cl_no]; %there is a chance that the node is a part of multiple clusters
            ca_no = cl_no; %node_close's actual cluster
            %break;
            
        end
        
        if node_close == node %See if the other end node connects to a cluster
            if any(Contractor{con}.cluster{cl_no}==node_to)
                cluster_add = [cluster_add, cl_no];
            end
        end
        
    end
    
    cluster_add = unique(cluster_add);
    %See if there is enough capacity to squish the debris
    %The collection-summation of the capacities of clusters that are close
    %to our node
    sum_leftover = zeros(length(cluster_add),1);
    for ca = 1 :length(cluster_add)
        for y = 1:size(Contractor{con}.trips{cluster_add(ca)},1)
            sum_leftover(ca) = sum_leftover(ca) + Contractor{con}.trips{cluster_add(ca)}{y,4};
        end
    end
    

    sumsum_leftover = sum(sum_leftover);
    if sumsum_leftover > coll_debris %If there is enough place to squish the from, to edge
        Benefit = (coll_debris * revenue_per_debris) - ...
            ((dist(node_close)) * gas_per_distance); %Actually dist(node_close)/2 to convert to distance from time and bidirectional *2
        cluster_not_found = false;
        
        fl = true;
        left = coll_debris;
        iter = 1;
        collection = zeros(1,length(cluster_add));
        %Distribute the aggregate left debris to the clusters
        while fl
            [SS, II] = sort(sum_leftover, 'descend');
            collection(II(iter)) = min(left, SS(iter));
            left = left - collection(II(iter));
            if left == 0
                fl = false;
            else
                iter = iter +1;
            end
        end
        
        
    else
        iter = iter +1;
        if iter > length(I_m) %You have to connect it to depot
            Benefit = (coll_debris * revenue_per_debris) - ...
                ((dist(depot)) * gas_per_distance);
            cluster_add = no_cluster + 1; %dump it to a new cluster
            cluster_not_found = false;
            collection = coll_debris;
        else %See the other closest cluster and which node is the closest
            node_close = nodes_con(I_m(iter));
            cluster_add=[];
        end
    end
    
    
end

end

