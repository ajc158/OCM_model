perfDataBig = [];
perfDataBigSD = [];


for delay = 0
    for dist = [2.5 5.0 7.5 10 15 20 25 30 40]
       runString = ['_CMF_' int2str(delay*20+14) '_' int2str(dist*2)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dataTemp/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [dist mean(' fileStr ')]];']);
            eval(['perfDataBigSD = [perfDataBigSD; [dist std(' fileStr ')./sqrt(goodOrNot)]];']);
       end
    end
end

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
 print -depsc2 ~/cmf_plot_cross.eps