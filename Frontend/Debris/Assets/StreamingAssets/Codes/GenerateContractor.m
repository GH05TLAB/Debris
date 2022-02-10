
% EdgeList
% debris, time, capacity
% # of nodes, roads, contractors
%tic

%clc
%clear 

%load('ProblemData(Instance2).mat')
%Adj matrix for the big map

%The Hazus generated debris
%debris=debris2; %Previous wrong calculation of debris

%%%% Different debris distribution instances
% max_debris = max(debris);
% min_debris = min(debris);

%Uniformly draw integers 
%random_debris1 = randsample(ceil(max_debris),no_roads);
%Uniformly distribute the debris to different roads
%random_debris2 = debris(randperm(no_roads));

%debris = random_debris2;
%debris = random_debris1;

Time=zeros(no_nodes); Debris_original=zeros(no_nodes); 
for i=1:no_roads
    Time(EdgeList(i,1),EdgeList(i,2))=time(i);
    Time(EdgeList(i,2),EdgeList(i,1))=time(i);
    
    Debris_original(EdgeList(i,1),EdgeList(i,2))=debris(i);
    Debris_original(EdgeList(i,2),EdgeList(i,1))=debris(i);
end
Adjacency=Time>0;

%%%%%%%%%%%%%% Creating different initial solutions by changing the 
%%%% Edge assingment

%%%%!!!!!!!!!!!!!!!!USER INOPUT!!!!!!!!!!!!!!!!!!!!!!!!!
% random_edge_assignment = randi(3,[no_roads,1]);
% EdgeAssignment(:,1)=random_edge_assignment;

%% ============== NEW ============
% convert the EdgeAssignment to a cell array - in the future I will add
% into cells

%for i=1:size(EdgeAssignment,1)
%    Assignment{i,1} = EdgeAssignment(i,1); %cell array version of EdgeAssignment
%    Assignment{i,2} = EdgeAssignment(i,2); %cell array version of EdgeAssignment
%end



%% Trying a new assignment vec [58, 79] => assign it to contractor 1 too
% but debris collection is zero, just allowing traversal by cont 1
%Assignment{179,1}= [1,Assignment{179,1}];
%Assignment{179,2}= [0,Assignment{179,2}];  %0 percent debris
%%
%%
%Finding which edges are assigned to which contractor - and finding the
%connected subgraphs for each contractor

for nc=1:no_contractor

       contractor_edges = EdgeList(find(EdgeList(:,3) == nc),:);
       
    Contractor{nc}.TimeMatrix=zeros(no_nodes);
    Contractor{nc}.Debris=zeros(no_nodes);
    binary_nodes=zeros(1,no_nodes);
    
    for i=1:size(contractor_edges,1)
        f=contractor_edges(i,1); t=contractor_edges(i,2);
        Contractor{nc}.TimeMatrix(f,t)=Time(f,t);
        Contractor{nc}.TimeMatrix(t,f)=Time(t,f);
        
        
        Contractor{nc}.Debris(f,t)=Debris_original(f,t)* contractor_edges(i,3);
        Contractor{nc}.Debris(t,f)=Debris_original(t,f)* contractor_edges(i,3);
        binary_nodes(t)=1; %To see which nodes a contractor area scans
        binary_nodes(f)=1;
    end
    
    Contractor{nc}.nodes = find(binary_nodes>0);
    no_nodes_c=sum(binary_nodes);
    [Contractor]= findClusters(no_nodes_c, Contractor{nc}.TimeMatrix, nc, Contractor);
end

%save('Assignment.mat', 'Assignment')
%find the shortest 'time' path for all the nodes from the depot
NODES=1:no_nodes;
[distLabel, pred]=dijkstra(Time, depot, NODES);

save('DistancesfromDepot.mat', 'distLabel', 'pred')
%save('Pred.mat', 'pred')

%create routes for each subgraph - cluster of the contractors
for nc=1:no_contractor 
    
    no_cluster=length(Contractor{nc}.cluster);
    
    traversaltime_contractor=0; %Want to calculate the total time of a contractor - summation over all its clusters
    total_debris = 0; %for each contractor
    pathToDepot_C = 0;
    for i=1:no_cluster
        
        % get the closest node in that cluster and fix it as depot
        [C,I] = min(distLabel(Contractor{nc}.cluster{i}));
        new_depot= Contractor{nc}.cluster{i}(I(1));
             
        % get the path from the depot to the new depot
        path=new_depot; p=new_depot;
        while p~=depot
            p=pred(p);
            path=[p,path];
        end
        
        Contractor{nc}.pathtoDepot{i,1}=path;
        Contractor{nc}.pathtoDepot{i,2}=C; %distlabel of the new depot
        
        pathToDepot_C = pathToDepot_C + C;
        [Contractor]= routeConstruction(Contractor, capacity, Time, path, Contractor{nc}.Debris,nc,distLabel,i);
        
        no_trips=size(Contractor{1,nc}.trips{1,i},1); %%%NEW
        trips=1:no_trips;                             %%%NEW
        
        [Contractor]=cycleCancelling(Contractor,i,nc,trips);
        
        
        [total_traversal_time, Contractor, ~]=costCalculation(Contractor, Time, nc,i, capacity);
        
        [Contractor]=Improvement(Contractor, i, nc);
        
        [Contractor]=cycleCancelling(Contractor,i,nc,trips);
        
        %Another improvement on the routes - deleting the unnecessary
        %detours and shortening the length of trips
        trip_length_th = 4;
        if isempty(Contractor{nc}.trips{i}) ~= 1 %If the cluster is composed of non-debris edges only
                                                % there won't be any trip resulting from routeConstruction
        [Contractor] = ImprovementShorten (Contractor, i,nc, trip_length_th);
        end
        
        [total_traversal_time_improved, Contractor, collected_debris]=costCalculation(Contractor, Time, nc,i, capacity);
        
        traversaltime_contractor = traversaltime_contractor + total_traversal_time_improved;
        total_debris = total_debris + collected_debris;
       fprintf('Contractor: %d, Cluster: %d, Cost Improvement: %f \n',nc,i, total_traversal_time-total_traversal_time_improved)

    end
    
    time_to_collect = time_per_debris * total_debris;
    Contractor{nc}.TotalTime=time_to_collect + traversaltime_contractor + pathToDepot_C;
    Contractor{nc}.TotalProfit=(total_debris * revenue_per_debris) - ((traversaltime_contractor +pathToDepot_C) /2 *gas_per_distance);
    
    %considering a velocity of 30mph : distance becomes half of the
    %traversal time - totalprofit = revenue gained from collection - gas
    %cost incurred from traversal
