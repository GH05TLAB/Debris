function [ E ] = triptoEdge( Contractor, trip_m )

%Create a new edge matrix with from-to-nc-cl-tr information

E = [];

for i = 1:size(trip_m,1)
    
    nc = trip_m(i,1);
    cl=trip_m(i,2);
    tr=trip_m(i,3);
    
    trip = Contractor{nc}.trips{1,cl}{tr,1};
    debris_trip = Contractor{nc}.trips{1,cl}{tr,2};

    len_trip=1:length(trip);
    
    %The edges in the trip that has debris may be eligible for transfer
    debris_roads = len_trip(debris_trip > 0);

    for j = 1:length(debris_roads)
        
        from = trip(debris_roads(j)); 
        to= trip(debris_roads(j) +1);    
        col_debris = debris_trip(debris_roads(j));
        E = [E; [from, to , nc, cl, tr, col_debris]];
    end
    
end

end

