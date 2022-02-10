function [Contractor] = fixBrushingErasing(EdgeList, Contractor, brushed_edges, obj_select, time_vec, profit_vec, ...
    TimeMatrix, time_per_debris, revenue_per_debris, gas_per_distance, capacity, depot, distLabel, pred)

no_edges = size(brushed_edges,1);
edge_change = [];
%objectives selected is a bool vector of time-pr-int

time_selected=obj_select(1); profit_selected=obj_select(2); intersection_selected=obj_select(3);

for e = 1:no_edges
    from = brushed_edges{e,1};
    to = brushed_edges{e,2};
    nc_new = brushed_edges{e,3};
    new_nc_len = length(nc_new);
    
    if isempty(nc_new)~=1 %If a brushing is been done - the edge is not empty
        
        nc_old = [];
                
        if isempty(EdgeList{from,to})==1; 
            t_debris1=0; 
        else
            t_debris1=sum(EdgeList{from,to}(:,4));
            nc_old = [nc_old; EdgeList{from,to}(:,1)]; %why a double of old and edgelist?
        end
        if isempty(EdgeList{to, from})==1; 
            t_debris2=0;
        else 
            t_debris2=sum(EdgeList{to,from}(:,4));
            nc_old = [nc_old; EdgeList{to,from}(:,1)]; %why a double of old and edgelist?
        end
        
        nc_old = unique(nc_old);
            
        total_debris = t_debris1 + t_debris2 ;
        
        debris_div = total_debris / new_nc_len;

        for u = 1:length(nc_old) %Delete the nc_old            
            nc = nc_old(u);   
            
            Contractor{nc}.Debris(from,to) = 0;
            Contractor{nc}.Debris(to,from) = 0;
            
            Contractor{nc}.TimeMatrix(from,to) = 0;
            Contractor{nc}.TimeMatrix(to,from) = 0;
            
            Contractor{nc}.nodes=[];
            ss = sum(Contractor{nc}.TimeMatrix);
            Contractor{nc}.nodes = find(ss>0);
        end
        
        for nc = nc_new %Add the nc_new
            Contractor{nc}.Debris(from,to) = debris_div;
            Contractor{nc}.Debris(to,from) = debris_div;
            
            Contractor{nc}.TimeMatrix(from,to) = TimeMatrix(from,to);
            Contractor{nc}.TimeMatrix(to,from) = TimeMatrix(from,to);
            
            Contractor{nc}.nodes=[];
            ss = sum(Contractor{nc}.TimeMatrix);
            Contractor{nc}.nodes = find(ss>0);
        end
        
    else %the edge is not assigned any contractor
        
        
        for y = 1:size(EdgeList{from,to},1)
            if EdgeList{from,to}(y,4)>0
                edge_change = [edge_change; [from, to , EdgeList{from,to}(y,:)]];
            end
        end
        for y = 1:size(EdgeList{to,from},1)
            if EdgeList{to,from}(y,4)>0
                edge_change = [edge_change; [to, from , EdgeList{to,from}(y,:)]];
            end
        end
        
        

    end
end

if isempty(edge_change)~=1
[Contractor,~] = RepairSolution(Contractor, time_vec, profit_vec, edge_change, time_selected, ...
    profit_selected, intersection_selected, TimeMatrix, time_per_debris, revenue_per_debris, ...
    gas_per_distance, capacity, depot);
end
        

[Contractor] = ReconstructContractor(Contractor, distLabel,pred,...
    time_per_debris, revenue_per_debris, gas_per_distance,depot,capacity,TimeMatrix);

    
end