end

[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_vec] = ComputeIntersection2(Contractor, depot, surrounding);
OVERLAP = sum(sum(node_intersection_vec));

profit_vec=zeros(1,no_contractor);
time_vec=zeros(1,no_contractor);

for i=1:no_contractor
    profit_vec(i) = Contractor{i}.TotalProfit;
    time_vec(i) = Contractor{i}.TotalTime;
end

%time and profit updated for the current iteration
[MAXTIME, contmaxtime]= max(time_vec);
[MINPROFIT2, contminprofit] = min(profit_vec);

%%calculate bad edges. 
%pr=0.1;int=0.1;
% [Contractor, BadCycles_profit, BadCycles_intersection] = detectBadTrips(Contractor, capacity,pr, int);
EdgeListMatrix = GenerateEdgeList( Contractor );

 par3 = 0.1;
[ BadEdges_int, BadEdges_time ] = detectBadEdges( EdgeListMatrix, Contractor, capacity, par3, EdgeList );
     
%save('Contractor2.mat', 'Contractor')
 
%save('IntersectionValue.mat', 'OVERLAP1')
%save('DeletedCycles_2.mat', 'BadCycles_profit', 'BadCycles_intersection')
%main4_unity();

    pathSplit=regexp(pwd,'\','split');
    initPath = '';

    for n = 1:numel(pathSplit)
    if(strcmp(pathSplit(n),'Codes'))
          break;
    end
   
        if n == 1
            initPath = strcat(initPath,pathSplit(n));
        else
            initPath = strcat(initPath,'\',pathSplit(n));
        end
   
    end

    badFile = strcat(initPath,'\Database\Input\badEdges_from_Matlab.csv');
    badFile = char(badFile);

    fprintf('%s',badFile);
    [fid, msg] = fopen(badFile,'w');
    if fid < 0 
         error('Failed to open file "%s" because: "%s"', badFile, msg);
    else
        csvwrite(badFile,BadEdges_time);
    end
    fclose(fid);
    
    badFile2 = strcat(initPath,'\Database\Input\badEdges_from_Matlab2.csv');
    badFile2 = char(badFile2);

    fprintf('%s',badFile2);
    [fid, msg] = fopen(badFile2,'w');
    if fid < 0 
         error('Failed to open file "%s" because: "%s"', badFile2, msg);
    else
        csvwrite(badFile2,BadEdges_int);
    end
    fclose(fid);
    
        
    brushedFile = strcat(initPath,'\Database\Input\brushedEdges_Matlab.txt');
    brushedFile = char(brushedFile);
        
    fprintf('\n%s',brushedFile);
    [fd, msg] = fopen(brushedFile,'w');
    
    ee = [];
    for i=1:no_contractor
         j = length(Contractor{i}.Edges);
        if(j > 1)
            e = [];
            for j = 1:length(Contractor{i}.Edges)
                e = [e; cell2mat(Contractor{i}.Edges(j))];
            end
        else
            e = cell2mat(Contractor{i}.Edges);
        end
        
        %e = cell2mat(Contractor{i}.Edges);
        e = [e , i*ones( length(e),1)];
        ee = [ee ; e];
    end 
    
    for j=1:length(EdgeList)
        
        c = [EdgeList(j,1), EdgeList(j,2)];
        [~, ix] = ismember(ee(:,[1,2]), c, 'rows');
        
        all_conts = ee(logical(ix),3);
        brush{j,1} = EdgeList(j,1); brush{j,2} = EdgeList(j,2); 
        brush{j,3} = all_conts;
    end
    
    for j = 1:length(brush)
        brushed_print{j,1} = num2str(brush {j,1});
        brushed_print{j,2} = num2str(brush {j,2});
        
        thiscell = '';
        for k = 1:length(brush{j,3})
            thiscell = strcat(thiscell, num2str(brush{j,3}(k)));
        end
        brushed_print{j,3} = thiscell;
        
        if fd < 0 
            error('Failed to open file "%s" because: "%s"', brushedFile, msg);
        else
            fprintf(fd,'%s,%s,%s\r\n',brushed_print{j,1},brushed_print{j,2},brushed_print{j,3});
        end 
    end 
    fclose(fd); 
    
    scoreFile = strcat(initPath,'\Database\Input\score_info_fromMatlab.txt');
    scoreFile = char(scoreFile);

    fprintf('\n%s',scoreFile);
    [fid, msg] = fopen(scoreFile,'w');
    if fid < 0 
         error('Failed to open file "%s" because: "%s"', scoreFile, msg);
    else
        fprintf(fid,'%f,%f',MAXTIME, MINPROFIT2);
        for i=1:no_contractor
            fprintf(fid,'\r\n%d,%f,%f,%f',i,Contractor{i}.TotalTime,Contractor{i}.TotalProfit, OVERLAP);
        end
    end
    fclose(fid);
      
%toc