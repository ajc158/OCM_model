%%%%% MODEL TESTING CONTAINER SCRIPT
tic
%%% LOAD STANDARD PARAMETERS
DEFAULTS

%% MODIFY WEIGHTS FOR TESTING

SNR_TO_SC_BUILDUP = -0.0;
SNR_TO_SC_BUILDUP_ADD = -0.9;

STN_TO_SNR = 2.8; % NOTE: SCALED BY LAYER SIZE! SNR weight MUST = GPe weight
STN_TO_GPE = 2.8; % NOTE: SCALED BY LAYER SIZE!
FEF_TO_STN = 2.0;
THAL_TO_STN = 5.0;
GPE_TO_STN = -3.0;

% FEF_2_THAL_RATIO = 0.30;
% LOOP_GAIN = 1.25;
THAL_2_FEF_mv = 1;
FEF_mv_2_THAL = 0;

FEF_2_THAL_RATIO_vis = 2.0;
LOOP_GAIN_vis = 2.0;

SC_BUILDUP_RECIP = 0.9;
SC_BUILDUP_RECIP_INH = -0.0;

MEMB_NOISE = 0.0;
%MEMB_NOISE = 0.0;

RETINA1_TO_FEF = 0.0; % DISABLED FOR NOW!
RETINA1_TO_SC_SUPERIOR = 0.1; % DISABLED FOR NOW!
SC_SUPERIOR_TO_SC_BUILDUP = 0.2;
FEF_TO_SC_BUILDUP = 1.0;

DOPAMINE = 0.2;

LIP_TO_FEF = 0.7;
STN_CTRL = 0.0; % lower is faster decision; higher is slower (0.0 for multiple ~0.17 for single)

FEF_mv_TO_SC_BUILDUP = 0.0;
FEF_TO_SC_BUILDUP = 1.5;

%%%%%

SNR_TO_THAL = -1.7;
SNR_TO_THAL_ADD = -0.2;

THAL_TO_STR_D1 = 1.0;
THAL_TO_STR_D2 = 1.0;

FEF_TO_STR_D1 = 1.0;
FEF_TO_STR_D2 = 1.0;

STR_D1_TO_SNR = -0.8;
STR_D2_TO_GPE = -0.8;

GPE_TO_SNR = -0.3;

STR_IN_SIGMA = 1.5;
proj_type = ''; % '' for normal cartesian, 'LP' for log/polar
STR_IN_TYPE = ['onetoone'];

%%%%%

SC_BUILDUP_TO_THAL = 0.2;

FEATURE_INHIBITION_GATING3 = -0.7;

FEEDFORWARD_WEIGHT_GATING3 = 1.0;
FEEDBACK_WEIGHT_GATING3 = 3.1;
RECIPROCAL_WEIGHT_GATING3 = 0.1;
ATTENTIONAL_WEIGHT_GATING3 = 0.08;

FIX_NOGO_BIAS = 0.6;
FIX_ZONE_D2_DRIVE = max(FIX_NOGO_BIAS * (0.17 + 1.2 * (1.5-0.80)),0); %0.56 when world lum is 0.4 and STR_W = 0.8 - this simulates a PFC command to not latch up fixation
FIX_ZONE_WIDTH = 30;
FIX_TO_OPN = 0.05;

%% PHASIC!
RETINA1_TO_FEF = 0;
RETINA1_TO_SC_SUPERIOR = 10; % DISABLED FOR NOW!
SC_SUPERIOR_TO_SC_BUILDUP = 0;

jon_model = false;

degrees_to_edge = 75;


%%%

%% Flags:
scopesOn = 0;
reach_scopes = false;
concerto = false;
logging_on = 0; % 0 = none, 1 = light, 2 = heavy
use_reach = false;
noise = false;

%% Scopes:
%scopeTarg = 'SC_buildup/out>out';
scopeTarg = 'FEF/out>out';
scopeTarg2 = 'SC_buildup/out>out';
scopeTargA = 'BG/SNr/out>out';
scopeTargB = 'BG/STN/out>out';

taskType = 'TEST';

%%% VISUAL SYSTEM SELECTION
%%% shunt add gate or dk or ver 3 - gate3 ...
visSys = 'gate3';
visModel = 'digit';

%% exePars
executionStop = 2.1;
fS = 400;
switch visSys
    case 'dk'
    fS = 800;
end
num_samples = fS * executionStop;  

%% Bias:
%%%%%% set some interesting desire levels for features
if strcmp(visModel, 'digit')
    num_channels = 10;
