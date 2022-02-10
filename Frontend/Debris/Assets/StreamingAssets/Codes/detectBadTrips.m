function [ Contractor, BC_profit, BC_overlap ] = detectBadTrips( Contractor, capacity, pr_percentage, int_percentage)

%% This function detects bad trips in terms of profit and time too
% Its based on a ratio of total time to the collected debris

% the ratio being bad refers to relatively bad cycles 


for nc = 1: length(Contractor) %each contractor
    for cl = 1: length(Contractor{1,nc}.cluster)  %each cluster
        
        trip_no = size(Contractor{1,nc}.trips{1,cl},1);
        %Detect the 10 percent of the bad trips for profit in each cluster
        %This 10 percent is of course a parameter - we can change it 
        %also I could've given it as input to the function too so that we
        %can play around with different values to see if it makes a better
        %progresss
        %Edit: I added as input
        
        no_bad_pr = ceil(trip_no * pr_percentage);  
        
        %For intersection I made up the parameter 0.05 - have no idea why
        %we can also give this as an input %Edit: I added as input
        no_bad_ovlp = ceil(trip_no * int_percentage);
        
        ratioVec = []; intersectionVec=[];
        for i = 1:  trip_no % each trip calculate the time/debris ratio
            if isempty(Contractor{1,nc}.trips{1,cl}{i,1})~=1
                ratio = Contractor{1,nc}.trips{1,cl}{i,3} / (capacity - Contractor{1,nc}.trips{1,cl}{i,4}); %The ratio of total cost of the trip to collected debris
            else
                ratio=0;
            end
            % Higher the ratio - worst
            Contractor{1,nc}.trips{1,cl}{i,5} = ratio;
            ratioVec = [ratioVec ; ratio];
            
            %We already calculated the intersection ratio in
            %ComputeIntersection2.m and put it to the contractor
            %It is a little weird since I first put to the 6th column of
            %the contractor and now using the 5th column to store the ratio
            %of time/ debris. Obviously I decided to make a ratio for
            %intersection later, and I didn't wanted to change the indices
            %again :) So hope thats not confusing!
            intersectionVec = [intersectionVec ; Contractor{1,nc}.trips{1,cl}{i,6}];
        end
        

        % I believe this part is not that necessary - I though maybe I
        % would've used it later on that's why I stored it in a structured
        % way but now I am seeing that I could've done it more efficiently
        [S , I] = sort(ratioVec, 'descend');
        BadCycles_profit{nc}.cluster{1,cl} = I(1:no_bad_pr) ; %Keep track of the indices of bad cycles in each cluster
        BadCycles_profit{nc}.cluster{2,cl} = S(1:no_bad_pr) ; %Also their ratios
        
        [S , I] = sort(intersectionVec, 'descend');
        BadCycles_overlap{nc}.cluster{1,cl} = I(1:no_bad_ovlp) ; %Keep track of the indices of bad cycles in each cluster
        BadCycles_overlap{nc}.cluster{2,cl} = S(1:no_bad_ovlp) ;
        
    end
end


% Store all of the bad trips in a matrix 
% BC_Matrix_P : bad trips in terms of profit 
% BC_Matrix_O : bad trips in terms of intersection value
        % Create a matrix 
        % Each row indicates a "bad" trip 
        % columns: contractor,cluster no, trip no 

BC_Matrix_P =[]; BC_Matrix_O = [];
for nc = 1: length(Contractor) %each contractor
    for cl = 1: length(Contractor{1,nc}.cluster)  %each cluster
        selected_trips_p = length(BadCycles_profit{1,nc}.cluster{1,cl});
        for tr = 1:selected_trips_p
            BC_Matrix_P = [BC_Matrix_P ; [nc, cl , BadCycles_profit{1,nc}.cluster{1,cl}(tr), BadCycles_profit{1,nc}.cluster{2,cl}(tr)]];
        end
        
        selected_trips_o = length(BadCycles_overlap{1,nc}.cluster{1,cl});
        for tr = 1:selected_trips_o
          BC_Matrix_O = [BC_Matrix_O ; [nc, cl , BadCycles_overlap{1,nc}.cluster{1,cl}(tr), BadCycles_overlap{1,nc}.cluster{2,cl}(tr)]];
        end
    end
end

% Prev calculation finds the worst trip in a cluster, but what if that trip
% is not bad overall, just relatively bad in  its own cluster
%Comparison of all the "bad" trips in all of the network
%You may want to use this part or not - based on our preference 
%for now I used it, I feel like it makes more sense - we can disucss it later on

top_trips = ceil(size(BC_Matrix_P,1) *1); % Let's say we are going to get the top half
[~ , I] = sort(BC_Matrix_P(:,4), 'descend');
BC__P_filtered = BC_Matrix_P(I(1:top_trips),1:3);  %Extra filtered profit matrix

[~ , I] = sort(BC_Matrix_O(:,4), 'descend');
BC__O_filtered = BC_Matrix_O(I(1:top_trips),1:3);  %Extra filtered overlap matrix

BC_overlap = BC__O_filtered;
BC_profit = BC__P_filtered ;
end

