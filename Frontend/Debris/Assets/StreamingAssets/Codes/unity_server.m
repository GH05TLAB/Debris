%unity connection - matlab server

clc
clear
tcpipServer = tcpip('0.0.0.0',55002,'NetworkRole','Server');
fprintf('matlab is listening for unity now...');
flag = false;
while(1)
clear rawwData
data = membrane(1);
fopen(tcpipServer);
rawData = fread(tcpipServer,24,'char');
for i=1:24 rawwData(i)= char(rawData(i));
    if strcmp(rawwData, 'matlab can read CSV now!')
        fprintf('\nstart reading csv now!');
        tic
        if flag == false 
            unity_start();
            flag = true;
        else
            unity_continue();
        end
        time = toc;
        time;
    elseif strcmp(rawwData, 'restart matlab read CSV!')
        fprintf('\nstart rereading csv now!');
        clc
        clearvars -except tcpipServer
        tic
        unity_start();
        flag = true;
        time = toc;
        time;
    end
end
fclose(tcpipServer);
end