function [tile] = STIMS_gauss(OffY, OffX, sigma)

    %%%%%%%%%%%%% SINGLE STIMULUS CREATION
    %%%%%%%%%%%%% Alex Cope 2009

    tile=(imread(['./Images/blank2.png']));

    
    projState = [];
    [x,y] = meshgrid(-(size(tile,1)-1)/2:1:(size(tile,1)-1)/2);
    [theta, rho] = cart2pol(x,y);
    targIm = (exp(-(rho.^2.0)./(2*sigma^2)));

    OffS = floor(size(targIm)./2);

    x = floor(size(tile,1)./2) + OffX;
    y = floor(size(tile,2)./2) + OffY;

    if OffX > 0 || OffY > 0
        tile(OffX+1:end, OffY+1:end, 1) = targIm(1:end-OffX,1:end-OffY).*255.0;
        tile(OffX+1:end, OffY+1:end, 2) = targIm(1:end-OffX,1:end-OffY).*255.0;
        tile(OffX+1:end, OffY+1:end, 3) = targIm(1:end-OffX,1:end-OffY).*255.0;
    end
    if OffX < 0 || OffY < 0
        tile(1:end+OffX, 1:end+OffY, 1) = targIm(1-OffX:end,1-OffY:end).*255.0;
        tile(1:end+OffX, 1:end+OffY, 2) = targIm(1-OffX:end,1-OffY:end).*255.0;
        tile(1:end+OffX, 1:end+OffY, 3) = targIm(1-OffX:end,1-OffY:end).*255.0;
    end   

    figure(66)
    imagesc(tile);

end