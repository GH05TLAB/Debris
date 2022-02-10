function [ Contractor ] = findClusters( ~ , A, nc, Contractor )

remaining_nodes=Contractor{nc}.nodes;
max_node=max(remaining_nodes);
explored=ones(1,max_node); %for the dummy nodes put 1 directly
explored(remaining_nodes)=0;

if isempty(remaining_nodes)==1
    all_nodes_traversed=0;
else
    all_nodes_traversed=1;
end
    

iter=1;

no_cluster=0;

while all_nodes_traversed %Until all the nodes are processed
    
    no_cluster=no_cluster +1;
    Contractor{nc}.Edges{no_cluster}=[];
    root=remaining_nodes(1);
    Q=root;   
    explored(root)=1;
    
    Contractor{nc}.cluster{no_cluster}=[root];
    
    while isempty(Q)~=1 %List to traverse the nodes

        current_node=Q(1);
        Q(1)=[]; %Remove the current node from the list

        neigh=find(A(current_node,:)>0);
        
        for nn=neigh
           Contractor{nc}.Edges{no_cluster}=[Contractor{nc}.Edges{no_cluster};[current_node,nn]];
        end
           
        %Get the neighbors that are not already visited
        %Some neighbors might be already put in the tree
        u=ones(1,length(neigh))-explored(neigh);
        neigh=neigh .* u;
        neigh=neigh(neigh>0);
        
        
        explored(neigh)=1;
        
        Contractor{nc}.cluster{no_cluster}=[Contractor{nc}.cluster{no_cluster}, neigh];
        
        
        Q=[Q,neigh]; %Neighbors are explored 
        iter=iter+1;

    end

    remaining_nodes=find(explored==0);
    
    if isempty(remaining_nodes)==1 
        all_nodes_traversed=0; 
    end
end

%until no_cluster, the previous clusters are overwritten , we need to get
%rid of the rest of the clusters remaining
try
no_prev_cluster = length(Contractor{nc}.cluster);
catch
    no_prev_cluster = 0;
end
 for y = no_cluster +1 : no_prev_cluster
     Contractor{nc}.cluster{y} = [];
     Contractor{nc}.Edges{y} = [];
     no_tr = length(Contractor{nc}.trips{y});
     
     for t = 1:no_tr
         for col = 1:6 % all the columns of trips
            Contractor{nc}.trips{y}{t,col}=[];
         end
         
     end
     Contractor{nc}.trips{y} = Contractor{nc}.trips{y}((~cellfun('isempty',Contractor{nc}.trips{y})));
 end
 try
 Contractor{nc}.cluster = Contractor{nc}.cluster((~cellfun('isempty',Contractor{nc}.cluster)));
 catch
    Contractor{nc}.cluster = [];
 end
 
 
 try
    Contractor{nc}.Edges = Contractor{nc}.Edges((~cellfun('isempty',Contractor{nc}.Edges)));
 catch
    Contractor{nc}.Edges = [];
 end

 try
 Contractor{nc}.trips = Contractor{nc}.trips((~cellfun('isempty',Contractor{nc}.trips)));
 catch
     Contractor{nc}.trips = [];
 end
end

