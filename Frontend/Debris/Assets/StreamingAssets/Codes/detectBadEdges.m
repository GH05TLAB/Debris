function [ BadEdges_int, BadEdges_time ] = detectBadEdges( EdgeListMatrix, Contractor, capacity, par_threshold, EdgeList )

%BadEdges will have the same format as edge_change
%from - to -nc - cl- trip - collected debris

no_edges = size(EdgeList,1);
no_bad_edges = ceil(no_edges * par_threshold); %number of bad edges to show from each objective (int and time/profit)
%Overall we will indicate unique edges from 2*no_bad_edges 
%Because the same edge might appear as bad for both int and time


%Add two new columns to store the intersection badness and time/pr badness
EdgeList = [EdgeList, zeros(no_edges,2)];
for e = 1:no_edges
    
    from = EdgeList(e,1); to = EdgeList(e,2);
    all_trips = [EdgeListMatrix{from,to}; EdgeListMatrix{to,from}];
    no_trips = size(all_trips,1);
    
    %intersection ratio is stored in the 6th column of trips
    %time/profit badness ratio is stored in the 5th column
    
    sum_int = 0; sum_time = 0;
    for t = 1:no_trips
        nc = all_trips(t,1);
        cl = all_trips(t,2);
        tr = all_trips(t,3);
        int_ratio = cell2mat(Contractor{nc}.trips{1,cl}(tr,6));
        time_ratio = Contractor{1,nc}.trips{1,cl}{tr,3} / (capacity - Contractor{1,nc}.trips{1,cl}{tr,4});
        Contractor{1,nc}.trips{1,cl}{tr,5} = time_ratio;
        
        sum_int = sum_int + int_ratio;
        sum_time = sum_time + time_ratio;
        
    end
    
    %Overall badness ratio with respect to all the trips that edge appears
    EdgeList(e,3)= sum_int/no_trips;
    EdgeList(e,4)= sum_time/no_trips;
    
end

%Bigger the ratio worse
[~, I_int ] = sort(EdgeList(:,3), 'descend');
bad_edges_int = EdgeList(I_int(1:no_bad_edges),1:2);

[~, I_time ] = sort(EdgeList(:,4), 'descend');
bad_edges_time = EdgeList(I_time(1:no_bad_edges),1:2);

BadEdges_int = bad_edges_int;
BadEdges_time = bad_edges_time;
%BadEdges = unique([bad_edges_int; bad_edges_time],'rows');
end

