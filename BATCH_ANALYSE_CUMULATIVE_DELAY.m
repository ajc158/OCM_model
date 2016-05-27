perfDataBig = [];
perfDataBigSD = [];


for delay = 0.2
    for type = 1:2
       runString = ['_JON_C_' int2str(type)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dataTemp/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig = [perfDataBig; [delay*1000 mean(' fileStr ')]];']);
            eval(['temp' int2str(type) ' = ' fileStr ';']);
            eval(['perfDataBigSD = [perfDataBigSD; [delay*1000 std(' fileStr ')./sqrt(goodOrNot)]];']);
       end
    end
end

[temp1b, bins1] = hist(sort(temp1));
temp1c = cumsum(temp1b);

[temp2b, bins2] = hist(sort(temp2));
temp2c = cumsum(temp2b);

fignum = figure('Units', 'pixels', 'Position', [100 20 600 400]);
hold off;



hPlot = plot(bins1, temp1c);
hold on;
hPlot2 = plot(bins2, temp2c);
% hErr = errorbar(perfDataBig(1:end,1),perfDataBig(1:end,2), perfDataBigSD(1:end,2));

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
  'XTick'       , (0:50:4500)./1000, ...
  'YTick'       , [0.2 0.3 0.4 0.5 0.6], ...
  'LineWidth'   , 2         );

set(hPlot, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'LineWidth' , 2         );
set(hPlot2, ...
    'Color'     , [0.4 0.4 0.4]    ,   ...
    'LineWidth' , 2         );
% 
%  axis([-500 500 0.15 0.47]);
 

 set(gcf, 'PaperPositionMode', 'auto');
 print -depsc2 ~/delay_plot_cumulative.eps