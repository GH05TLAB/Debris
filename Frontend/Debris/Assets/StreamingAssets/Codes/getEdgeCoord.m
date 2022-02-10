function edgeCoordMat = getEdgeCoord(EdgeList, newCoord)

no_edges = size(EdgeList,1);

%edgeCoord = [1:no_edges]';
edgeCoordMat = {};

for e = 1:size(EdgeList,1)
    node1 = EdgeList(e,1);
    node2 = EdgeList(e,2);
    
    x = (newCoord(node1,1) + newCoord(node2,1))/2;
    y = (newCoord(node1,2) + newCoord(node2,2))/2;
    
%     edgeCoord(e,2) = x;
%     edgeCoord(e,3) = y;

    edgeCoordMat{node1,node2} = [x,y];
    edgeCoordMat{node2,node1} = [x,y];
    
end

end

