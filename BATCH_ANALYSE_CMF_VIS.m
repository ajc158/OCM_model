perfDataBig = [];


for dist = 0.5:2:45.5
   runString = ['_CMF_VIS_' int2str(dist)];
   eval(['fileStr = ''perfdata' runString ''';']);
   eval(['load ./dataTemp/' fileStr ';']);
   eval(['goodOrNot = size(' fileStr ',1);']);
   if goodOrNot > 0
        eval(['perfDataBig = [perfDataBig; [dist mean(' fileStr ')]];']);
   end
   
end

figure(66)
hold off;
plot(perfDataBig(1:end,1),perfDataBig(1:end,2))