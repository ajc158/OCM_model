gatedTMap2 = [];
ffInd = 0;
for ff = 0:1:8
    ffInd = ffInd + 1;
    fbInd = 0;
    for fb = 20:1:45
        fbInd = fbInd + 1;
        totTime = 0;
        try
            eval(['erSize = size(tunedata_gate3_' int2str(ff) '_' int2str(fb) '.times' int2str(ff) '_' int2str(fb) ',1);']);
        catch
            gatedWMap(ffInd, fbInd) = 0;
            continue;
        end
        for (i = 1: erSize)
            eval(['erTemp = tunedata_gate3_' int2str(ff) '_' int2str(fb) '.times' int2str(ff) '_' int2str(fb) '(i,1);']);
            totTime = totTime + (1.5 - erTemp);
        end
        gatedTMap2(ffInd, fbInd) = numCorrect;
    end
end

imagesc([2.0,4.5],[0,0.8],gatedTMap2); colormap(hot);colorbar;