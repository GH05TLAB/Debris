function [Median, Edge ] = findMedian(Contractor, edgeCoordMatrix, nc, EdgeList, Median, Edge)

%no_contractor = size(Contractor,2);
no_nodes = size(Contractor{1}.TimeMatrix,1);
no_edges = size(EdgeList,1);

 %   for nc=1:no_contractor
        
        no_cluster=length(Contractor{nc}.cluster);
        
        for cl=1:no_cluster
            cl_edges = Contractor{1,nc}.Edges{cl};
            median_max = 9999999; %This is for each cluster of a contractor
            
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
                
                %Now that you found all the nodes Distance to the other nodes in
                %the cluster - figure out which node in that cluster is the median
                
                if  total_dist_node < median_max
                    median_max = total_dist_node;
                    Median{nc,cl}.edge = [f,t];
                    
                    % Indicates the distance of the nodes in the cluster to the
                    % median of the cluster
                    Median{nc,cl}.distance = distVec;
                    
                end
            end
            
            %This is the distance of an edge in the cluster to its own cluster median
            for e_i = 1: length(cl_edges)
                Edge{cl_edges(e_i,1), cl_edges(e_i,2)}.contractor{nc}.cluster{cl}.distmedian = Median{nc,cl}.distance(e_i);
                Edge{cl_edges(e_i,2), cl_edges(e_i,1)}.contractor{nc}.cluster{cl}.distmedian = Median{nc,cl}.distance(e_i);
            end
            
            
        end
 %   end


end

