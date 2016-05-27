function [] = BATCH_CHAR(pars)

%%%%% VISUAL SEARCH CONTAINER SCRIPT


%%% LOAD STANDARD PARAMETERS
DEFAULTS

%% MODIFY WEIGHTS FOR TESTING

%%% TRICKS

less_input_from_fovea = false;
more_input_from_periphery = false;
more_phasic_in_periphery = false;
fixation_nogo_on = false;
fovea_striatum_compensation = true;
input_normalised = false;
nogo_on = false;

% cmf_type = 1;

%%%


BACKGROUND_NOISE = 0.0; % additive to everything
INPUT_NOISE = 0.02;
MEMB_NOISE = INPUT_NOISE;

% increasing the fef to thal seems to speed up the selection at no cost to
% accuracy.
THAL_2_FEF = 0.25;
FEF_2_THAL = 8.0;

LIP_TO_FEF = 2.0;
RETINA1_TO_SC_SUPERIOR = 0.0;

jon_model = false;

degrees_to_edge = 75;

% weights = good_vals_nd(1,:);
weights = zeros(11,1);

% weights = [2.5 0.0 10.0 0.0 1.8 1.2 2.2 weights(8) 10.0 weights(10)  weights(11)];

hack_model = true;
if hack_model == true;
    weights = [2.5 0.0 5.0 0.0 1.0 1.6 2.0 weights(8) 10.0 weights(10)  weights(11)];
end

SNR_TO_THAL = -weights(1);
SNR_TO_THAL_ADD = -weights(2);

SNR_TO_SC_BUILDUP = -weights(3);
SNR_TO_SC_BUILDUP_ADD = -weights(4);


STR_D1_TO_SNR = -weights(5);
STR_D2_TO_GPE = -weights(6);


STN_TO_SNR = weights(7); % NOTE: SCALED BY LAYER SIZE! SNR weight MUST = GPe weight
STN_TO_GPE = 1.0; % NOTE: SCALED BY LAYER SIZE!


FEF_TO_STN = weights(9);
THAL_TO_STN = weights(9);

% SC_BUILDUP_TO_THAL = weights(11);

if hack_model==true
    GPE_TO_STN = -1.4;
    GPE_TO_SNR = -0.4;%-weights(10);
end
%%%

%% Flags:
scopesOn = 0;
scopeOn = 0;  %% vis scopes
reach_scopes = false;
concerto = false;
logging_on = 20; % 0 = none, 1 = light, 2 = heavy, higher numbers are task specific

%% Scopes:
scopeTarg = 'FEF/out>out';
scopeTarg2 = 'BG/STN/out>out';
scopeTargA = 'SC_buildup/out>out';
scopeTargB = 'BG/SNr/out>out';

%%% VISUAL SYSTEM SELECTION
%%% shunt add gate or dk or ver 3 - gate3 ...
%visSys = 'add3';
visModel = 'none';
taskType = 'CHAR';

%% exePars
executionStop = 2.2;
fS = 400;
num_samples = fS * executionStop;  


num_channels = 10;

runString = ['_' taskType '_' int2str(pars.strength*10) '_' int2str(pars.diff*10)];

%% Loop start:
%for biasMode=1:2
    eval(['fileStr = ''perfdata' runString ''';']);
    eval([fileStr ' = [];']);
    for repeatRun = 1:20
       strTarg = pars.strength;
       diffTarg = pars.diff;

        targetMode = 1;
        runNum = 1;
        
        targetVals = {};
        targetVals{1} = [0 0 1000];
            
        %%%%%%%%%%% RUN IT
        overrideName = ['sys' runString];
        
        RUN_MODEL
        
        %% ANALYSE
        
        timeTaken = out.orient.SG.target(2,end) - 0.2;
        
        if timeTaken > 0;
            eval([fileStr ' = [' fileStr '; timeTaken];']);
        end
        
        
        %% Loop end:
      

    end
    % save data
    eval(['save ./dataChar/' fileStr ' ' fileStr ';']); 
%end
end
