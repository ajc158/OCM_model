function [tileR] = STIMS_CMF(OffX, OffY)

%%%%%%%%%%%%% SINGLE STIMULUS CREATION
%%%%%%%%%%%%% Alex Cope 2009


    tileR=(imread(['./Images/blank2.png']));
    targIm=(imread(['./Images/cross.png']));


    OffS = floor(size(targIm)./2);
    OffS2 = ceil(size(targIm)./2)-1;
    
    x = floor(size(tileR,1)./2) + OffY;% + targetVals[1];
    y = floor(size(tileR,2)./2) + OffX;% + targetVals[2];

    tileR(x-OffS(1):x+OffS2(1), y-OffS(2):y+OffS2(2), :) = targIm(:,:,:).*1.0;

    %figure(66)
    %imagesc(tileR);

end