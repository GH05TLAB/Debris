function [Contractor] = Repair_intersection(Contractor, edge_change, TimeMatrix, surrounding)

%Only improves the intersection
%Finds the contractor that surounds an edge the most, and change the
%assignment of that edge to that contractor

edge_no = size(edge_change,1);
no_nodes = size(Contractor{1}.TimeMatrix,1);

%When you transfer the contractor of a particular edge - keep track of it
%so that you don't have to consider again
edge_check = zeros(no_nodes);

for c = 1: edge_no
    
    nc = edge_change(c,3); cl = edge_change(c,4); tr = edge_change(c,5);
    from = edge_change(c,1); to = edge_change(c,2);
    %     trip = Contractor{nc}.trips{cl}{tr,1};
    %     trip_length = length(trip) - 1; %In terms of how many links-edges
    %     for e = 1:trip_length
    %         from = trip(e); to = trip(e+1);
    
    if edge_check(from,to)~= 1
        s = surrounding(:,from) + surrounding(:,to);
        s(nc) = s(nc) - 1; %it is counted double, both from 'to' and 'from'
        
        [~, I] = sort(s, 'descend'); %Find the contractor which appears most in the surroundings
        nc_new = I(1);
        
        if nc_new ~= nc
            %Change the assignment of the (from,to) edge from nc to nc_new
            %Update the surrounding as you proceed
            surrounding(nc, from) = surrounding(nc, from) - 1;
            surrounding(nc, to) = surrounding(nc, to) - 1;
            
            surrounding(nc_new, from) = surrounding(nc_new, from) + 1;
            surrounding(nc_new, to) = surrounding(nc_new, to) + 1;
            
            %transfer all the debris to nc_new from nc
            debris_collected = Contractor{nc}.Debris(from,to);
            
            Contractor{nc}.Debris(from,to) = 0;
            Contractor{nc}.Debris(to,from) = 0;
            
            Contractor{nc_new}.Debris(from,to) = Contractor{nc_new}.Debris(from,to) + debris_collected;
            Contractor{nc_new}.Debris(to,from) = Contractor{nc_new}.Debris(to,from) + debris_collected;
            
            Contractor{nc_new}.TimeMatrix(from,to) = TimeMatrix(to,from);
            Contractor{nc_new}.TimeMatrix(to,from) = TimeMatrix(to,from);
            
            %Don't let nc to even traverse this edge
            Contractor{nc}.TimeMatrix(from,to) = 0;
            Contractor{nc}.TimeMatrix(to,from) = 0;
            
            
            edge_check(from,to) = 1 ; edge_check(to,from) = 1;
        end
    end
    %end
end

%Update the contractor.nodes
for nc=1:length(Contractor)
    Contractor{nc}.nodes=[];
    ss = sum(Contractor{nc}.TimeMatrix);
    Contractor{nc}.nodes = find(ss>0);
end


end

