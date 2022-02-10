
%This loops through the repair solution with different objectives




% After user makes the changes - repair algorithm

clc
clear

%[time, profit, intersection]
obj_category={[1,0,0],[1,0,1], [0,0,1],[0,1,0], [0,1,1],[1,1,0],[1,1,1]};
obj_cat_name= {'Time', 'Time + Int', 'Int', 'Profit', 'Profit+Int', 'Profit+Time', 'Profit+Time+Int'};
persona_name = {'All bad cycles Profit/time',' Bad cycles Intersection', 'Visual Convex Hull', 'Visual C.H. with erasing'};
for persona = 1:4 %Persona 1 bad cycles profit/time - persona 2 bad cycles intersection - persona 3 convex hull overlap
for o = 1:6 %There are a total of 7 combinations of objectives
    oo = obj_category{o};
    time_selected = oo(1);
    profit_selected = oo(2);
    intersection_selected = oo(3);

%load('Contractor.mat') % indicates the previously given solution to the user that the user is goint to play with
%load('Contractor(shuffledDebris).mat')
%load('Contractor(RandomDebris).mat')
load('Contractor2.mat')
load('ProblemData(Instance2).mat') %The problem data that is never going to change
%load('ProblemData4.mat')
%load('Regions.mat') %No need anymore

%load('brushed_edges.mat') % from, to , new_nc(as a list)

%Get a profit and time vec to see the relative difference of contractor's
%values
profit_vec=zeros(1,no_contractor);
time_vec=zeros(1,no_contractor);

for i=1:no_contractor
    profit_vec(i) = Contractor{i}.TotalProfit;
    time_vec(i) = Contractor{i}.TotalTime;
end


% newCoord = zeros(no_nodes,2);
% for coord = 1:no_nodes
%     lat = Coordinates(coord,2);
%     lon = Coordinates(coord,1);
%     alt=0;
%     [x,y]=getCartesianCoord(lat,lon,alt);
%     newCoord(coord,2)=x; newCoord(coord,1)=y;
% end

newCoord = Coordinates;

%[ d ] = euclidianDistance( x1, x2, y1, y2 );
edgeCoord = getEdgeCoord(EdgeList, newCoord);


%brushed_edges = visualAttractiveness2(Contractor, EdgeList, edgeCoord, newCoord);


EdgeListMatrix = GenerateEdgeList( Contractor );

%this is the previous dijkstra we had - nothing changed
NODES=1:no_nodes;
[distLabel, pred]=dijkstra(Time, depot, NODES);


%edges are brushed based on their debris allocations
%When human assigns a cont on an edge it automatically divides the debris
%on the edge. If computer is asked to repair based on an objective than you
%can see only traversing contractors on edges

% obj_selected = [1, 0 , 0]; %Time- Profit-Intersection selections indicated with 1 if selected
% [Contractor] = fixBrushingErasing(EdgeListMatrix, Contractor, brushed_edges, obj_selected, time_vec, ...
%             profit_vec, Time, time_per_debris, revenue_per_debris, gas_per_distance, capacity, depot, distLabel,pred);
% 

%%%%%%%%%%%%%%%%%%%%%

[ surrounding ] = findSurrounding( Contractor );
[Contractor,  node_intersection_matrix] = ComputeIntersection2(Contractor, depot, surrounding);
OVERLAP1 = sum(sum(node_intersection_matrix)); %The total overlap

par1 = 0.1 ; par2=0.1; %The explanation of these parameters are inside the following function
[Contractor, BadCycles_profit, BadCycles_intersection] = detectBadTrips(Contractor, capacity, par1, par2);


%%Detecting bad edges
%par3 is the threshold parameter
par3 = 0.25;
[ BadEdges ] = detectBadEdges( EdgeListMatrix, Contractor, par3, EdgeList );

%NEW!!! Detecting bad regions
%Assume that several regions are given with node numbers
%[ BadRegions_time, BadRegions_profit, BadRegions_intersection ] = detectBadRegions( regions, Contractor );

