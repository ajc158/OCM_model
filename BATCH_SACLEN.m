function [] = BATCH_SACLEN(pars)

%%%%% SACCADE LENGTH CONTAINER SCRIPT, updated 2010 Alex Cope

%%% LOAD STANDARD PARAMETERS

DEFAULTS


%%% TRICKS

comp_input_from_fovea = false;
more_input_from_periphery = false;
more_phasic_in_periphery = false;
fixation_nogo_on = false;

fovea_striatum_compensation = false;
fovea_striatum_comp_v2 = true;
fix_passthough = false;

%%%

jon_model = false;

degrees_to_edge = 30;

hack_model = true;

%%%


%% Flags:
scopesOn = 0;
scopeOn = 0;  %% vis scopes
concerto = false;
logging_on = 20; % 0 = none, 1 = light, 2 = heavy, higher numbers are task specific

%% Scopes:
%scopeTarg = 'SC_buildup/out>out';
scopeTarg = 'FEF/out>out';
scopeTarg2 = 'BG/STN/out>out';
scopeTargA = 'SC_buildup/out>out';
scopeTargB = 'BG/SNr/out>out';

visModel = 'digit';
taskType = 'SACLEN';

%% exePars
executionStop = 4.0;
fS = 400;
num_samples = fS * executionStop;  

%% Bias:
%%%%%% set some interesting desire levels for features
if strcmp(visModel, 'digit')
    num_channels = 10;
else
    num_channels = 6;
end


D2_BIAS = 0.15;

DOPAMINE = 0.2;

%% Loop start:
for biasMode=1:1
    runString = ['_' taskType '_' int2str(biasMode) '_' int2str(pars.fbType) '_'  int2str(pars.numDist) '_' int2str(pars.targetLoc)];
    eval(['fileStr = ''perfdata' runString ''';']);
    eval([fileStr ' = {};']);
    
        if (exist(['./dataTemp/' fileStr '.mat']) == 0)
    
    for repeatRun = 1:40
  

        visSys ='gate3';

        % end never end sim but log all saccades
        targetMode = 2;
        targetVals = {};        
        targetVals{1} = [500 200 1];   
        targetVals{2} = [500 200 1];   
        
        %% Bias:
        %%%%%% set some interesting desire levels for features
        data = zeros(num_channels, num_samples);
        if biasMode == 1
            data(5,1:num_samples) = 0.2; % 6
        end
        if biasMode == 2
            data(8,1:num_samples) = 0.32; % o
            data(9,1:num_samples) = 0.32; % c
        end
        numDist = pars.numDist;
        runNum = pars.targetLoc;

        %%%%%%%%%%% RUN IT
        overrideName = ['sys_' runString];
        RUN_MODEL

        %% ANALYSE
        
        %timeTaken = out.orient.SG.target(end) - 0.2;
        
        resArr = [];
        
        for i = 1:size(out.orient.SG.target,2)
            if out.orient.SG.target(2,i) > 0
                resArr = [resArr, out.orient.SG.target(:,i) - [0; 0.2; 0; 0; 0; 0]];                 
            end
        end
        
        eval([fileStr ' = [' fileStr '; resArr];']);
        
        %% Loop end:
      

    end
    
    % save data
    eval(['save ./dataTemp/' fileStr ' ' fileStr ';']); 
    
        end
end
end
