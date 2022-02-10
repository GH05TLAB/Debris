function [ dist, pred ] = dijkstra( Time, depot, NODES )

Q=NODES;
no_nodes=max(NODES);
dist=Inf * ones(1,no_nodes); dist(depot)=0;
pred=zeros(1,no_nodes); pred(depot)=0;

while isempty(Q)~=1
    
    u=find(dist==min(dist(Q)));
%        try
%         i=find(Q==u);
%        catch
%           i=find(Q==u);
%        end
    
    i=find(Q==u);
    Q(i)=[];
    
    neigh= find(Time(u,:)>0);
    
    for v=neigh
        try
            if dist(u) + Time(u,v) < dist(v)
                dist(v)= dist(u) + Time(u,v);
                pred(v)=u;
            end
        catch
            if dist(u) + Time(u,v) < dist(v)
                dist(v)= dist(u) + Time(u,v);
                pred(v)=u;
            end
        end
    end
end


end

