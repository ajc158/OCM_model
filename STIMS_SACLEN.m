%%%%%%%%%%%%% SACCADE TARGET ARRAY FIELD CREATION
%%%%%%%%%%%%% Alex Cope 2009

tile=(imread(['./Images/blank2.png']));
targIm=(imread(['./Images/six.png']));

OffS = floor(size(targIm)./2);

%% LAYOUT

arrayStim = [0 0];

for i = 1:100
   
    assigned = false;
    while assigned == false
        
        testX = ceil(rand*290+5);
        testY = ceil(rand*290+5);

        if sum(sum((testX - arrayStim(:,1)).^2 + (testY - arrayStim(:,2)).^2 < 300)) == 0
               arrayStim = [arrayStim; [testX testY]];
               tile(testX-OffS(1):testX+OffS(1), testY-OffS(2):testY+OffS(2), :) = targIm(:,:,:);
               assigned = true;
        end
    
    end
    
    
end


figure(66)
imagesc(tile);