%trip_id is just the matrix the user decides to delete
%I assumed he decides to delete all the 'bad' cycles we provide him in
%terms of profit/time
%What kind of bad cycles to provide is a matter of questions

if persona ==1
trip_id = BadCycles_profit;
[ edge_change ] = triptoEdge( Contractor, trip_id );
elseif persona==2
trip_id = BadCycles_intersection;
[ edge_change ] = triptoEdge( Contractor, trip_id );
end


%from, to, nc information 
if persona ==3 || persona ==4

if persona==4
    brushed_edges = visualAttractiveness(Contractor, EdgeList, edgeCoord);
else
    brushed_edges = visualAttractiveness2(Contractor, EdgeList, edgeCoord, newCoord);
end
brushed_edges = num2cell(brushed_edges);
if persona ==4; brushed_edges{1,3}=[];end
end

%% Convert the trip_id to edge matrix
%So that you would have the same data structure
%edge change are the edges that will be transfered








%Objectives:
% Min MAXTIME
% Max MINPROFIT
MAXTIME1= max(time_vec);
MINPROFIT1 = min(profit_vec);
%OBJ = char('Time' ,'Profit', 'Intersection');
%10 replications on the game playing
%User deletes cycles and we repair/improve the perturbed solution, give
%another set of candidate bad cycles he deletes again....

OVERLAP_VEC = OVERLAP1;
TIME_VEC= MAXTIME1;
PROFIT_VEC = MINPROFIT1;



    
for replication = 1:15
        %The options user can select the solution to be improved
        %For now I defined it by hand - but this part is going to be decided by
        %the human
        %Which options he picks for the algorithm to improve?
        
%          time_selected = true; 
%     profit_selected = true; 
%     intersection_selected =false;   
        
%%%%%%%%%%%%%!!!!!!!!!!!!!! Either do RepairSolution + Reconstruct with the
%%%%%%%%%%%%%trip_id. OR do fixbrushingerasing given the brushed
%%%%%%%%%%%%%edges!!!!!!!!!!!!!!!!!!!!!!

if persona ==1 || persona==2
%         Considering the trip_id is the set of cycles(trips) deleted by
%         repair solution based on the objectives to be improved defined by user
        [Contractor,predicted_improvement] = RepairSolution(Contractor, time_vec, profit_vec, edge_change, time_selected, ...
            profit_selected, intersection_selected, Time, time_per_debris, revenue_per_debris, ...
            gas_per_distance, capacity, depot);
        
        
        %For the re-assigned regions for each contractor, we reconstruct
        %Contractor data
        [Contractor] = ReconstructContractor(Contractor, distLabel,pred,...
            time_per_debris, revenue_per_debris, gas_per_distance,depot,capacity,Time);
else         
        
        [Contractor] = fixBrushingErasing(EdgeListMatrix, Contractor, brushed_edges, oo, time_vec, ...
            profit_vec, Time, time_per_debris, revenue_per_debris, gas_per_distance, capacity, depot, distLabel,pred);
