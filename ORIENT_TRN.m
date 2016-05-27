%*************************************************************************%
%                                                                         % 
%                                ORIENT                                   %
%                                                                         %
%*************************************************************************%

% CONTAINS:
% Retina
% Superior Colliculus (SC)
% FEF Basal Ganglia loop (BG subsystem)
% Saccadic Generator (SG)
% Frontal Eye Fields (FEF)

% On the sizes of locs:
% locs will either be of dimensions 1x1 - with the sigma projections
% required specified by number of neurons x scaling factor, or locs = dims
% and sigma represents number of neurons.

% Notes on the configuration parameters... 
% and some working settings:
STN_IN = 0.55; %0.63 (PUSH) This relates to the rate at which the damping of the Basal Ganglia 
% on the gain in FEF increases with the overall activation of FEF, thus changing the
% total activation permitted in FEF - affects STN input. 
GPE2STN = 1.0; % 0.8 Lower values mean slower integration, but better selection
STN2GPE = 1.0;
PUSH_PULL_RATIO = 0.37; % This is the ratio between 'push' (as above) and 'pull' -
% the strength of the winning stimulus to resist damping. Too much pull
% will result in excessive suppression of SNr. Affects D1 -> SNr and D2 ->
% GPe connections.
CAP_LEVEL = 1.0;%2.3; % Affects the rate of stimulus integration and, SNr -> Thalamus

FEF_2_THAL_RATIO = 2.0;
LOOP_GAIN = 1.0; % ...of FEF THAL loop

DIFFUSE_NORM = 0.02 / (layerDims(1)*layerDims(2)) * (layerLocs(1) * layerLocs(2)); % Scaling for adjusting STN diffuse projection normalisation.

% Affect bloom in SC
SC_BUILDUP_RECIP = 0.3;%2.8
SC_SNR_DAMPING = 3.0;



