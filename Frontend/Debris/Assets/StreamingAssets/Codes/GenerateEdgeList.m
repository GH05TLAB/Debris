function [ EdgeList ] = GenerateEdgeList( Contractor )

no_contractor = size(Contractor,2);
no_nodes = size(Contractor{1}.TimeMatrix,1);
EdgeList=cell(no_nodes);

%For each edge located in EdgeList{to,from} we 
for nc=1:no_contractor
    
     no_cluster=length(Contractor{nc}.cluster);
     
     for cl=1:no_cluster
        trip_no = size(Contractor{1,nc}.trips{1,cl},1);
        for tr = 1:trip_no
            trip = Contractor{1,nc}.trips{1,cl}{tr,1};
            len_trip=length(trip);
            
            for i=1:len_trip-1 %Iterate over all the edges
                from = trip(i);
                to = trip(i+1);
                EdgeList{from,to}= [EdgeList{from,to}; [nc,cl,tr,Contractor{1,nc}.trips{1,cl}{tr,2}(i)]];
            end
            
        end
     end
end

end

