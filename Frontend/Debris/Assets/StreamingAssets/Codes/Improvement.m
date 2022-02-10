function [ Contractor ] = Improvement1( Contractor, i ,nc)

% Start from the full trip and fill it up from the other trips - this way
% you can empty some cycles from other trips and shoten the trips

nodes=Contractor{nc}.cluster{i}; %The nodes in that cluster
no_trips=size(Contractor{1,nc}.trips{1,i},1);

if no_trips ~=1
    
    Q_Empty=[];
    Q2_original=1:no_trips;
    Q= cell(no_trips,2);
    for r=1:no_trips  % Create Q1 and Q2
        if Contractor{nc}.trips{1,i}{r,4} > 0;
            Q_Empty=[Q_Empty,r];
            Q{r,1}=setdiff(Q2_original,r);  %The rest goes to Q2  - just for 1 non-empty trip for the rest of Q1 ; its associated Q2 is calculated later
        end;
    end % Check the trips with not-full capacity / couldn't do a vector operation with the cell array thats why checked it one-by-one with a for loop
    
    %%
    % Q_empty = list of empty trip numbers
    % Q : 1st column is the possible trips that you can consider; full
    % trips that you can get debris from
    % 2nd column is the predecessor - in the previous iteration from which
    % trip you got debris to be full - or which trip made it empty - both
    % ways
    % The number of rows equals to the number of trips
    % Termination upon not doing any changes - debris transfer
    %%
    
    check=true; transfer_check=true;
    retrace_check=false;
    max_iter=1000; total_iter=0;
    
    while check
        
        for t=Q_Empty  % for the empty trip
            iter_each_v=0;
            Q_Empty(1)=[]; %remove that trip
            Q{t,1}= setdiff(Q2_original,union(Q{t,2},t)); %all the possible trips to be considered - except the trip itself (t)
            transfer_check_each_v=ones(1,length(Q{t,1})); %You can get debris from multiple trips - just to see from which trips you got debris
            
            possible_moves=Q{t,1};
            if retrace_check ~= true
                randp=randperm(length(possible_moves));
                possible_moves=possible_moves(randp);
            end
            
            for v=possible_moves % get the full trip to transfer its debris to it
                
                temp_r=0;
                iter_each_v=iter_each_v+1;
                total_iter=total_iter +1;
                
                [Cycles, cycle_len]=findCycles(Contractor{nc}, i, v);
                [~, ind]=sort(cycle_len,'ascend');%sorted cycles based on their length
                
                cycle_break=false;
                for c=ind %start exploring from the shortest cycle
                    candidate_cycle=Cycles{c,1};
                    debris_roads = find(Cycles{c,2}>0); %find the debris collected roads
                    
                    for road=debris_roads %for each road see if you can transfer it to the empty trip - t
                        from= candidate_cycle(road); to=candidate_cycle(road+1);
                        debris= Cycles{c,2}(road);
                        
                        
                        [Contractor, transfer_check, Cycles] = transferDebris(Contractor, nc, Cycles,c,from , to , debris, v,t,i,road);
                        temp_r=temp_r || transfer_check; %To see if any transfer is being done from any road in any cycle
                        
                        S= Contractor{nc}.trips{1,i}{t,4};
                        if S==0 % If you transfered enough to make the trip full change to the next trip
                            [ Contractor ] = cycleCancelling( Contractor,i,nc ,v ); % See if the transfer from v to t lead to some cycle deletions
                            if sum(Q_Empty==v)==0
                                Q_Empty=[Q_Empty, v];
                            end
                            Q{v,2}=[t,Q{v,2}];  % update your history of processed empty trips - t just got full
                            Q{t,2}=[Q{t,2}, v]; % t got debris from v so add v to the pred of t
                            cycle_break=true; break;
                        end
                    end
                    
                    if cycle_break==true; break; end
                    
                end %END CYCLE LOOP
                
                transfer_check_each_v(iter_each_v)=temp_r;
                if transfer_check_each_v(iter_each_v)==1 && S~=0 %If there is a transfer from v to t but there is still space left at t
                   % [ Contractor ] = cycleCancelling( Contractor,i,nc ,v ); % See if the transfer from v to t lead to some cycle deletions
                    if sum(Q_Empty==v)==0 %If v is not already in the empty trips to consider
                        Q_Empty=[Q_Empty, v]; %Add it to the list because you just transfered from v to t - it has space now
                    end
                    Q{v,2}=[t,Q{v,2}]; %v got empty due to t - put it in pred
                    Q{t,2}=[Q{t,2}, v]; % t got debris from v - put it in pred
                    if (iter_each_v==length(transfer_check_each_v)) %if you considered all the v's - candidate full trips, you are done with t
                        Q{t,1}=[]; Q{t,2}=[];

                    end
                end
                
                if retrace_check==true && (iter_each_v==length(transfer_check_each_v)) %After you consider all v - and you didn't do any modification 
                    %You have just did retrace (since it is true)
                    Q2_original=setdiff(Q2_original,t); %Since having t as the empty doesn't lead to any change I am not gonna consider t again
                    retrace_check=false;
                    cycle_break=true;
                end
                
                if cycle_break==true; break;
                elseif sum(transfer_check_each_v)==0; %Having that trip t as the empy doesn't lead to any change - non of the v's give debris to t
                    Q_Empty=[t,Q_Empty];
                    Q{t,1}=[Q{t,2},Q{t,1}];
                    Q{t,2}=[]; %since you carried all the predecessor to the possible moves column
                    retrace_check=true; % - retrace to the prev move you did and try another move(retrace your steps back)
                end %See the last processed trip - you made something leading to no good results now retrace your steps
                
            end %%%%END v LOOP
            if cycle_break==true; Q{t,1}=[]; Q{t,2}=[]; break; end
            
            
        end %%% AND T ROUTE
        
        if max_iter <= total_iter || isempty(Q_Empty)==1 ;
            check=false;end
    end
    
end
end

