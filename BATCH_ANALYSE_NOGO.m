perfDataNotNogo = [];
perfDataBigNogo = [];

nogo = 0;

for targ = 1:12
   runString = ['_NO_GO_' int2str(nogo) '_' int2str(targ)];
   eval(['fileStr = ''perfdata' runString ''';']);
   eval(['load ./dataTemp/' fileStr ';']);
   eval(['goodOrNot = size(' fileStr ',1);']);
   if goodOrNot > 0
        eval(['perfDataNotNogo = [perfDataNotNogo; [targ mean(' fileStr ')]];']);
   end
   
end

nogo = 1;

for targ = 1:12
   runString = ['_NO_GO_' int2str(nogo) '_' int2str(targ)];
   eval(['fileStr = ''perfdata' runString ''';']);
   eval(['load ./dataTemp/' fileStr ';']);
   eval(['goodOrNot = size(' fileStr ',1);']);
   if goodOrNot > 0
        eval(['perfDataBigNogo = [perfDataBigNogo; [targ mean(' fileStr ')]];']);
   end
   
end

figure(66)
hold off;
hist(perfDataNotNogo(1:end,2));
nogoAv(1) = mean(perfDataNotNogo(:,2));
nogoAv(2) = mean(perfDataBigNogo(:,2));
