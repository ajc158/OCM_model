perfDataVSBig = {};
saccData = [];
for i = 1:9
    perfDataVSBig{i} = [];
end

distArrays = [1];
count = 0;
for numDist = distArrays
    for targetLoc = 1:28
        count = count + 1;
        fileStr = ['perfdata_SACLEN_1_' int2str(1) '_'  int2str(numDist) '_' int2str(targetLoc)];
        eval(['load ./dataTemp/' fileStr ';']);
        eval(['goodOrNot = size(' fileStr ',1);']);
        if goodOrNot > 0
            eval(['maxFileStr = size(' fileStr ',1);']);
            for i = 1:maxFileStr
                eval(['temp = ' fileStr '{i};']); 
                if temp(1,end) == 1
                    perfDataVSBig{numDist} = [perfDataVSBig{numDist}; temp(2,end)];
                end
                for j = 2:size(temp,2)
                    sacLen = sqrt((temp(3,j)-temp(3,j-1))^2 + (temp(4,j)-temp(4,j-1))^2);
                    saccData = [saccData; sacLen];
                end
            end
        end
       
    end
end

averagesVS = [];
errVS = [];
j = 0;
for i = [1 3 7 9]
    j = j + 1;
%     averagesVS(j,1) = mean(perfDataVSBig{i});
%     averagesVS(j,2) = i; 
%     errVS(j) = std(perfDataVSBig{i})/sqrt(size(perfDataVSBig{i},1));
    averagesVS(j,1) = mean(perfDataVSBig{i});
    perfDataTemp =  perfDataVSBig{i}(perfDataVSBig{i} < 2*averagesVS(j,1));
    averagesVS(j,1) = mean(perfDataTemp);
    averagesVS(j,2) = i;  
    errVS(j) = std(perfDataTemp)./sqrt(size(perfDataTemp,1));
end

figure(68)
hold off;
errorbar(averagesVS(1:end,2),averagesVS(1:end,1),errVS)
hold on;

figure(67)
hold off;
hist(saccData,100);
