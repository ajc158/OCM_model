
% ORIENTATION VENTRAL STREAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2008 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters

dopamine=0.2;
dims = ret_dims; %[layerSide layerSide];
locs = ret_locs; %{[layerSide layerSide]};
bgdims = [10];
bglocs = {[10]};
 
W_F = FEEDFORWARD_WEIGHT_GATING3;
W_B = FEEDBACK_WEIGHT_GATING3;
W_R = RECIPROCAL_WEIGHT_GATING3;
W_A = ATTENTIONAL_WEIGHT_GATING3;
W_I = FEATURE_INHIBITION_GATING3;

%% %%%%% Create System
vis = sml_system();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL
%% %%%%% set up standard state data for processes
actState = [];
% membrane decay time constant
actState.tau_membrane = 0.01;
% We want eqm. = input do p = 1
actState.p = 1;
% No noise on the membrane
actState.sigma_membrane = 0;%MEMB_NOISE;

outState = [];
% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
% hard limits at 0 and 1:
outState.limits = 2;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outFn = 'linear';

%actState.sigma_membrane = INPUT_NOISE;
vis = nw_modAddPop(vis, 'H_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
vis = nw_modAddPop(vis, 'V_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);

outState.m = 1;
% ... and offset
outState.c = 0.0;
actState.sigma_membrane = 0.05;
vis = nw_modAddPop(vis, 'LIP', fS, dims, {[layerLocs(1) layerLocs(2)]}, [p2a 'leaky'], actState,[p2o 'linear'], outState);

%% %%%%% Output to LIP

projState = [];
projState.delay = 0;
projState.norm = 'affx';
projState.minw = 1e-2;
projState.decimate = 0.0;
projState.sigma = 1.0;

vis = nw_modAddProj(vis, fS, 'H_V1m', 'LIP', 1, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'V_V1m', 'LIP', 1, [p2p 'gaussianIIR'], projState, 'add');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING
%% %%%%% Scopes
  

sys = sys.addsubsystem('vis', vis);