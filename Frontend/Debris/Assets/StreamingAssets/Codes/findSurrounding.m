function [ surrounding ] = findSurrounding( Contractor )

%It calculates from what contractors a node's neighboring edges are
%traversed by 
%Contractor.edges show the edges that the contractors are allowed to
%traverse - but it doesn't specify the ones that are actually traversed and
%included in the trips 

no_contractor = length(Contractor);
no_nodes = size(Contractor{1}.TimeMatrix,1);
surrounding = zeros(no_contractor,no_nodes);
for nc = 1:no_contractor
    no_cluster = length(Contractor{nc}.cluster);
    %For each contractrot, M matrix shows the edges traversed - 1 if
    %traversed
    M = zeros(no_nodes);
    for cl = 1:no_cluster
            no_trip = size(Contractor{nc}.trips{cl},1);
        for tr = 1:no_trip
            trip = Contractor{nc}.trips{cl}{tr,1};
            no_edge = length(trip)-1;
            for e=1:no_edge
                from = trip(e); to = trip(e+1);
                M(from,to) = 1; M(to,from)=1;
            end
        end
    end
    surrounding(nc,:) = sum(M);
    %For each node, specifies the number of that node's links  traversed by
    %nc. So it can be max 4 for a node. Because the max degree is 4 for a
    %node. If all those links are traversed by lets say 1st contractor then
    %surrounding(1,node) = 4. However these links also can be traversed by
    %2nd contractor so surrounding(2,node)=4 too.
end

end