end
        
        %In order to find the new ratios for intersection, calculate the
        %surrounding info on the updated solution
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
        
        %I just wanted to see how much improvement in minprofit and maxtime it makes
        %Its just for me to see, if you want you can discard this part
        fprintf('Iteration: %d \n',replication);
        %fprintf('Selected Objectives: %s \n ',OBJ(obj_bool,:));
        %fprintf('Predicted Improvement: %d \n', predicted_improvement);
        fprintf('Intersection: %f, \t Improvement: %f \n',OVERLAP2, OVERLAP1-OVERLAP2);
        fprintf('Completion Time: %f, \t Improvement: %f, \t Contractor(max_time): %f \n',MAXTIME2, MAXTIME1-MAXTIME2, contmaxtime);
        fprintf('Min Profit: %f, \t Improvement: %f, \t Contractor(min_profit): %f \n',MINPROFIT2, MINPROFIT1-MINPROFIT2, contminprofit);
        
        OVERLAP_VEC = [OVERLAP_VEC,OVERLAP2];
        TIME_VEC=[TIME_VEC, MAXTIME2];
        PROFIT_VEC=[PROFIT_VEC, MINPROFIT2];
        
        OVERLAP1 = OVERLAP2;
        MAXTIME1 = MAXTIME2;
        MINPROFIT1 = MINPROFIT2;
        
        %Get the new bad trips to improve in the next iteration
        if persona ==1 || persona ==2
            [Contractor, BadCycles_profit, BadCycles_intersection] = detectBadTrips(Contractor, capacity, par1,par2);
            trip_id = BadCycles_profit;
            if persona==2
                trip_id = BadCycles_intersection;
            end
            [ edge_change ] = triptoEdge( Contractor, trip_id );
        else
           
            if persona==4
                brushed_edges = visualAttractiveness(Contractor, EdgeList, edgeCoord);
%                 brushed_edges(:,3)=[];
            else
                brushed_edges = visualAttractiveness2(Contractor, EdgeList, edgeCoord, newCoord);
            end
            brushed_edges = num2cell(brushed_edges);
            if persona ==4; brushed_edges{1,3}=[];end
            
        end
        EdgeListMatrix = GenerateEdgeList( Contractor );
    end
    
    Rep(o).obj(persona).profit = PROFIT_VEC;
    Rep(o).obj(persona).time = TIME_VEC;
    Rep(o).obj(persona).int = OVERLAP_VEC;
    
    
end
end

load('ALLREP(4PersonasInst2).mat')%- ALLREP is for random debris

load('REP(Person4).mat')
load('ALLREP(4Personas).mat')%- ALLREP is for random debris

% load('REP(Person1-2).mat')
% load('REP3.mat')
obj_cat_name= {'Time', 'Time + Int', 'Int', 'Profit', 'Profit+Int', 'Profit+Time', 'Profit+Time+Int'};
persona_name = {'All bad cycles Profit/time',' Bad cycles Intersection', 'Visual Overlap Brushing', 'Visual Overlap Erasing'};
color_vec = {[1, 0.1, 0.6],[0, 0.6, 0 ],[0.75 0.75 0.25],'b',[0.88 0.69 0.73],'c'};

figure 
hold on 

for p = 4
for o=1:6
    plot(1:16, Rep(o).obj(p).int,'-*','MarkerSize',10,'DisplayName',obj_cat_name{o},'Color',color_vec{o},'LineWidth',2)    
    %plot(1:16, Rep(o).obj(p).time,'-*','DisplayName',persona_name{p},'Color',color_vec{p},'LineWidth',2,'MarkerSize',10)   
end
end
title('Change in Intersection wrt diff repairs (debris random, persona 4, Instance2)')
%title('Change in Profit wrt diff personas (debris random, Instance 2, repair for P+I)')
xlabel('Iteration')
ylabel('Objectives')
legend('show')
legend('Location','southeast')
hold off

% figure
% hold on
% %plot( 1:4,TIME_VEC,'-*')
% %plot(1:4,OVERLAP_VEC.*100,'-*','color','r')
% plot(1:21,TIME_VEC,'-*',1:21,PROFIT_VEC,'-*')
% title('Improvement based on Profit + Time')
% xlabel('Iteration')
% ylabel('Objectives')
% hold off
%
% legend('Time', 'Profit')%, 'Intersection')
%
% %--------------%
% figure
% hold on
% plot(1:21,OVERLAP_VEC,'-*','color','r')
% title('Improvement based on Profit + Time')
% xlabel('Iteration')
% ylabel('Overlap Objective')
% hold off
%
% [ob1 , i ]= max(PROFIT_VEC);
% ob2 = TIME_VEC(i);
% ob3 = OVERLAP_VEC(i);
