perfDataBig = [];
perfDataBigSD = [];


for delay = -0.4:0.05:0.4
    for dist = 25
       runString = ['_JON_' int2str(delay*20+14) '_' int2str(dist)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dataTemp/' fileStr ';']);
       eval([fileStr '=' fileStr '-2;']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [delay*1000 mean(' fileStr '(' fileStr '<0.6))]];']);
            eval(['perfDataBigSD = [perfDataBigSD; [delay*1000 std(' fileStr '(' fileStr '<0.6))./sqrt(goodOrNot)]];']);
       end
    end
end

fignum = figure('Units', 'pixels', 'Position', [100 20 600 400]);
hold off;
% hPlot = plot(perfDataBig(1:end,1),perfDataBig(1:end,2));
hErr = errorbar(perfDataBig(1:end,1),perfDataBig(1:end,2), perfDataBigSD(1:end,2));

big_array = [perfDataBig(1:end,1), perfDataBig(1:end,2), perfDataBigSD(1:end,2)];

csvwrite('~/Dropbox/OCM_data/delay_data', big_array);

figure(fignum)

hXLabel = xlabel('Target delay (ms)'                     );
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
  'XTick'       , [-400 -200 0 200 400], ...
  'YTick'       , [0.2 0.3 0.4 0.5 0.6], ...
  'LineWidth'   , 2         );

set(hErr, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , 10           , ...
    'MarkerEdgeColor' , [0 0 0]  , ...
    'MarkerFaceColor' , [0 0 1]  , ...
    'LineWidth' , 2         );

 axis([-500 500 0.0 0.47]);
 

 set(gcf, 'PaperPositionMode', 'auto');
 print -depsc2 ~/delay_plot2.eps
