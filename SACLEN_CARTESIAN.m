

saccDists = [];

for arrayNum = 1:100
%% LAYOUT
    
    arrayStim = [0 0];

    for i = 1:100

        assigned = false;
        while assigned == false

            testX = ceil(rand*290+5);
            testY = ceil(rand*290+5);

            if sum(sum((testX - arrayStim(:,1)).^2 + (testY - arrayStim(:,2)).^2 < 300)) == 0
                   arrayStim = [arrayStim; [testX testY]];
%                    tile(testX-OffS(1):testX+OffS(1), testY-OffS(2):testY+OffS(2), :) = targIm(:,:,:);
                   assigned = true;
            end

        end


    end

    currLoc = [0 0];

    %% CHOOSE A TARGET

    for i = 1:500

        inRange = false;
        while inRange == false
            targNum = ceil(rand*100+1);
            if (abs(max(currLoc - arrayStim(targNum))) < 75) && (abs(max(currLoc - arrayStim(targNum))) > 0)
                
                saccDists = [saccDists (sum((currLoc-arrayStim(targNum)).^2)).^0.5];
                inRange = true;
            end
        end

    end
    
end

figure(69)
hold off;
hist(saccDists,20);
        