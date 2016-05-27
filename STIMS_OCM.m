%%%%%%%%%%%%% STIMULUS RING CREATION
%%%%%%%%%%%%% Alex Cope 2009

circleRadius = 30;%35
maxDist = 11.0;

tile=(imread(['./Images/blank2.png']));
targIm=(imread(['./Images/six.png']));
distIm1=(imread(['./Images/six.png']));
distIm2=(imread(['./Images/six.png']));

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
for i = 1:(numDist+1)
    x = floor(circleRadius * sin(deltaTheta * (runNum-1) + deltaTheta * (i-1) * ...
        (maxDist+1)/(numDist+1)))+floor(size(tile,1)./2);
    y = floor(circleRadius * cos(deltaTheta * (runNum-1) + deltaTheta * (i-1) * ...
        (maxDist+1)/(numDist+1)))+floor(size(tile,2)./2);
    if i == 1
        tile(x-OffS(1):x+OffS(1), y-OffS(2):y+OffS(2), :) = targIm(:,:,:);
    else
        eval(['tile(x-OffS(1):x+OffS(1), y-OffS(2):y+OffS(2), :) = distIm' int2str(layOuts(runNum,i-1)) '(:,:,:);']);   
    end   
end

figure(66)
imagesc(tile);