function [Contractor]= routeConstruction(Contractor, capacity, Time, path, Debris,nc,distLabel,u)
rng(123,'twister')

depot= path(end);
space = capacity; % Leftover space in the truck

node=depot;
RemDebris=Debris; %Matrix keeping tack of the remaining debris maounts on roads

no_cluster=length(Contractor{nc}.cluster); % find the number of clusters

    
    trip_cost=0; trip=depot; Contractor{nc}.trips{u}={}; t=0; debris_col_vec=[]; 

    [d, pred]=dijkstra(Contractor{nc}.TimeMatrix,depot, Contractor{nc}.cluster{u});
    unserved_arcs = Contractor{nc}.Edges{u};
    for i=1:size(unserved_arcs,1) %Put the starting debris of each road - and time info
        unserved_arcs(i,3)=Debris(unserved_arcs(i,1),unserved_arcs(i,2));
        unserved_arcs(i,4)=Time(unserved_arcs(i,1),unserved_arcs(i,2));
    end

    leftover_check=true;
    
    %If the cluster is already composed of edges with no debris at all!
    if sum(unserved_arcs(:,3))==0
        leftover_check=false;
        Contractor{nc}.cluster{u}=[]; %Close that cluster
        Contractor{nc}.Edges{u}=[];

    end
    
    while leftover_check
        
        
        pp=(unserved_arcs(unserved_arcs(:,3)>0,1)==node);
        pp2=unserved_arcs(unserved_arcs(:,3)>0,2); %Get the possible nodes we can go from the current node - edges with debris on it
        potential=pp2(pp);
        time_potential=unserved_arcs(pp,4);
        dist_potential=distLabel(potential); %the distance of the nodes to main depot (also the new depot) - if closer to main depot then it is closer to the new depot
        
        if isempty(potential)==1 % if there is not debris on the neighbors
            timevec=Contractor{nc}.TimeMatrix(:,node);
            neigh= find(timevec>0);
            if length(neigh)~=1 %if you have several options, select wisely
                neigh2=setdiff(neigh,trip(max((end-1),1))); %don't go back to where you were
                %dist_potential=timevec(neigh2);
                %[~,ind]=min(dist_potential);
                random_index=randi(length(neigh2));
                p= neigh2(random_index);  
            else p=neigh;
            end
            
        else
            if space > 0.5*capacity                           %Pick the shortest distanced - timed edge
                [~,ind]=min(time_potential);
                p= potential(ind);                            %The new node to proceed
            else                                               %getting closer to the depot
                [~,ind]=min(dist_potential);
                p= potential(ind);
            end
         end
        
        collected_debris = min(RemDebris(node,p),space);   %collect as much as you can
        trip_cost=trip_cost + unserved_arcs(i,4);
        if collected_debris ~=0
        %decrease the debris for both directions
            i= ismember(unserved_arcs(:,1:2),[node,p],'rows');
            unserved_arcs(i,3)= unserved_arcs(i,3) - collected_debris;
            i= ismember(unserved_arcs(:,1:2),[p,node],'rows');
            unserved_arcs(i,3)= unserved_arcs(i,3) - collected_debris;
            RemDebris(node,p)=RemDebris(node,p)-collected_debris;
            RemDebris(p,node)=RemDebris(p,node)-collected_debris;
            space=space-collected_debris;
        end
        
        debris_col_vec=[debris_col_vec,collected_debris];
        
        node=p; % next trip is going to start from depot
        trip=[trip,p];

        if space == 0  || (node==depot) || sum(unserved_arcs(:,3))==0
            %if you are out of capacity go back to the depot from the closest way or you end up at depot traversing all edges
            if sum(debris_col_vec)~=0
                p=node; return_path=[];
                while p~=depot
                    try
                    p=pred(p);
                    catch
                        p=pred(p);
                    end
                    return_path=[return_path,p];
                end
                space=capacity; 
                t=t+1;
                trip=[trip,return_path]; %trip after depot unil coming back to depot
                debris_col_vec=[debris_col_vec, zeros(1,length(return_path))]; %not collecting anything when returning back to the depot

                % All the info about trips - route + debris +total cost 

                Contractor{nc}.trips{u}{t,1}= trip; %different vehicle trips
                Contractor{nc}.trips{u}{t,2} = debris_col_vec;
                Contractor{nc}.trips{u}{t,3}=trip_cost + d(node); % adding the shortest going back to depot distance
                
                %%%%  ------------------ %%%%% ADDED
                Contractor{nc}.trips{u}{t,4} = 200-sum(debris_col_vec); %To keep track of the non-empty trips
                %%%%% -------------------%%%%%%%%%%
           end
                trip_cost=0; trip=depot; debris_col_vec=[];
                node=depot; % next trip is going to start from depot
        end
        
        
        
        if sum(unserved_arcs(:,3))==0
            leftover_check=false;
        end
    end
    
    

    
end


