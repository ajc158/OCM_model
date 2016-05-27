function [out] = BATCH_LUMINANCE(pars)

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

hack_model = true;

STIM_NOISE = 10;

FIXATION_STRENGTH = 1.0;
STIM_STRENGTH = pars.luminance;

BACKGROUND_NOISE = 0.3;

big_noise = false;
BIG_NOISE_WEIGHT = 0.035;

SC_SUPERIOR_TO_THAL = pars.weight;%2.0;
SC_SUPERIOR_TO_SC_BUILDUP = 20.0;

SIG_NOISE = 0;%30.0;

SIG_NOISE = pars.noise;%10;%20

long_delay = 1.5;

% 0 is crosses, 1 is distance scale gaussian blobs

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

DOPAMINE = 0.2;

%% Loop start:



for biasMode=1:1
     runString = 'moo';
    eval(['fileStr = ''perfdata' runString ''';']);
    eval([fileStr ' = [];']);

    
    if (1==1)%exist(['./dataTemp/' fileStr '.mat']) == 0)
    
        for repeatRun = 1:364%40
            repeatRun
         STIM_STRENGTH = pars.luminance;   
            delay_amount = pars.delay;
           
            % end sim when we make a saccade, target set in STIMS.m
            targetMode = 2;
            targetVals = {};
            targetVals{1} = [pars.dist, 0, 4];
            targetVals{2} = single([pars.dist, 0, 0.001]);
            


            %%%%%%%%%%% RUN IT
            overrideName = ['sys_' runString];
            RUN_MODEL
            
            
%             figure(3);
%             hold on;
%             plot(squeeze(out.orient.FEF.out.out(30,38,:)));
%             plot(squeeze(out.orient.FEF.out.out(1,38,:)));

            %% ANALYSE

            timeTaken = out.orient.SG.target(2,end) - long_delay;

            if timeTaken > 0 && out.orient.SG.target(1,end) == 1;
                eval([fileStr ' = [' fileStr '; timeTaken];']);
                timeTaken
            end


            %% Loop end:

            if mod(repeatRun,20)==0
                figure(2);
                hold off;
                eval(['hist(' fileStr ',0:0.01:1);']);
                axis([0.1 0.5 0 80]);
            end
          end
        
      
    
    % save data
%      eval(['save ./dataTemp/' fileStr ' ' fileStr ';']); 
    
    else
        exit2 = 'data exists'
    end
    
    eval(['out = ' fileStr ';']);
    
%     figure(20);
%     subplot(1,17,parsNum);
%     hold off
%     plot(squeeze(out.orient.FEF.out.out(30,39,:)));
%     hold on
%     plot(squeeze(out.orient.FEF.out.out(5,30,:)),'r');
%     plot(squeeze(out.orient.BG.SNr.out.out(30,39,:)),'g');

    
end
end