% Add subsystem
orient = sml_system('orient');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD NEURAL LAYERS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outpars = defParsOut;
actpars = defParsAct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RETINA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orient = nw_modAddPop(orient, 'retina_1', fS, [In_dims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
orient = nw_modAddPop(orient, 'retina_2', fS, [In_dims], {[In_locs]},[p2a 'leaky'], actpars, [p2o 'linear'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orient= nw_modAddPop(orient, 'SC_sup', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);
orient= nw_modAddPop(orient, 'SC_buildup', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEF etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orient = nw_modAddPop(orient, 'FEF', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
orient = nw_modAddPop(orient, 'THAL', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);
orient = nw_modAddPop(orient, 'TRN', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BG = sml_system('BG');

% dopamine source
state = [];
state.data = DAData;
state.repeat = true;
state.ndims = 1;
BG = BG.addprocess('DA', 'dev\std\source\numeric', fS, state);

outpars.c = 0.2;
BG = nw_modAddPop(BG, 'STR_D1', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
BG = nw_modAddPop(BG, 'STR_D2', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

outpars.c = -0.10;
actpars.neg_reversal_potential = -0.5;
actpars.tau_membrane = 0.02;
BG = nw_modAddPop(BG, 'STN', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'exp'], outpars);
actpars.tau_membrane = 0.02;

outpars.c = -0.10;
BG = nw_modAddPop(BG, 'GPe', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);
BG = nw_modAddPop(BG, 'SNr', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
actpars.neg_reversal_potential = inf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SACCADIC GENERATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%
state = [];
state.xRange = pantilt_scale*In_dims(2);
state.yRange = pantilt_scale*In_dims(1);
state.threshold = 20*(layerDims(1)/layerLocs(1))*(layerDims(2)/layerLocs(2));
orient = orient.addprocess('SG', 'dev/abrg/2008/emSG', fS, state);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD PROJECTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RETINA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add intrinsic projections (see "help nw_addProj")
projState = [];
projState.delay = 0.0;
projState.norm='affx'; %- confirm the modlin default 
defParsProj = projState;
projState.delay = 0.01;
orient = nw_modAddProj(orient, fS, 'retina_2', 'retina_1', -6, [p2p 'onetoone'], projState, 'add');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

projState = defParsProj;
projState.sigma = 1.0; % number of neurons - orientlayers are locs = dims
orient = nw_modAddProj(orient, fS, 'SC_sup', 'SC_buildup', 0.1, [p2p 'gaussian'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'SC_buildup', 'SC_buildup', SC_BUILDUP_RECIP, [p2p 'gaussian'], projState, 'add');%0.05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEF etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

THAL_2_FEF_SCALAR = sqrt(LOOP_GAIN/FEF_2_THAL_RATIO);
FEF_2_THAL_SCALAR = LOOP_GAIN/THAL_2_FEF_SCALAR;

orient = nw_modAddProj(orient, fS, 'FEF', 'THAL', FEF_2_THAL_SCALAR, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'THAL', 'FEF', THAL_2_FEF_SCALAR, [p2p 'onetoone'], projState, 'add');

orient = nw_modAddProj(orient, fS, 'FEF', 'TRN', 1, [p2p 'onetoone'], projState, 'add');

orient = nw_modAddProj(orient, fS, 'TRN', 'THAL', -0.6, [p2p 'allbutsame'], projState, 'shunt');
orient = nw_modAddProj(orient, fS, 'TRN', 'THAL', -0.3, [p2p 'onetoone'], projState, 'shunt');

orient = nw_modAddProj(orient, fS, 'THAL', 'TRN', 0.5, [p2p 'onetoone'], projState, 'add');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%STN_IN = PUSH;
STR_IN = STN_IN*PUSH_PULL_RATIO;

STR_IN = 0.4;

projState = defParsProj;
projState.srcDims = 1;
projState.norm = 'none';
BG = nw_modAddInput(BG, fS, 'DA', 'STR_D1', 1, [p2p 'diffuse'], projState, 'shunt');
BG = nw_modAddInput(BG, fS, 'DA', 'STR_D2', -1, [p2p 'diffuse'], projState, 'shunt');
projState.norm = 'affx';

projState = defParsProj;
BG = nw_modAddProj(BG, fS, 'STR_D1', 'SNr', -STR_IN, [p2p 'onetoone'], projState, 'add');
BG = nw_modAddProj(BG, fS, 'STR_D2', 'GPe', -STR_IN, [p2p 'onetoone'], projState, 'add');

projState.norm = 'none'; % just STN
BG = nw_modAddProj(BG, fS, 'STN', 'SNr', 1.0, [p2p 'diffuse'], projState, 'add');
BG = nw_modAddProj(BG, fS, 'STN', 'GPe', 1.0, [p2p 'diffuse'], projState, 'add');
projState.norm = 'affx';
BG = nw_modAddProj(BG, fS, 'GPe', 'STN', -1, [p2p 'onetoone'], projState, 'add');
projState.norm = 'affx';

BG = nw_modAddProj(BG, fS, 'GPe', 'SNr', -0.3, [p2p 'onetoone'], projState, 'add');

orient = orient.addsubsystem('BG', BG);

%%%%%%%%%%%%%%%%%%%%%%%%% links between subsystems %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% orient to BG ------------------------------------------------------------

projState = defParsProj;
projState.sigma = 6;
projState.norm = 'none'; % Just for STN in
orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D1', 0.5, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D2', 0.5, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STN', STN_IN/(layerDims(1)*layerDims(2)), [p2p 'diffuse'], projState, 'add');

orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D1', 0.5, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D2', 0.5, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STN', STN_IN/(layerDims(1)*layerDims(2)), [p2p 'diffuse'], projState, 'add');
projState.norm = 'affx';

% Retina to orient --------------------------------------------------------

% sigma here can be decreased if necessary
projState = defParsProj;
projState.sigma = 0.6;
projState.delay = 0.05;
%orient = nw_modAddProj(orient, fS, 'retina_1', 'FEF', 0.5, [p2p 'gaussian'], projState, 'add');
projState.delay = 0.0;

% orient to orient ------------------------------------------------------------
orient = nw_modAddProj(orient, fS, 'SC_sup', 'THAL', 0.5, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'SC_buildup', 'THAL', 0.6, [p2p 'onetoone'], projState, 'add');

% BG to orient ------------------------------------------------------------
projState.sigma = 1.3; 
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'THAL', -0.6/CAP_LEVEL, [p2p 'gaussian'], projState, 'shunt');
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'TRN', -3.0/CAP_LEVEL, [p2p 'gaussian'], projState, 'shunt');
%orient = nw_modAddProj(orient, fS, 'BG.SNr', 'THAL', -0.0, [p2p 'onetoone'], projState, 'add');

% Retina to orient------------------------------------------------------------
projState.delay = 0.05;
projState.sigma = 0.6; 
orient = nw_modAddProj(orient, fS, 'retina_1', 'SC_sup', 1, [p2p 'gaussian'], projState, 'add');

% orient to orient------------------------------------------------------------
projState.delay = 0.0;
projState.sigma = 0.6;
orient = nw_modAddProj(orient, fS, 'FEF', 'SC_buildup', 0.3, [p2p 'gaussian'], projState, 'add');%0.02

% BG to orient----------------------------------------------------------------
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', -SC_SNR_DAMPING, [p2p 'onetoone'], projState, 'shunt');

orient= orient.link('SC_buildup>out', 'SG<<SC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SCOPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if scopesOn == true && reach_scopes == false
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [20 300];
    state.colours = 'fire';
    state.title = scopeTarg;
    orient = orient.addprocess('scopeFEF', 'dev\abrg\2008\scope', fS, state);
    orient =orient.link(scopeTarg, 'scopeFEF<<mono<in');

    
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [400 300];
    state.colours = 'fire';
    state.title = scopeTargA;
    orient = orient.addprocess('scopeA', 'dev\abrg\2008\scope', fS, state);
    orient =orient.link(scopeTargA, 'scopeA<<mono<in');
    
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [20 600];
    state.colours = 'fire';
    state.title = scopeTargB;
    orient = orient.addprocess('scopeB', 'dev\abrg\2008\scope', fS, state);
    orient =orient.link(scopeTargB, 'scopeB<<mono<in');
     
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [400 600];
    state.colours = 'fire';
    state.title = scopeTarg2;
    orient = orient.addprocess('scope2', 'dev\abrg\2008\scope', fS, state);
    orient =orient.link(scopeTarg2, 'scope2<<mono<in');

    state = [];
    state.scale = [-0.3 1.4];
    state.position = [20 900];
    state.title = 'SG_inhib';
    state.height = 100;
    state.length =200;
    state.interval = inter;
    orient = orient.addprocess('scopeOPN', 'dev\abrg\2008\scalarScope', fS, state);
    orient =orient.link('SG>inhib', 'scopeOPN<in');
    
end

%*************************************************************************%
%                              END ORIENT                                 %
%*************************************************************************%

sys = sys.addsubsystem('orient', orient);
