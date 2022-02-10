function brushed_edges = visualAttractiveness2(Contractor, EdgeList, edgeCoordMatrix, nodeCoord)

no_contractor = size(Contractor,2);
no_nodes = size(Contractor{1}.TimeMatrix,1);
no_edges = size(EdgeList,1);

Median = {};
Edge = {};
brushed_edges = [];
for nc = 1:no_contractor
    %Find the median of each cluster in each contractor
    [Median, Edge] = findMedian(Contractor, edgeCoordMatrix, nc, EdgeList, Median, Edge);
    
    %Find the distances of the median to all the edges
    Median = findDistancestoMedian( Median, EdgeList, edgeCoordMatrix,Contractor, nc );
end
    
    
check = true;
%while check

    edge_to_change =[];
    
    for e = 1:no_edges
        min_dist = 99999;
        
        for nc = 1:no_contractor
            
            no_cluster = length(Contractor{nc}.cluster);
            
            for cl = 1:no_cluster
                
                median_dist = Median{nc,cl}.distances(e);
                
                if median_dist < min_dist
                    
                    e1 = EdgeList(e,1); e2 = EdgeList(e,2);
                    Edge{e1,e2}.best_contractor = nc;
                    Edge{e1,e2}.best_cluster = cl;
                    
                    Edge{e2,e1}.best_contractor = nc;
                    Edge{e2,e1}.best_cluster = cl;
                    
                    
                    min_dist = median_dist;
                end
                
            end
        end
        
        changed_cont = [];
        try Edge{e1,e2}.contractor{Edge{e1,e2}.best_contractor};
            if isempty(Edge{e1,e2}.contractor{Edge{e1,e2}.best_contractor})==1
                nc_new = Edge{e1,e2}.best_contractor;
                [ Contractor, nc_old] = swapEdgeAssingment( Contractor, Edge, e1,e2 );
                changed_cont = [nc_old, nc_new];
                brushed_edges = [brushed_edges; [e1,e2, Edge{e1,e2}.best_contractor]];
            end
        catch
            nc_new = Edge{e1,e2}.best_contractor;
            [ Contractor, nc_old] = swapEdgeAssingment( Contractor,Edge, e1,e2 );
            changed_cont = [nc_old, nc_new];
            brushed_edges = [brushed_edges; [e1,e2, Edge{e1,e2}.best_contractor]];
        end
        
        %Since the edge is assigned to a new contractor - all the
        %calculations shifted. Continue assigning the new edge based on the
        %updated contractor assignments - but don't go back to the edges
        %that are already visited
        for nc = 1:changed_cont
            %Find the median of each cluster in each contractor
            [Median, Edge] = findMedian(Contractor, edgeCoordMatrix, nc, EdgeList, Median, Edge);
            
            %Find the distances of the median to all the edges
            Median = findDistancestoMedian( Median, EdgeList, edgeCoordMatrix,Contractor, nc );
        end
        
    end

%end
end



