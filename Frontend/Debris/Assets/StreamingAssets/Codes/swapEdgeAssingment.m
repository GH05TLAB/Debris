function [ Contractor, nc_old] = swapEdgeAssingment( Contractor, Edge, e1,e2 )

   nc_old = find(~cellfun(@isempty,Edge{e1,e2}.contractor));
   
   for nc = nc_old
       x = Edge{e1,e2}.contractor{nc}.cluster;
       cl = find(~cellfun(@isempty,x)); %This should be a single number
       e = [e1,e2; e2,e1];
       [Contractor{nc}.Edges{cl},~] = setdiff(Contractor{nc}.Edges{cl},e, 'rows');
   end
   
   best_nc =  Edge{e1,e2}.best_contractor;
   best_cl = Edge{e1,e2}.best_cluster;
   
%   try
   Contractor{best_nc}.Edges{best_cl} = [Contractor{best_nc}.Edges{best_cl}; [e1,e2;e2,e1]];
%    catch 
%        Contractor{best_nc}.Edges{best_cl} = [Contractor{best_nc}.Edges{best_cl}; [e1,e2;e2,e1]];
%    end
end

