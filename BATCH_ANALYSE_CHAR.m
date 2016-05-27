perfDataChar = [];


for strength = 0.1:0.1:0.9
    for diff = strength:0.1:1.0
    
       runString = ['_CHAR_' int2str(strength*10) '_' int2str(diff*10)];
       eval(['fileStr = ''perfdata' runString ''';']);
       eval(['load ./dataChar/' fileStr ';']);
       eval(['goodOrNot = size(' fileStr ',1);']);
       if goodOrNot > 0
            eval(['perfDataChar(round(strength*10),round(diff*10)) = mean(' fileStr ');']);
       end
       
    end
end

figure(66)
hold off;

[X,Y] = meshgrid(1:9,1:10);
surf(X,Y,perfDataChar');

% plot(perfDataBig(1:end,1),perfDataBig(1:end,2))