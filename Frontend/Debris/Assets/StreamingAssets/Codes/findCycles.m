function [ Cycles, cycle_len ] = findCycles( C,i,t )

nodes=C.cluster{i};
iter=1;
cycle_len=[];
Cycles = {};
for n=nodes
    occurence= (C.trips{1,i}{t,1}==n);
    indices=find(occurence==1);
        
        if isempty(indices)~=1
            P=combnk(indices,2);
            no_cycles=size(P,1);

            for c=1:no_cycles
                i1=P(c,1); i2=P(c,2);
                Cycles{iter,1}=C.trips{1,i}{t,1}(i1:i2); %The cycle itself with node numbers
                Cycles{iter,2}=C.trips{1,i}{t,2}(i1:i2-1); %Put the debris info about the cycle
                Cycles{iter,3}=[i1,i2]; %The indices of the cycle - to make the relation to its trip
                cycle_len(iter)=length(Cycles{iter});
                iter=iter+1;
            end
        end
end

end
 %First column of Cycles if the cycles found
 %Second column indicates the debris collected in that cycle
 %third column is the start and end index of the cycle inside the trip
