function [Contractor, change_check, updated_time_vec] = distributeTrip(Contractor, nc, from, to,coll_debris, TimeMatrix,...
          updated_time_vec,time_per_debris, change_check)

%It distributes the load(debris) of the big time contractor to the other
%contractors

%Adding the load to the mintime contractor all the time may be overloading?? 
%min and 2nd min may have very close times
[~, nc_new] = min(updated_time_vec); 

% For repair_profit anything relates to time becomes for profit
%Same logic - trying to find the min profit contractor and transfer debris
%to it from the high profit contractors

% trip = Contractor{nc}.trips{1,cl}{tr,1};
% debris_trip = Contractor{nc}.trips{1,cl}{tr,2};

%len_trip=1:length(trip);
%find the roads that debris are collected
%debris_roads = len_trip(debris_trip > 0);

%transfered_nodes=[];
%for i = 1:length(debris_roads)

%from = trip(debris_roads(i)); to= trip(debris_roads(i) +1);
%transfered_nodes = [transfered_nodes, from,to];
%Transfer the debris from the current to the min cost contractor

%Transfering from contractor nc(large time) to contractor nc_new(smaller time)
%coll_debris = debris_trip(debris_roads(i));
Contractor{nc}.Debris(from,to) = Contractor{nc}.Debris(from,to) - coll_debris;
Contractor{nc}.Debris(to,from) = Contractor{nc}.Debris(to,from) - coll_debris;

Contractor{nc_new}.Debris(from,to) = Contractor{nc_new}.Debris(from,to) + coll_debris;
Contractor{nc_new}.Debris(to,from) = Contractor{nc_new}.Debris(to,from) + coll_debris;

%I didn't take out the edge from,to from contactor nc, so that road is
%still admissable for traversal by nc, however I just transfered the debris
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
%Keeping track of the progress when you transfer 
updated_time_vec (nc_new) = updated_time_vec (nc_new) + time_per_debris *(coll_debris);
updated_time_vec (nc) = updated_time_vec (nc) - time_per_debris *(coll_debris);

% [~, I2] = sort(updated_time_vec, 'ascend'); 
% if I2(1) ~= nc
%     nc_new = I2(1);
% else
%     nc_new = I2(2);
% end

end


% no_clusters=length(Contractor{nc_new}.cluster);
% ind_nc = find(trip_id(:,1) == nc_new);
% ncmin_trips = trip_id(ind_nc, :);
% 
% %To see if they merge to a cluster of nc_new
% %If they merge into a cluster of nc_new and if there are trips provided by
% %the user to be deleted ( a row in trip_id) then don't consider those trips
% %for modification. simply because adding a new edge is going to change the
% %routes of that cluster when we reconstruct the trips, so that trips
% %provided by the user are already subject to change (sometimes we get the
% %exact same trip but usually they are oing to be changed)
% % I just escaped some extra work here
% for y = unique(transfered_nodes) 
%     for c = 1:no_clusters %if they merge into a cluster
%          flag = any(Contractor{nc_new}.cluster{c}==y);
%         if flag == 1
%             ind_cl = ncmin_trips(:,2) == c;
%             change_check(ind_nc(ind_cl)) = 0; %eliminate the trips offered for change in that cluster
%             break;
%         end
%     end
% end


%end

