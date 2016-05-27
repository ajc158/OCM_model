%*************************************************************************%
%                                                                         %
%                                EXTERN                                   %
%                                                                         %
%*************************************************************************%

%contains:
% world - simulated visual environment

extern = sml_system();

%% SOURCE		
%%%%%%%%%%%%%%%% Create visual input
%%%%%%%%%%%%%%%% Get visual input

switch taskType
    
    case 'TEST'
        numDist = 9;
       % runNum = 3;
        state = [];
        tile=(imread(['./Images/fix2.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 500*fS;
        %STIMS_NJ
       % tile=(imread(['./Images/lines2.png']));
        %if jon_model == true
            tile=(imread(['./Images/fix2.png']));
            tileMiddle = (imread(['./Images/jon' num2str(runNum) '.png']));
            if contrast == 1
                tile(61:240,61:240,:) = (tileMiddle).*1.0;
            end
            if contrast == 2
                tile(61:240,61:240,:) = tileMiddle.*1.5; 
            end
            if contrast == 3
                tile(61:240,61:240,:) = tileMiddle .*1.9; 
            end
            tile = tile * 0.3;
        %end
        state.worldImageArray{2} = tile;
        state.worldTime(2) = onsetV*fS;
        
    case 'FLAG'
        state = [];
        tile=(imread(['./Images/blank2.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 500*fS;
        STIMS_FLAG
       % tile=(imread(['./Images/lines2.png']));
        if jon_model == true
            tile=(imread(['./Images/jon.png']));
        end
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 0.2*fS;
    
    case 'TEST_OCM'
        numDist = 9;
        runNum = 1;
        state = [];
        tile=(imread(['./Images/fix2.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 5*fS;
        STIMS_OCM
       % tile=(imread(['./Images/lines2.png']));
        if jon_model == true
            tile=(imread(['./Images/jon.png']));
        end
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 1*fS;

    case 'VS'
        if visSys == 'test_input'
            %%% VISUAL SEARCH
            state = [];
            tile=(imread(['./Images/fix2.png']));
            state.worldImageArray{1} = tile;
            state.worldTime(1) = 1;      
            STIMS_TEST_INPUT
            if field_vs == true
                STIMS_TEST_INPUT_FIELD
            else
                STIMS_TEST_INPUT
            end
            state.worldImageArray{2} = tile;
            state.worldTime(2) = 0.2*fS;
        else
            %%% VISUAL SEARCH
            state = [];
            tile=(imread(['./Images/fix2.png']));
            state.worldImageArray{1} = tile;
            state.worldTime(1) = 1;
            %tile=(imread(['./Images/vs' int2str(numDist) '_' int2str(runNum) '.png']));        

            if field_vs == true
                STIMS_RAND
            else
                STIMS
            end
            state.worldImageArray{2} = tile;
            state.worldTime(2) = 0.2*fS;
        end

    case 'SACLEN'
        %%% CLUTTER SEARCH
        state = [];
        tile=(imread(['./Images/blank.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        STIMS_SACLEN
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 50;
        
        
    case 'JON'
        if exist('long_delay','var')
            numDist = 1;
            runNum = 1;
            state = [];
    %         tile=STIMS_CMF(0,0);
            tile=(imread(['./Images/fix2_cross.png']));
            state.worldImageArray{1} = tile.*STIM_STRENGTH.*FIXATION_STRENGTH;
            state.worldTime(1) = 1;
            state.worldImageArray{4} = tile.*STIM_STRENGTH;
            state.worldTime(4) = 5*fS;
            if (delay_amount < 0)
                tile=(imread(['./Images/fix2_cross.png']));    
                tile2 = STIMS_CMF(targetVals{1}(1), targetVals{1}(2)); 
                tile2 = tile2+tile;
            else
                tile=(imread(['./Images/fix2_cross.png']));    
                tile2 = tile .* 0; 
            end
            tile3 = STIMS_CMF(targetVals{1}(1), targetVals{1}(2));

            if (delay_amount < 0)        
                state.worldImageArray{2} = tile2.*STIM_STRENGTH;
                state.worldTime(2) = (long_delay)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (long_delay-delay_amount)*fS;   
            elseif (delay_amount > 0)
                state.worldImageArray{2} = tile2.*STIM_STRENGTH;
                state.worldTime(2) = (long_delay-delay_amount)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (long_delay)*fS;               
            else 
                state.worldImageArray{2} = tile3.*STIM_STRENGTH;
                state.worldTime(2) = (long_delay-delay_amount)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (long_delay)*fS;            
            end
        else
            numDist = 1;
            runNum = 1;
            state = [];
    %         tile=STIMS_CMF(0,0);
            tile=(imread(['./Images/fix2_cross.png']));
            state.worldImageArray{1} = tile.*STIM_STRENGTH;
            state.worldTime(1) = 1;
            state.worldImageArray{4} = tile.*STIM_STRENGTH;
            state.worldTime(4) = 5*fS;
            if (delay_amount < 0)
                tile=(imread(['./Images/fix2_cross.png']));    
                tile2 = STIMS_CMF(targetVals{1}(1), targetVals{1}(2)); 
                tile2 = tile2+tile;
            else
                tile=(imread(['./Images/fix2_cross.png']));    
                tile2 = tile .* 0; 
            end
            tile3 = STIMS_CMF(targetVals{1}(1), targetVals{1}(2));

            if (delay_amount < 0)        
                state.worldImageArray{2} = tile2.*STIM_STRENGTH;
                state.worldTime(2) = (3.0)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (3.0-delay_amount)*fS;   
            elseif (delay_amount > 0)
                state.worldImageArray{2} = tile2.*STIM_STRENGTH;
                state.worldTime(2) = (3.0-delay_amount)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (3.0)*fS;               
            else 
                state.worldImageArray{2} = tile3.*STIM_STRENGTH;
                state.worldTime(2) = (3.0-delay_amount)*fS;
                state.worldImageArray{3} = tile3.*STIM_STRENGTH;
                state.worldTime(3) = (3.0)*fS;            
            end
        end
        
    case 'CMF'
        numDist = 1;
        runNum = 1;
        state = [];
%         tile=STIMS_CMF(0,0);
        tile=(imread(['./Images/fix2_cross.png'])).*FIXATION_STRENGTH;
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{4} = tile;
        state.worldTime(4) = 5*fS;
        if CMF_TYPE == 0 || CMF_TYPE == 2
            tile2 = STIMS_CMF(targetVals{1}(1), targetVals{1}(2)); 
            state.worldImageArray{2} = tile2.*STIM_STRENGTH;
            state.worldTime(2) = (1.0)*fS;
        else 
            distance = max(abs([targetVals{1}(1), targetVals{1}(2)]));
            sigma = distance * 20/180*pi;
            tile2 = STIMS_gauss(targetVals{1}(1), targetVals{1}(2), sigma); 
            state.worldImageArray{2} = tile2.*STIM_STRENGTH;
            state.worldTime(2) = (1.0)*fS;
        end
       
    case 'DUAL'
        numDist = 1;
        runNum = 1;
        state = [];
%         tile=STIMS_CMF(0,0);
        tile=(imread(['./Images/fix2_cross.png'])).*FIXATION_STRENGTH;
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{4} = tile;
        state.worldTime(4) = 5*fS;
            tile2 = STIMS_DUAL(-pars.dist, pars.y_val,STIM_STRENGTH,STIM_STRENGTH2); 
            state.worldImageArray{2} = tile2;
            state.worldTime(2) = (1.0)*fS;
 
    case 'CMF_VIS'
        numDist = 1;
        runNum = 1;
        state = [];
%         tile=STIMS_CMF(0,0);
        tile=(imread(['./Images/fix2_cross.png'])).*0.6;
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 5*fS;
        if cmf_type == 0
            tile = STIMS_CMF(targetVals(1), targetVals(2)); 
        else 
            distance = max(abs([targetVals(1), targetVals(2)]));
            sigma = distance * 20/180*pi;
            tile = STIMS_gauss(targetVals(1), targetVals(2), sigma); 
        end
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 0.2*fS;
        
    case 'NO_GO'
        numDist = 11;
        state = [];
        tile=(imread(['./Images/fix2_cross.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 5*fS;
        STIMS_OCM
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 0.2*fS;
        
    case 'CHAR'
        numDist = 9;
        state = [];
        tile=(imread(['./Images/blank2.png']));
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{3} = tile;
        state.worldTime(3) = 20*fS;
        STIMS_OCM_CHAR
        state.worldImageArray{2} = tile;
        state.worldTime(2) = 0.2*fS;  
        
    case 'ONSET'
        state = [];
        if biasMode == 1
            STIMS_ONSET2
        else
            STIMS_ONSET3
        end
        
        state.worldImageArray{1} = tile;
        state.worldTime(1) = 1;
        state.worldImageArray{2} = tile2;
        state.worldTime(2) = 1.0*fS;
end



%%%%%%%%%%%%%
% ADD PROCESS
state.retinaSize = In_dims;
extern = extern.addprocess('world', 'dev/abrg/2009/emWorld', fS, state);


%*************************************************************************%
%                              END EXTERN                                 %
%*************************************************************************%

sys = sys.addsubsystem('extern', extern);