%% this to be run when the game starts.
%% update problem data edgelist.
%% run the generate contractor 

%% update problem data edgelist
%% run main
clc
clearvars -except tcpipServer

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
    
    path = strcat(initPath,'\Database\Output\edgelist_forMatlab.csv');
    path = char(path);
X = importdata(path);

load('brushed_edges.mat');
load('ProblemData(Instance2).mat');

    path = strcat(initPath,'\Database\Output\debris.csv');
    path = char(path);
    
debris = [];
debris = importdata(path);

header = X(1,:);
X(1,:) = [];
B = [];

for k = 1:size(X)
    B = str2double(regexp(num2str(X(k,3)),'\d','match'));
    brushed_edges{k,1} = X(k,1);
    brushed_edges{k,2} = X(k,2);
    brushed_edges{k,3} = B;
end

EdgeList = X;
GenerateContractor(); 
