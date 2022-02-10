
%This loops through the repair solution with different objectives
% After user makes the changes - repair algorithm
 
time_selected = header(1);
profit_selected = header(2);
intersection_selected = header(3);
load('brushed_edges.mat')
%Get a profit and time vec to see the relative difference of contractor's
%values
profit_vec=zeros(1,no_contractor);
time_vec=zeros(1,no_contractor);

for i=1:no_contractor
    
    profit_vec(i) = Contractor{i}.TotalProfit;
    time_vec(i) = Contractor{i}.TotalTime;
end

EdgeListMatrix = GenerateEdgeList( Contractor );

%this is the previous dijkstra we had - nothing changed
NODES=1:no_nodes;
[distLabel, pred]=dijkstra(Time, depot, NODES);
%distlabel is the shortest distance to all the nodes (no_nodes x 1 vector)
% If for every node in a particular cluster you look at those dist labels
% and find the node with the min dist label obv that node is the closest
% node in that cluster to the original depot 
% You start and end all routes from that hypothetical depot (cluster
% depot)
% When you are calculating the overall cost of a cluster (summation of all
% route costs + path to original depot cost)


%edges are brushed based on their debris allocations
%When human assigns a contractor on an edge it automatically divides the debris
%on the edge. If computer is asked to repair based on an objective than you
%can see only traversing contractors on edges


[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);
OVERLAP1 = sum(sum(node_intersection_matrix)); %The total overlap


%% 
%% Detecting bad edges
%par3 is the threshold parameter
par3 = 0.25;
[ BadEdges ] = detectBadEdges( EdgeListMatrix, Contractor, par3, EdgeList );

%Objectives:
% Min MAXTIME
% Max MINPROFIT
MAXTIME1= max(time_vec);
MINPROFIT1 = min(profit_vec);

OVERLAP_VEC = OVERLAP1;
TIME_VEC= MAXTIME1;
PROFIT_VEC = MINPROFIT1;
       
        
[Contractor] = fixBrushingErasing(EdgeListMatrix, Contractor, brushed_edges, oo, time_vec, ...
            profit_vec, Time, time_per_debris, revenue_per_debris, gas_per_distance, capacity, depot, distLabel,pred);

[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);
OVERLAP2 = sum(sum(node_intersection_matrix));
        
profit_vec=zeros(1,no_contractor);
time_vec=zeros(1,no_contractor);
        
        for i=1:no_contractor
            profit_vec(i) = Contractor{i}.TotalProfit;
            time_vec(i) = Contractor{i}.TotalTime;
        end
        
        %time and profit updated for the current iteration
        [MAXTIME2, contmaxtime]= max(time_vec);
        [MINPROFIT2, contminprofit] = min(profit_vec);
        

        fprintf('Intersection: %f, \t Improvement: %f \n',OVERLAP2, OVERLAP1-OVERLAP2);
        fprintf('Completion Time: %f, \t Improvement: %f, \t Contractor(max_time): %f \n',MAXTIME2, MAXTIME1-MAXTIME2, contmaxtime);
        fprintf('Min Profit: %f, \t Improvement: %f, \t Contractor(min_profit): %f \n',MINPROFIT2, MINPROFIT1-MINPROFIT2, contminprofit);
        
        
        OVERLAP1 = OVERLAP2;
        MAXTIME1 = MAXTIME2;
        MINPROFIT1 = MINPROFIT2;

        EdgeListMatrix = GenerateEdgeList( Contractor );

    pathSplit=regexp(pwd,'\','split');
    initPath = '';

    for n = 1:numel(pathSplit)
    if(strcmp(pathSplit(n),'Backend'))
          break;
    end
   
        if n == 1
            initPath = strcat(initPath,pathSplit(n));
        else
            initPath = strcat(initPath,'\',pathSplit(n));
        end
   
    end

    badFile = strcat(initPath,'\Frontend\Debris\Assets\Database\Input\badEdges_from_Matlab.csv');
    badFile = char(badFile);

    fprintf('%s',badFile);
    [fid, msg] = fopen(badFile,'w');
    if fid < 0 
         error('Failed to open file "%s" because: "%s"', badFile, msg);
    else
        csvwrite(badFile,BadEdges);
    end
    fclose(fid);
    
    scoreFile = strcat(initPath,'\Frontend\Debris\Assets\Database\Input\score_info_fromMatlab.txt');
    scoreFile = char(scoreFile);

    fprintf('%s',scoreFile);
    [fid, msg] = fopen(scoreFile,'w');
    if fid < 0 
         error('Failed to open file "%s" because: "%s"', scoreFile, msg);
    else
        fprintf(fid,'%f,%f',MAXTIME2, MINPROFIT2);
        for i=1:no_contractor
            fprintf(fid,'\r\n%d,%f,%f,%f',i,Contractor{i}.TotalTime,Contractor{i}.TotalProfit, OVERLAP1);
        end
    end
    fclose(fid);