else
    num_channels = 6;
end
data = zeros(num_channels, num_samples);
data(7,fS*0.2:num_samples) = 0.32; % red/green
%data(8,fS*0.2:num_samples) = 0.4; % red
%data(9,fS*0.2:num_samples) = 0.4; % red
%data(5,1:num_samples) = 0.0; % green
overrideName = 'sys2';




% Autotune by working out gradients to target states and proceeding down
% them, subject to constraints.

% INITIAL STATE:


weights = [1.7 0.2 1.0 0.2 1.0    1.0 2.8 3.0 5.0 0.4 0.2];


% TARGETS:

targets = [1.0 0.0 0.13 0.0];

% CONSTRAINTS:


weight_min = [1.6 0.1 0.1 0.1 0.1  0.1 0.1 0.1 0.1 0.1 0.1];
weight_max = [5.0 1.5 5.0 1.0 2.0  2.0 10  6   10  1.3 1.0];
weight_step = [0.1 0.05 0.1 0.1 0.1 0.05 0.1 0.1 0.1 0.1].*3;


num_targ = 4;

good_vals = [];
good_vals_e = [];

prev_val = 1.2;
best_val = 100000;
runs = 0;
temperature = 44.12;
t_step = 0.6;
energy_values = [];
delta_e = 1;
delta_e_trace = [];


% INITIAL SIMULATED ANNEALING 

while runs < 100000
    
    runs = runs + 1;
        
    result = 0;
    
    dataStore = {};
    
    % FOR EACH DIRECTION:
    old_weights = weights;
    
    for direction = 1:size(weights,2)
        
        % CHOOSE A STEP (random number rounded to 0.1 increments between temp_adj_ranges that satisfies boundaries)

        max_step_up = weight_max(direction) - weights(direction);
        if 0.3 < max_step_up
               max_step_up = 0.3;
        end
        max_step_down = weight_min(direction) - weights(direction);
        if 0.3 < max_step_down
               max_step_down = 0.3;
        end
        
        step = 100000000;

        temp_adj_range = 3; % * temperature; % No temperature range adjustment yet...

        while ((step < max_step_down) || (step > max_step_up))
            step = (ceil(rand()*20 * temp_adj_range)/10)-temp_adj_range;
        end


        weights(direction) = weights(direction) + step;

    end

SNR_TO_THAL = -weights(1);
SNR_TO_THAL_ADD = -weights(2);

SNR_TO_SC_BUILDUP = -weights(3);
SNR_TO_SC_BUILDUP_ADD = -weights(4);


STR_D1_TO_SNR = -weights(5);
STR_D2_TO_GPE = -weights(6);


STN_TO_SNR = weights(7); % NOTE: SCALED BY LAYER SIZE! SNR weight MUST = GPe weight
STN_TO_GPE = weights(7); % NOTE: SCALED BY LAYER SIZE!
GPE_TO_STN = -weights(8);

FEF_TO_STN = weights(9);
THAL_TO_STN = weights(9);

GPE_TO_SNR = -weights(10);

SC_BUILDUP_TO_THAL = weights(11);

% FIXED
THAL_TO_STR_D1 = 1.0;
THAL_TO_STR_D2 = 1.0;

FEF_TO_STR_D1 = 1.0;
FEF_TO_STR_D2 = 1.0;


        for i = 1:1
            %% Run:
            %%%%%%%%%%% RUN IT
            RUN_MODEL

            %% Results:
