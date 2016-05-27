%%%%%%%%%%%%% STIMULUS RING CREATION
%%%%%%%%%%%%% Alex Cope 2009

circleRadius = 30;%35
maxDist = 11.0;

tile=(imread(['./Images/blank2.png']));
targIm=(imread(['./Images/six.png']));
distIm1=(imread(['./Images/nine.png']));
distIm2=(imread(['./Images/five.png']));

%% LAYOUT
layOut = zeros(numDist,1);
firstDist = ceil(rand()*2);
if firstDist == 1
    secondDist = 2;
else
    secondDist = 1;
end

for i = 1:ceil(numDist/2)
    nextPlace = 0;
    while (nextPlace == 0)
        randPlace = ceil(rand()*numDist);
        if layOut(randPlace) == 0
            nextPlace = 1;
            layOut(randPlace) = firstDist;
        end
    end
end

for i = 1:numDist
    if layOut(i) == 0
        layOut(i) = secondDist;
    end
end
%%   

OffS = floor(size(targIm)./2);
deltaTheta = 2*pi / (maxDist + 1);

xshift = round(rand()*4)-2;
yshift = round(rand()*4)-2;

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
        eval(['tile(x-OffS(1):x+OffS(1), y-OffS(2):y+OffS(2), :) = distIm' int2str(layOut(i-1)) '(:,:,:);']);   
    end   
end

figure(66)
imagesc(tile);