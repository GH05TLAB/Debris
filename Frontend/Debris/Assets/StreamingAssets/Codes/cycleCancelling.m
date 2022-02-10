function [ Contractor ] = cycleCancelling( Contractor,i,nc ,trips )

%Find the cycles inside the trips that don't collect any debris and clear
%them - or if there is a cycle which a little debris is collected destroy
%that and see if it be more beneficial to put it inside other trips


nodes=Contractor{nc}.cluster{i}; %The nodes in that cluster
%no_trips=size(Contractor{1,nc}.trips{1,i},1); 

%For each trip see the repeating nodes - detection of cycles
for t=trips
    check=true; u=nodes(1); iter=1;
    
    while check

        occurence= (Contractor{1,nc}.trips{1,i}{t,1}==u);
        indices=find(occurence==1);
        %There can be different cycles to delete bw occurences 
        
        if isempty(indices)~=1
            P=combnk(indices,2);
            no_cycles=size(P,1);

            for c=1:no_cycles

                i1=P(c,1); i2=P(c,2);

                collected_debris=sum(Contractor{1,nc}.trips{1,i}{t,2}(i1:i2-1));
                if collected_debris==0 %delete that cycle
                   Contractor{1,nc}.trips{1,i}{t,1}=[Contractor{1,nc}.trips{1,i}{t,1}(1:i1),Contractor{1,nc}.trips{1,i}{t,1}(i2+1:end)];
                   Contractor{1,nc}.trips{1,i}{t,2}=[Contractor{1,nc}.trips{1,i}{t,2}(1:i1-1),Contractor{1,nc}.trips{1,i}{t,2}(i2:end)];
                   iter=iter-1;
                   if length(Contractor{1,nc}.trips{1,i}{t,1}) == 1  %if trip is left as ` node just fix it - delete that node + trip
                       Contractor{1,nc}.trips{1,i}{t,1} =[];
                       Contractor{1,nc}.trips{1,i}{t,2} =0;
                       Contractor{1,nc}.trips{1,i}{t,3} =[];
                       Contractor{1,nc}.trips{1,i}{t,4} =200;
                   end
                   break;
                end

            end
        end

           
        if u==nodes(end) 
            check=false;
        else
            iter=iter+1;
            u=nodes(iter); 
        end   
    end
    
    
end




end

