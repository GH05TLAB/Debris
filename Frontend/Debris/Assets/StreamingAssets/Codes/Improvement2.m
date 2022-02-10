function [ Contractor ] = Improvement2( Contractor, i ,nc)

% Start from the full trip and fill it up from the other trips - this way
% you can empty some cycles from other trips and shoten the trips

nodes=Contractor{nc}.cluster{i}; %The nodes in that cluster
no_trips=size(Contractor{1,nc}.trips{1,i},1); 


%Three queues in total:
% Q1: The trips without full capacity
% Q2: Alternative paths that will transfer their debris to Q1 trips
% Q3: History queue - ordering the processed trips

Q_Empty=[];  Q_Pred=[];
Q2_original=1:no_trips;
for r=1:no_trips  % Create Q1 and Q2
    if Contractor{nc}.trips{1,i}{r,4} > 0; 
        Q{r,1}=r; 
        Q{r,2}=setdiff(Q2_original,Q{r,1});  %The rest goes to Q2  - just for 1 non-empty trip for the rest of Q1 ; its associated Q2 is calculated later    
    end;
end % Check the trips with not-full capacity / couldn't do a vector operation with the cell array thats why checked it one-by-one with a for loop 



check=true; transfer_check=true;
retrace_check=false;
max_iter=1000; total_iter=0;

while check

    for t=Q_Empty  % for the empty trip
        transfer_check_each_v=ones(1,length(Q_swap));
        iter_each_v=0;
        prev_v=Q_Empty; prev_v(1)=[];
        all_v=[];
   
        for v=Q_swap%(randi(length(Q2)))  % get the full trip to transfer its debris to it
            
            temp_r=0;
            iter_each_v=iter_each_v+1;
            total_iter=total_iter +1
            
            
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
                         %Q1=[v];
                         
                         Q_Empty=[prev_v, v]; 

                         Q_Pred=[t,Q_Pred];  % update your history of processed empty trips - t just got full
                         Q_swap= setdiff(Q2_original,union(Q_Pred(length(Q_Empty)),Q_Empty(1))); % don't process t again - going back to where you were doesn't help 
                         
                         if sum(prev_v==v)~=0 %If v already made the list cause it transfered to another trip but now also transfering it into t - you shouldn't consider twice
                             Q_swap=setdiff(Q_swap,t);
                             Q_Empty(end)=[];
                             Q_Pred(1)=[];
                             
                         end
                         
                         
                         
                         cycle_break=true; break;
                     end         
                 end
                 
                 if cycle_break==true; break; end

            end %END CYCLE LOOP
            
            transfer_check_each_v(iter_each_v)=temp_r;
            if transfer_check_each_v(iter_each_v)==1 && S~=0 ; all_v=[all_v,v]; prev_v=all_v; Q_Empty=[prev_v,v]; Q_Pred=[t,Q_Pred]; 
                if iter_each_v==length(transfer_check_each_v) % All the v's are traversed but still S is not full and new empty trips are in the picture
                    Q_swap=setdiff(Q2_original,union(Q_Pred(length(Q_Empty)),t));
                end
            end %Add the v (neighbouring trip that makes the transfer to t - since there might be multiple)
            
            
            if retrace_check==true %After you consider the previous trip (retrace your steps back) - start again from the prev trip
                Q_Empty=[v];
                Q_Pred=[t,Q_Pred];
                Q2_original=setdiff(Q2_original,t); %Permanently delete that trip so that it won't be considered again
                Q_swap= setdiff(Q2_original,union(Q_Pred(1),Q_Empty));
                retrace_check=false;
                cycle_break=true; break;
            end
                
            if cycle_break==true; break; 
            elseif sum(transfer_check_each_v)==0; %Having that trip t as the empy doesn't lead to any change 
                Q_swap=Q_Pred(1);  %go back to the previous trip               
                retrace_check=true;
            end %See the last processed trip - you made something leading to no good results now retrace your steps
                
        end %%%%END FOR LOOP
       if cycle_break==true; break; end
    end
    
    if max_iter==total_iter || isempty(Q_swap)==1 ; check=false;end
end


end

