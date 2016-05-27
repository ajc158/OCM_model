function [out] = BATCH_CMF(pars)

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

degrees_to_edge = 75;

hack_model = true;

STIM_NOISE = 10;

FIXATION_STRENGTH = 0.5;
STIM_STRENGTH = 0.3;%0.75
STIM_STRENGTH = pars.delay;


% SC_SUPERIOR_TO_THAL = 0.3;

BACKGROUND_NOISE = 0.3;

% 0 is crosses, 1 is distance scale gaussian blobs, 2 is Parkinson's
CMF_TYPE = pars.cmf_type;

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
taskType = 'CMF';

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

if CMF_TYPE < 2
    last = 1;
else
    last = 2;
end

for biasMode=1:last
    if CMF_TYPE < 2
        runString = ['_' taskType '_' int2str(pars.delay*20+14) '_' int2str(pars.dist*2)];
    else
        if biasMode==1
        DOPAMINE = 0.0;
        runString = ['_' taskType 'PD_PD_' int2str(pars.delay*20+14) '_' int2str(pars.dist*2)];
        else
        DOPAMINE = 0.2;
        runString = ['_' taskType 'PD_NORM_' int2str(pars.delay*20+14) '_' int2str(pars.dist*2)];
        end
    end
    eval(['fileStr = ''perfdata' runString ''';']);
    eval([fileStr ' = [];']);
    
    if (1==1)%exist(['./dataTemp/' fileStr '.mat']) == 0)
    
        for repeatRun = 1:40%40
            
            delay_amount = 0;% pars.delay;
           
            % end sim when we make a saccade, target set in STIMS.m
            targetMode = 2;
            targetVals = {};
            if (pars.dist < 5) 
                targetVals{1} = [-pars.dist, 0, 2.6];
            else
                targetVals{1} = [-pars.dist, 0, 4];
            end
            targetVals{2} = [-pars.dist, 0, 0.001];
            targetVals{3} = [0, 0, 3];
            


            %%%%%%%%%%% RUN IT
            overrideName = ['sys_' runString];
            RUN_MODEL

            %% ANALYSE

            timeTaken = out.orient.SG.target(2,end) - 1.0;

            if timeTaken > 0 && out.orient.SG.target(1,end) == 1;
                eval([fileStr ' = [' fileStr '; timeTaken];']);
                
            end

%            	[a,i] = max(squeeze(out.orient.FEF.out.out(:,:,100)));
%             figure(biasMode*2+repeatRun); hold off;
%             [c,j] = max(a);
%             plot(squeeze(out.orient.FEF.out.out(i(j),j,:)));
%             hold on;
%            	[a,i] = max(squeeze(out.orient.FEF.out.out(:,:,end-10)));
%             [c,j] = max(a);
%             plot(squeeze(out.orient.FEF.out.out(i(j),j,:)));
%             axis([0,1700,0,0.25]);
            %% Loop end:


        end
        
      
    
    % save data
    eval(['save ./pddata/' fileStr ' ' fileStr ';']); 
    
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