%             if concerto
%                 for i = 1:4
%                     t(i) = rep(i).Performance.Timing.supervisor.irt(2);
%                 end
%                 results1 = [results1 max(t)];
%             else
%                 t(1) = rep(1).Performance.Timing.supervisor.irt(2);
%                 results1 = [results1 t(1)];
%             end
        %     for i = 1:size(out.orient.SG.inhib,2)
        %     if out.orient.SG.inhib(i) ==1
        %         i
        %         break;
        %     end
        % end
        end






 % Evaluate targets 

    result = result + abs(targets(1) - out.orient.FEF.out.out(21,25,800));
    result = result + abs(targets(2) - out.orient.FEF.out.out(24,4,800));
    result = result + abs(targets(3) - out.orient.BG.SNr.out.out(9,9,200));
    result = result + abs(targets(4) - std(out.orient.BG.SNr.out.out(16,16,100:390)))*10;

    result = result + size(find(out.orient.BG.SNr.out.out(24,4,:)==0),1) / 100;
    result = result + size(find(out.orient.BG.SNr.out.out(9,9,:)==0),1) / 50;
    % result = result + size(find(out.Pop4.out.out(10,21,:)==0),1) / 3000;
    

            
    % EVALUATE READY FOR CHANGES
    
    % expected energy = 2.2635
    
    change_val = prev_val;
    
    % Work out whether we move or not...
    if result < change_val
        change_val = result;
        energy_values = [energy_values result];
        temp = out;
    elseif exp((change_val - result) / temperature) > rand()
        change_val = result;
        energy_values = [energy_values result];  
        temp = out;
    else
        energy_values = [energy_values change_val];
        weights = old_weights;
        temp = prev_out;
    end
    
    delta_e = delta_e * 0.95 + abs(prev_val - change_val) * 0.05;
    delta_e_trace = [delta_e_trace delta_e];
        
    % Show current best:          
    % 
    figure(1)
    hold off;

    plot(squeeze(temp.orient.FEF.out.out(21,25,1*fS:2.2*fS)),'r');
    hold on;
    plot(squeeze(temp.orient.FEF.out.out(24,4,1*fS:2.2*fS)),'b');
    plot(squeeze(temp.orient.FEF.out.out(9,9,1*fS:2.2*fS)),'g');

    figure(2)
    hold off;

    plot(squeeze(temp.orient.BG.SNr.out.out(21,25,1*fS:2.2*fS)),'r');
    hold on;
    plot(squeeze(temp.orient.BG.SNr.out.out(24,4,1*fS:2.2*fS)),'b');
    plot(squeeze(temp.orient.BG.SNr.out.out(9,9,1*fS:2.2*fS)),'g');
    
    
    figure(3)
    hold off;
    plot(energy_values);
    hold on;
    plot(delta_e_trace, 'g');

    if delta_e < 0.03 
        % We are stuck! Reset! Drop temp!
        if change_val > 0.3 % we just suck! reset only!
            weights = best_weights;
        else
%             weights = best_weights;
%             if temperature > 0
%                 temperature = temperature - 0.1;
%             end
        end
    end
    
    if runs > 300
        runs = 1;
        weights = best_weights;
        if temperature > 0.01
            temperature = temperature * t_step;
        end
    end
        
    % Have we found a new best set of vals?
    if result < best_val
        best_val = result;  
        best_weights = weights
    end

    % Additionally, log all results with low energy, for later analysis
    if result < 0.5
        good_vals = [good_vals; weights];  
        good_vals_e = [good_vals_e; result];
    end

    if prev_val ~= change_val
        prev_out = out;
    end
    
    prev_val = change_val;
      
    if temperature < 0.01 
        weights = best_weights;
        
        break;
    end
    
end     







toc




% extract non-duplicates from good_vals list
good_vals_nd = [];
good_vals_nd_e = [];

for i = 1:size(good_vals,1)
    match = false;
    for j = i+1:size(good_vals,1)
        if abs(sum(good_vals(i,:)-good_vals(j,:)))<0.0000001 % get rid of rounding errors
            match = true;
        end
    end
    if match == false
        good_vals_nd = [good_vals_nd; good_vals(i,:)];
        good_vals_nd_e = [good_vals_nd_e; good_vals_e(i,:)];
    end
end



% figure(3)
% hold off;
% 
% plot(squeeze(out.orient.FEF_mv.out.out(23,25,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.FEF_mv.out.out(25,4,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.FEF_mv.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
% 
% figure(4)
% hold off;
% 
% plot(squeeze(out.orient.SC_buildup.out.out(23,25,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.SC_buildup.out.out(25,4,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.SC_buildup.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
% 
% figure(1)
% hold off;
% 
% plot(squeeze(out.orient.FEF.out.out(22,26,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.FEF.out.out(22,9,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.FEF.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
% 
% figure(2)
% hold off;
% 
% plot(squeeze(out.orient.BG.SNr.out.out(22,26,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.BG.SNr.out.out(22,9,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.BG.SNr.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
% 
% figure(3)
% hold off;
% 
% plot(squeeze(out.orient.FEF_mv.out.out(22,26,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.FEF_mv.out.out(22,9,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.FEF_mv.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
% 
% figure(4)
% hold off;
% 
% plot(squeeze(out.orient.SC_buildup.out.out(22,26,round((1000:1350)./1000.*fS))),'r');
% hold on;
% plot(squeeze(out.orient.SC_buildup.out.out(22,9,round((1000:1350)./1000.*fS))),'b');
% plot(squeeze(out.orient.SC_buildup.out.out(9,9,round((1000:1350)./1000.*fS))),'g');
