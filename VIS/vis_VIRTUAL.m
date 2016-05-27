
% ORIENTATION VENTRAL STREAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2008 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters


dims = ret_dims; %[layerSide layerSide];
locs = ret_locs; %{[layerSide layerSide]};


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
actState.sigma_membrane =  MEMB_NOISE;

outState = [];
% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
% hard limits at 0 and 1:
outState.limits = 2;

outFn = 'tanh';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outState.c = 0.05;
% actState.sigma_membrane = BACKGROUND_NOISE;
vis = nw_modAddPop(vis, 'H_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
vis = nw_modAddPop(vis, 'V_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
outState.c = 0.0;


% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
actState.sigma_membrane = 0.13;
vis = nw_modAddPop(vis, 'LIP', fS, dims, {[layerLocs(1) layerLocs(2)]}, [p2a 'leaky'], actState,[p2o 'linear'], outState);

%% %%%%%%%%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")

sArray = zeros(dims(1), dims(2), 15);




for i = 1:numDist
    sArray(92:111, round(150/numDist*i)-10:round(150/numDist*i)-2, 2:end) = 0.07 + 0.02*(biasMode - 1);
end
i = mod(runNum,numDist)+1;
sArray(92:111, round(150/numDist*i)-10:round(150/numDist*i)-2, 2:end) = 0.1;

state = [];
state.data = sArray;
state.repeat = true;
state.ndims = 2;
vis = vis.addprocess('scene', 'std/2009/source/numeric', 5, state);

vis = vis.addprocess('resamp', 'std/2009/resample/numeric', fS, {});

vis = vis.link('scene>out', 'resamp<in1', 0);
vis = vis.link('resamp>in1', 'LIP/act<<add<in', 0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING
%% %%%%% Scopes

sys = sys.addsubsystem('vis', vis);