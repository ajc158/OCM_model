perfDataBig = [];
perfDataBigExpl = [];
perfDataBigXY = {};
perfDataBigY = [];

count = 0;
for intensity = 0.2:0.025:0.6
count = count + 1;
perfDataBigXY{count} = [];
       runString = ['_DUAL_' int2str(intensity*40)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dual/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [intensity mean(' fileStr '(:,1))]];']);
            eval(['perfDataBigExpl = [perfDataBigExpl; [intensity (transpose(' fileStr '(:,1)))]];']);
            eval(['perfDataBigXY{count} = [perfDataBigXY{count}; [' fileStr '(:,2) ' fileStr '(:,3)]];']);
            eval(['perfDataBigY = [perfDataBigY; [intensity transpose(' fileStr '(:,3))]];']);
       end

end

plot(abs(reshape(perfDataBigY(10,2:end),10,1)),abs(reshape(perfDataBigExpl(10,2:end),10,1)),'o')

fignum = figure('Units', 'pixels', 'Position', [100 20 600 500]);
hold off;
% hPlot = plot(perfDataBig(1:end,1),perfDataBig(1:end,2));
hErr = errorbar(perfDataBig(1:end,1),perfDataBig(1:end,2), perfDataBigSD(1:end,2));

figure(fignum)

hXLabel = xlabel('Target distance (deg)'                     );
hYLabel = ylabel('Reaction time (s)'                      );

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
  'XTick'       , [0 10 20 30 40], ...
  'YTick'       , [0.2 0.3 0.4 0.9], ...
  'LineWidth'   , 2         );

set(hErr, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , 10           , ...
    'MarkerEdgeColor' , [0 0 0]  , ...
    'MarkerFaceColor' , [0 0 1]  , ...
    'LineWidth' , 2         );

axis([0 50 0.15 0.35]);
 

 set(gcf, 'PaperPositionMode', 'auto');
%  print -depsc2 ~/fdf.eps