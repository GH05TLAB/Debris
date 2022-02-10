no_contractor = size(Contractor,2);
no_nodes = size(Contractor{1}.TimeMatrix,1);
EdgeListmatrix=cell(no_nodes);
finalmatrix = [];
listu =[];
%For each edge located in EdgeList{to,from} we
n = 1;
for nc=1:no_contractor
    
     no_cluster=length(Contractor{nc}.cluster);
     
     for cl=1:no_cluster
        trip_no = size(Contractor{1,nc}.trips{1,cl},1);
        for tr = 1:trip_no
            trip = Contractor{1,nc}.trips{1,cl}{tr,1};
            len_trip=length(trip);
            
            for i=1:len_trip-1 %Iterate over all the edges
                from = trip(i);
                to = trip(i+1);
                EdgeListmatrix{from,to}= [EdgeListmatrix{from,to}; [from, to, nc]];
                %EdgeList = [EdgeList;[from, to]];    
                finalmatrix = [finalmatrix;EdgeListmatrix{from,to}];
            end           
        end
     end
end

finalmatrix = unique(finalmatrix,'rows');
edglist = finalmatrix(:,1:2);
[k,b] = size(finalmatrix)

%
%EdgeList = unique(EdgeList, 'rows');
for n = 1: size(EdgeList)
    for m = 1:size(finalmatrix)
        flipthis = flip(EdgeList(n,1:2));
        if(finalmatrix(m,1:2) == EdgeList(n,1:2))
            listu = [listu;finalmatrix(m,:)];
            break
        elseif(finalmatrix(m,1:2) == flipthis)
            listu = [listu;finalmatrix(m,:)];
            break
        end
    end
end

csvwrite('LISTHIS.csv', listu);

