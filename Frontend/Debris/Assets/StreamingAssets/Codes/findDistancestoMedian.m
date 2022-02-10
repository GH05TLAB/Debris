function [ Median ] = findDistancestoMedian( Median, EdgeList, edgeCoordMatrix,Contractor, nc )

no_cluster = length(Contractor{nc}.cluster);
no_edges = size(EdgeList,1);

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

