perfDataBig = {};
perfDataBigSD = {};
for delay = 0.5:0.1:0.9
    perfDataBig{delay*10-4} = [];
    perfDataBigSD{delay*10-4} = [];
    
end

for delay = 0.5:0.1:0.9
    for dist = [3 5.0 7.5 10 15 20 25 30 40]
       runString = ['_CMF_' int2str(delay*20+14) '_' int2str(dist*2)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./pddata/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataBig{delay*10-4} = [perfDataBig{delay*10-4}; [dist mean(' fileStr ')]];']);
            eval(['perfDataBigSD{delay*10-4} = [perfDataBigSD{delay*10-4}; [dist std(' fileStr ')./sqrt(goodOrNot)]];']);
       end
    end
end

fignum = figure('Units', 'pixels', 'Position', [100 20 600 500]);
hold off;
% hPlot = plot(perfDataBig(1:end,1),perfDataBig(1:end,2));

for delay = 0.5:0.1:0.9
hErr = errorbar(perfDataBig{delay*10-4}(1:end,1),perfDataBig{delay*10-4}(1:end,2), perfDataBigSD{delay*10-4}(1:end,2));

big_out = [perfDataBig{delay*10-4}(1:end,1),perfDataBig{delay*10-4}(1:end,2), perfDataBigSD{delay*10-4}(1:end,2) ];

csvwrite(['~/Dropbox/OCM_data/cmf_lum_' num2str(delay*10)], big_out);

hold on;

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
    'MarkerFaceColor' , [delay-0.5 1-delay delay]  , ...
    'LineWidth' , 2         );


str = [num2str(delay)];

if delay == 0.9
    text(47,perfDataBig{delay*10-4}(end,2)-0.013, str, 'FontSize', 26);
elseif delay == 0.8
    text(47,perfDataBig{delay*10-4}(end,2)-0.003, str, 'FontSize', 26);
else    
    text(47,perfDataBig{delay*10-4}(end,2)+0.001, str, 'FontSize', 26);
end
end

text(42,perfDataBig{0.5*10-4}(end,2)+0.02, 'Luminance', 'FontSize', 26);


axis([0 50 0.15 0.5]);
 

 set(gcf, 'PaperPositionMode', 'auto');
 print -depsc2 ~/cmf_plot_cross_lum.eps