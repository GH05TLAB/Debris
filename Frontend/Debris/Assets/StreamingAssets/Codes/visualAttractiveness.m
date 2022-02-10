function brushed_edges = visualAttractiveness(Contractor, EdgeList, edgeCoordMatrix)

no_contractor = size(Contractor,2);
no_nodes = size(Contractor{1}.TimeMatrix,1);
no_edges = size(EdgeList,1);

check = true;
% while check
%Find the median of each cluster in each contractor
for nc=1:no_contractor
    
     no_cluster=length(Contractor{nc}.cluster);
     
     for cl=1:no_cluster
        %cl_nodes = Contractor{1,nc}.cluster{cl};
        cl_edges = Contractor{1,nc}.Edges{cl};
        %Time = Contractor{1,nc}.TimeMatrix;
        median_max = 9999999; %This is for each cluster of a contractor
        
        %for node = cl_nodes
        for ii = 1: size(cl_edges,1)
            %Find the shortest path from node to all nodes in the cluster
            f = cl_edges(ii,1); t = cl_edges(ii,2);

            x1 = edgeCoordMatrix{f,t}(1);
            y1 = edgeCoordMatrix{f,t}(2);
            
            total_dist_node = 0;
            distVec = [];
            for tii = 1:size(cl_edges,1)
                f2 = cl_edges(tii,1); t2 = cl_edges(tii,2);
                
                x2 = edgeCoordMatrix{f2,t2}(1);
                y2 = edgeCoordMatrix{f2,t2}(2);
                [ d ] = euclidianDistance( x1, x2, y1, y2 );
                total_dist_node = total_dist_node + d;
                distVec = [distVec, d];
            end
            %[distLabel, ~]=dijkstra(Time, node, cl_nodes);
            %total_dist_node = sum(distLabel(cl_nodes)); 
            
            %Now that you found all the nodes Distance to the other nodes in
            %the cluster - figure out which node in that cluster is the median
        
            if  total_dist_node < median_max
                median_max = total_dist_node;
                Median{nc,cl}.edge = [f,t];
                
                % Indicates the distance of the nodes in the cluster to the 
                % median of the cluster                
                %Median{nc,cl}.distance = distLabel(cl_nodes);
                Median{nc,cl}.distance = distVec;
       
            end
        end
        
        %The distance of the nodes to the median of the cluster
%         for n_i = 1: length(cl_nodes)
%             Node{cl_nodes(n_i)}.contractor{nc}.cluster{cl}.distmedian = Median{nc,cl}.distance(n_i);
%         end

            for e_i = 1: length(cl_edges)            
                Edge{cl_edges(e_i,1), cl_edges(e_i,2)}.contractor{nc}.cluster{cl}.distmedian = Median{nc,cl}.distance(e_i);
            end
        
        
     end
end

% Now check all the medians - and then all nodes
% See which nodes are closer to their own median
% If not label those nodes as in the overlap

% for nc = 1:no_contractor
%         
%         no_cluster = length(Contractor{nc}.cluster);
%         
%         for cl = 1:no_cluster
%            
%             med = Median{nc,cl}.node;
%             [distLabel, ~]=dijkstra(T, med, 1:no_nodes);
%             
%             Median{nc,cl}.distances = distLabel;
%             
%         end
% end

for nc = 1:no_contractor
        
        no_cluster = length(Contractor{nc}.cluster);
        
        for cl = 1:no_cluster
           
            med = Median{nc,cl}.edge;
            x1 = edgeCoordMatrix{med(1),med(2)}(1);
            y1 = edgeCoordMatrix{med(1),med(2)}(2);

            distVec = [];
            for to_edge = 1:no_edges
                f2 = EdgeList(to_edge,1);
                t2 = EdgeList(to_edge,2);
               % f2 = edge(1); t2 = to_edge(2);
                
                x2 = edgeCoordMatrix{f2,t2}(1);
                y2 = edgeCoordMatrix{f2,t2}(2);
                [ d ] = euclidianDistance( x1, x2, y1, y2 );
                distVec = [distVec, d];
            end
            Median{nc,cl}.distances = distVec;
        end
end

%node_to_change =[];
edge_to_change =[];
%for n = 1:no_nodes
for e = 1:no_edges
    min_dist = 99999;
    
    for nc = 1:no_contractor
        
        no_cluster = length(Contractor{nc}.cluster);
        
        for cl = 1:no_cluster
            
            %median_node = Median{nc,cl}.node;
            
            median_dist = Median{nc,cl}.distances(e);
            
            if median_dist < min_dist
%                 Node{n}.best_contractor = nc;
%                 Node{n}.best_cluster = cl;
                   e1 = EdgeList(e,1); e2 = EdgeList(e,2); 
                   Edge{e1,e2}.best_contractor = nc;
                   Edge{e1,e2}.best_cluster = cl;
                   
                   Edge{e2,e1}.best_contractor = nc;
                   Edge{e2,e1}.best_cluster = cl;
                   
                
                min_dist = median_dist;
            end

        end
    end
    
    %try Node{n}.contractor{Node{n}.best_contractor}.cluster{Node{n}.best_cluster};
    try Edge{e1,e2}.contractor{Edge{e1,e2}.best_contractor};
        %If min dist already corresponds to the cluster the node is in
        if isempty(Edge{e1,e2}.contractor{Edge{e1,e2}.best_contractor})==1
            edge_to_change = [edge_to_change, e];
        end
    catch
       % node_to_change = [node_to_change , n];
        edge_to_change = [edge_to_change, e];
    end
    


end
    
%     %Simply get all the edges from these nodes
%     brushed_edges = [0,0];
%     
%     %for n = node_to_change
%     for e = edge_to_change %This is the edge number
%         to_n = find(T(n,:)>0); %Neighbors of node n
%         best_cn = Node{n}.best_contractor;
%         best_cl = Node{n}.best_cluster;
%         for to = to_n
%             if sum(node_to_change==to)~=0 || (Node{to}.best_contractor ==best_cn && Node{to}.best_cluster == best_cl)
%                 %if to, n is not added before
%                 if ~ismember(brushed_edges, [to,n], 'rows')
%                     brushed_edges = [brushed_edges; [n, to]]; %Just erase whatever assignment there is
%                 end
%             end
%         end
%     end
%     
%     brushed_edges = num2cell(brushed_edges(2:end,:));
%     brushed_edges{1,3}=[];

brushed_edges = [];
for e = edge_to_change

f = EdgeList(e,1); t = EdgeList(e,2);
brushed_edges = [brushed_edges; [f,t]];

end

end
% end

