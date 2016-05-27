function [out] = BATCH_DELAY(pars, parsNum)

%%%%% VISUAL SEARCH CONTAINER SCRIPT, updated 2010 Alex Cope

%%% LOAD STANDARD PARAMETERS

DEFAULTS


%% MODIFY WEIGHTS FOR TESTING

%%% TRICKS

comp_input_from_fovea = false;
more_input_from_periphery = false;
more_phasic_in_periphery = false;
fixation_nogo_on = false;
input_normalised = false;
less_input_from_fovea = false;
nogo_on = false;

fovea_striatum_compensation = false;
fovea_striatum_comp_v2 = true;
fix_passthough = false;

fovea_STN_compensation = false;


%%%

jon_model = false;

degrees_to_edge = 24;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hack_model = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

STIM_NOISE = 10;

% FIXATION_STRENGTH = 0.3;
STIM_STRENGTH = 0.7;

% SC_SUPERIOR_TO_THAL = 7.0;

BACKGROUND_NOISE = 0.2;
% BACKGROUND_NOISE = 1.0;

big_noise = false;
BIG_NOISE_WEIGHT = 0.03;

SC_SUPERIOR_TO_THAL = 3.0;
SC_SUPERIOR_TO_SC_BUILDUP = 20.0;

%%%


%% Flags:
scopesOn = 0;
scopeOn = 0;  %% vis scopes
concerto = false;
logging_on = 21; % 0 = none, 1 = light, 2 = heavy, higher numbers are task specific

%% Scopes:
%scopeTarg = 'SC_buildup/out>out';
scopeTarg = 'FEF/out>out';
scopeTarg2 = 'BG/STN/out>out';
scopeTargA = 'SC_buildup/out>out';
scopeTargB = 'BG/SNr/out>out';

visModel = 'digit';
taskType = 'JON';

%% exePars
executionStop = 4.2;
fS = 1000;
num_samples = fS * executionStop;  

%% Bias:
%%%%%% set some interesting desire levels for features
if strcmp(visModel, 'digit')
    num_channels = 10;
else
    num_channels = 6;
end

D2_BIAS = 0.0;

if pars.type < 2
    DOPAMINE = 0.2;
else
    DOPAMINE = 0.0;
end

%% Loop start:



for biasMode=1:1
    if pars.type == 0
        runString = ['_' taskType '_' int2str(pars.delay*20+14) '_' int2str(pars.dist)];
    else 
        runString = ['_' taskType '_C_' int2str(pars.type)];
    end
    eval(['fileStr = ''perfdata' runString ''';']);
    eval([fileStr ' = [];']);
    
    if (1==1)%exist(['./dataTemp/' fileStr '.mat']) == 0)
    
        if pars.type == 0
            maxi = 5;
        else
            maxi = 10;
        end
        
        for repeatRun = 1:maxi
            
            delay_amount = pars.delay;
           
            % end sim when we make a saccade, target set in STIMS.m
            targetMode = 2;
            targetVals = {};
            targetVals{1} = [pars.dist, 0, 5];
            targetVals{2} = [pars.dist, 0, 0.001];
            


            %%%%%%%%%%% RUN IT
            overrideName = ['sys_' runString];
            RUN_MODEL

            %% ANALYSE

            timeTaken = out.orient.SG.target(2,end) - 1.0;

            if timeTaken > 0 && out.orient.SG.target(1,end) == 1;
                eval([fileStr ' = [' fileStr '; timeTaken];']);
                
            end


            %% Loop end:


        end
        
      
    
    % save data
    eval(['save ./dataTemp/' fileStr ' ' fileStr ';']); 
    
    else
        exit2 = 'data exists'
    end
    
%     figure(20);
%     subplot(1,17,parsNum);
%     hold off
%     plot(squeeze(out.orient.FEF.out.out(30,39,:)));
%     hold on
%     plot(squeeze(out.orient.FEF.out.out(5,30,:)),'r');
%     plot(squeeze(out.orient.BG.SNr.out.out(30,39,:)),'g');

    
end
end
