%%%%%%%%%%%%% STIMULUS RING CREATION
%%%%%%%%%%%%% Alex Cope 2009

circleRadius = 30;%35
maxDist = 11.0;

tile=(imread(['./Images/blank2.png']));
targIm=(imread(['./Images/six.png']));
distIm1=(imread(['./Images/nine.png']));
distIm2=(imread(['./Images/five.png']));

layOuts = [ ...
          1 2 2 1   2 2 1 1   1 2 1 2 2 1;
          2 1 2 1   2 1 1 2   1 2 2 1 1 2; 
          1 2 1 2   2 1 2 1   2 1 1 2 2 1;
          2 2 1 1   1 2 2 1   2 2 1 1 2 1;
          1 1 2 2   1 2 1 2   2 1 2 1 1 2;
          2 1 1 2   1 1 2 2   1 1 2 2 2 1;
          1 2 2 1   2 1 2 1   1 2 2 1 2 1;
          2 1 1 2   1 1 2 2   1 2 1 2 1 2;
          2 1 2 1   2 2 1 1   2 2 1 1 2 1; 
          1 2 1 2   1 2 1 2   2 1 2 1 2 1; 
          2 2 1 1   1 2 2 1   2 1 1 2 1 2; 
          1 1 2 2   2 1 1 2   1 1 2 2 1 2];

OffS = floor(size(targIm)./2);
deltaTheta = 2*pi / (maxDist + 1);

xshift = 0;%round(rand()*4)-2;
yshift = 0;%round(rand()*4)-2;

for i = 1:(numDist+1)
    x = floor(circleRadius * sin(deltaTheta * (runNum-1) + deltaTheta * (i-1) * ...
        (maxDist+1)/(numDist+1)))+floor(size(tile,1)./2)+xshift;
    y = floor(circleRadius * cos(deltaTheta * (runNum-1) + deltaTheta * (i-1) * ...
        (maxDist+1)/(numDist+1)))+floor(size(tile,2)./2)+yshift;
    if targetMode == 2
        targetVals{i} = [y-150 x-150 10]; % y location of target, x location of target, acceptable distance from target
    end
    if i == 1
        tile(x-OffS(1):x+OffS(1), y-OffS(2):y+OffS(2), :) = targIm(:,:,:);
        if targetMode == 1
            targetVals{1} = [y-150 x-150 10]; % y location of target, x location of target, acceptable distance from target
        end
    else
        eval(['tile(x-OffS(1):x+OffS(1), y-OffS(2):y+OffS(2), :) = distIm' int2str(layOuts(runNum,i-1)) '(:,:,:);']);   
    end   
end

figure(66)
imagesc(tile);