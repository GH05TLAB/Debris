function [Contractor, change_check, updated_time_vec] = distributeTripIntersection(Contractor, nc, cl, tr, trip_id, TimeMatrix,...
    updated_time_vec,time_per_debris, change_check,surrounding)

%Adding to the mintime contractor all the time may be overloading??
%min and 2nd min may have very close times


% For repair_profit anything relates to time becomes for profit
%Same logic - trying to find the min profit contractor and transfer debris
%to it from the high profit contractors

trip = Contractor{nc}.trips{1,cl}{tr,1};
debris_trip = Contractor{nc}.trips{1,cl}{tr,2};

len_trip=1:length(trip);
debris_roads = len_trip(debris_trip > 0);

transfered_nodes=[];
for i = 1:length(debris_roads)
    
    from = trip(debris_roads(i)); to= trip(debris_roads(i) +1);
    
    s = surrounding(:,from) + surrounding(:,to);
    s(nc) = s(nc) - 1; %it is counted double, both from 'to' and 'from'
    
    s(nc)=0;
    m = max(s); %Find the contractor which appears most in the surroundings
    I = find(s==m);
    %The difference between distrbiteTrip (inside repair_time2) is the way
    %they find the nc_new
    if length(I)>1
        %Among the contractros that appears the most in its surroundings
        %pick the one with the min time
        %don't assign it to an irrelevant very far away contractor
        [~, I2] = sort(updated_time_vec(I),'ascend');
        nc_new = I(I2(1)); %Pick the smallest time contractor
        %This is gonna be the case if nc is the only surrounding - so
        %intersection objective is not going to be leveraged
    else
        nc_new=I(1);
    end
    
    %Transfer the debris from the current to the new selected contractor
    transfered_nodes = [transfered_nodes, to, from];
    
    surrounding(nc_new, from) = surrounding(nc_new, from) + 1;
    surrounding(nc_new, to) = surrounding(nc_new, to) + 1;
    
    coll_debris = debris_trip(debris_roads(i));
    Contractor{nc}.Debris(from,to) = Contractor{nc}.Debris(from,to) - coll_debris;
    Contractor{nc}.Debris(to,from) = Contractor{nc}.Debris(to,from) - coll_debris;
    
    Contractor{nc_new}.Debris(from,to) = Contractor{nc_new}.Debris(from,to) + coll_debris;
    Contractor{nc_new}.Debris(to,from) = Contractor{nc_new}.Debris(to,from) + coll_debris;
    
    Contractor{nc_new}.TimeMatrix(from,to) = TimeMatrix(to,from);
    Contractor{nc_new}.TimeMatrix(to,from) = TimeMatrix(to,from);
    
    if ~(any(Contractor{nc_new}.nodes==from))
        Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, from];
    end
    
    if ~(any(Contractor{nc_new}.nodes==to))
        Contractor{nc_new}.nodes = [Contractor{nc_new}.nodes, to];
    end
    
    % Of course the traversal time should be added too - since we don't know it
    % before constructing the routes, just add the debris collection time ,
    % it is the big chunk of the time anyways, bigger than traversal time
    updated_time_vec (nc_new) = updated_time_vec (nc_new) + time_per_debris *(coll_debris);
    updated_time_vec (nc) = updated_time_vec (nc) - time_per_debris *(coll_debris);
end


no_clusters=length(Contractor{nc_new}.cluster);
ind_nc = find(trip_id(:,1) == nc_new);
ncmin_trips = trip_id(ind_nc, :);

for y = unique(transfered_nodes) %To see if they merge to a cluster
    for c = 1:no_clusters %if they merge into a cluster
        flag = any(Contractor{nc_new}.cluster{c}==y);
        if flag == 1
            ind_cl = ncmin_trips(:,2) == c;
            change_check(ind_nc(ind_cl)) = 0; %eliminate the trips offered for change in that cluster
            break;
        end
    end
end


end

