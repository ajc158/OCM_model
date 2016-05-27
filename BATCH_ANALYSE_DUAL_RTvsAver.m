perfDataBig = [];
perfDataBigExpl = [];
perfDataBigXY = {};
perfDataBigY = [];

degree_of_averaging = [];

%%%%%%%%%%%%%%%%%%% 30 degrees - targets at (25,7) and (25,-7) pixels

count = 0;
for intensity = 0.3
count = count + 1;
perfDataBigXY{count} = [];
       runString = ['_DUAL30_' int2str(intensity*40)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dualRTvsAv/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [intensity mean(' fileStr '(:,1))]];']);
            eval(['perfDataBigExpl = [perfDataBigExpl; [intensity (transpose(' fileStr '(:,1)))]];']);
            eval(['perfDataBigXY{count} = [perfDataBigXY{count}; [' fileStr '(:,2) ' fileStr '(:,3)]];']);
            eval(['perfDataBigY = [perfDataBigY; [intensity transpose(' fileStr '(:,3))]];']);
       end

end

degree_of_averaging = [degree_of_averaging; [30 0]];
% use that degree of averaging = (targ_dist - av_y_distance)/targ_dist
%degree_of_averaging(end,2) = sum(perfDataBigXY(abs(perfDataBigXY(:,2))<7-1.1117),2);%(7 - mean(abs(perfDataBigY(1,2:end))))/7;
csvwrite('~/Dropbox/av30',perfDataBigXY);

perfDataBig = [];
perfDataBigExpl = [];
perfDataBigXY = {};
perfDataBigY = [];

%%%%%%%%%%%%%%%%%%% 60 degrees - targets at (22,13) and (22,-13) pixels

count = 0;
for intensity = 0.3
count = count + 1;
perfDataBigXY{count} = [];
       runString = ['_DUAL60_' int2str(intensity*40)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dualRTvsAv/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [intensity mean(' fileStr '(:,1))]];']);
            eval(['perfDataBigExpl = [perfDataBigExpl; [intensity (transpose(' fileStr '(:,1)))]];']);
            eval(['perfDataBigXY{count} = [perfDataBigXY{count}; [' fileStr '(:,2) ' fileStr '(:,3)]];']);
            eval(['perfDataBigY = [perfDataBigY; [intensity transpose(' fileStr '(:,3))]];']);
       end

end

degree_of_averaging = [degree_of_averaging; [60 0]];
% use that degree of averaging = (targ_dist - av_y_distance)/targ_dist
%degree_of_averaging(end,2) = (13 - mean(abs(perfDataBigY(1,2:end))))/13;
%degree_of_averaging(end,2) = sum(perfDataBigXY(abs(perfDataBigXY(:,2))<13-1.1117),2);%(7 - mean(abs(perfDataBigY(1,2:end))))/7;
csvwrite('~/Dropbox/av60',perfDataBigXY);


%%%%%%%%%%%%%%%%%%% 90 degrees - targets at (18,18) and (18,-18) pixels
perfDataBig = [];
perfDataBigExpl = [];
perfDataBigXY = {};
perfDataBigY = [];

count = 0;
for intensity = 0.3
count = count + 1;
perfDataBigXY{count} = [];
       runString = ['_DUAL90_' int2str(intensity*40)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dualRTvsAv/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [intensity mean(' fileStr '(:,1))]];']);
            eval(['perfDataBigExpl = [perfDataBigExpl; [intensity (transpose(' fileStr '(:,1)))]];']);
            eval(['perfDataBigXY{count} = [perfDataBigXY{count}; [' fileStr '(:,2) ' fileStr '(:,3)]];']);
            eval(['perfDataBigY = [perfDataBigY; [intensity transpose(' fileStr '(:,3))]];']);
       end

end

degree_of_averaging = [degree_of_averaging; [90 0]];
% use that degree of averaging = (targ_dist - av_y_distance)/targ_dist
%degree_of_averaging(end,2) = (18 - mean(abs(perfDataBigY(1,2:end))))/18;
%degree_of_averaging(end,2) = sum(perfDataBigXY(abs(perfDataBigXY(:,2))<18-1.1117),2);%(7 - mean(abs(perfDataBigY(1,2:end))))/7;
csvwrite('~/Dropbox/av90',perfDataBigXY);

figure(1)
% plot(abs(reshape(perfDataBigY(1,2:end),30,1)),abs(reshape(perfDataBigExpl(1,2:end),30,1)),'o');

fignum = figure('Units', 'pixels', 'Position', [100 20 600 500]);
hPlot = plot(degree_of_averaging(:,1),degree_of_averaging(:,2));

cvswrite('~/Dropbox/av',degree_of_averaging);
 
figure(fignum)

hXLabel = xlabel('Target seperation (deg)'                     );
hYLabel = ylabel('Amount of averaging '                      );

set(gca                      , ...
    'FontName'   , 'Helvetica' );
set([hXLabel, hYLabel], ...
    'FontName'   , 'Helvetica');
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 30        );





set(gca, ...
  'FontSize'    , 36        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [30 60 90], ...
  'YTick'       , [0.1 0.3 0.5 1.0], ...
  'LineWidth'   , 2         );

set(hPlot, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , 10           , ...
    'MarkerEdgeColor' , [0 0 0]  , ...
    'MarkerFaceColor' , [0 0 1]  , ...
    'LineWidth' , 2         );

axis([20 100 0.05 0.6]);
 

 set(gcf, 'PaperPositionMode', 'auto');
 print -depsc2 ~/dual_stim_seperation.eps
