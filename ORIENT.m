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

% Add subsystem
orient = sml_system();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD NEURAL LAYERS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outpars = defParsOut;
actpars = defParsAct;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RETINA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actpars.sigma_membrane = 0;
orient = nw_modAddPop(orient, 'retina_in', fS, [ret_dims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
orient = nw_modAddPop(orient, 'retina_1', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
actpars.tau_membrane = 0.03;
orient = nw_modAddPop(orient, 'retina_2', fS, [layerDims], {[layerLocs]},[p2a 'leaky'], actpars, [p2o 'linear'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outpars = defParsOut;
actpars = defParsAct;
orient= nw_modAddPop(orient, 'SC_sup', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'tanh'], outpars);
actpars.p = 1;
orient= nw_modAddPop(orient, 'SC_buildup', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
orient= nw_modAddPop(orient, 'SG_in', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEF etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outpars = defParsOut;
actpars = defParsAct;
outpars.c = -0.0;
actpars.p = 1;
actpars.sigma_membrane = BACKGROUND_NOISE
orient = nw_modAddPop(orient, 'FEF_input', fS, [In_dims], [In_locs], [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
outpars = defParsOut;
actpars = defParsAct;
if strcmp(taskType, 'TEST')
%     actpars.sigma_membrane = BACKGROUND_NOISE;
end
orient = nw_modAddPop(orient, 'FEF', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
outpars = defParsOut;
actpars = defParsAct;
orient = nw_modAddPop(orient, 'THAL', fS, [layerDims], {[layerLocs]}, [p2a 'leakyThal'], actpars, [p2o 'linear'], outpars);
% orient = nw_modAddPop(orient, 'THAL_IL', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BG = sml_system();

% dopamine source
state = [];
state.data = DOPAMINE;
state.repeat = true;
state.ndims = 1;
BG = BG.addprocess('DA', 'std/2009/source/numeric', fS, state);

outpars = defParsOut;
actpars = defParsAct;
outpars.c = STRIATAL_OFFSET;
BG = nw_modAddPop(BG, 'STR_D1', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
BG = nw_modAddPop(BG, 'STR_D2', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);


outpars = defParsOut;
actpars = defParsAct;
outpars.c = 0.9;
outpars.m = 1;
outpars.limits = [0 1];
actpars.tau_membrane = 0.005;
actpars.neg_reversal_potential = -0.4;
BG = nw_modAddPop(BG, 'STN', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'exp'], outpars);


outpars = defParsOut;
actpars = defParsAct;
BG = nw_modAddPop(BG, 'GPe', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
outpars.limits = [0.0 1.0];
BG = nw_modAddPop(BG, 'SNr', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

outpars = defParsOut;
actpars = defParsAct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SACCADIC GENERATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%
state = [];
state.xRange = pantilt_scale*In_dims(2);
state.yRange = pantilt_scale*In_dims(1);
state.mode = 1.0;

in_layer_size = layerDims(1);

if targetMode > 0
    state.target = targetVals;
end
% state.E_2 = 2.5/degrees_to_edge*(in_layer_size/2);
% state.M_f = in_layer_size/(state.E_2*log(1+(degrees_to_edge/state.E_2)));

state.E_2 = 2.5;
state.M_f = in_layer_size/(state.E_2*log(1+(degrees_to_edge/state.E_2)));

%state.quadraticFactor = 0.0006;%0.00146
state.threshold = 0.4;%15*(layerDims(1)/layerLocs(1))*(layerDims(2)/layerLocs(2));
if strcmp(taskType,'TEST_ROBOT')
    state.xRange2 = 26/50;
    state.yRange2 = 26/50;
    state.xRange = degrees_to_edge*2 * 1.1;
    state.yRange = degrees_to_edge*2 * 1.1;% 1.1 is a fix factor
    state.mode = 1.0;
    state.quadraticFactor = 0.0006;%0.00146
    orient = orient.addprocess('SG', 'dev/abrg/2009/emSGLProbot', fS, state);
elseif strcmp(taskType,'FLAG')
    state.xRange = In_dims(1);
    state.yRange = In_dims(2);
    orient = orient.addprocess('SG', 'dev/abrg/2009/emSG', fS, state);
else
    orient = orient.addprocess('SG', 'dev/abrg/2009/emSGLP', fS, state);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD PROJECTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RETINA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add intrinsic projections (see "help nw_modAddProj")
projState = [];
projState.delay = 0.0;
projState.norm='aff';
projState.decimate = 0.0;
defParsProj = projState;
orient = nw_modAddProj(orient, fS, 'retina_2', 'retina_1', RETINA2_TO_RETINA1, [p2p 'onetoone'], projState, 'add');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

projState = defParsProj;
projState.sigma = 0.6;
projState.edge_compensation = 'wrapV';
orient = nw_modAddProj(orient, fS, 'SC_sup', 'SC_buildup', SC_SUPERIOR_TO_SC_BUILDUP, [p2p 'gaussianIIR'], projState, 'add');
projState.sigma = 2.0; % 2.0
projState.norm= 'none';
orient = nw_modAddProj(orient, fS, 'SC_buildup', 'SC_buildup', SC_BUILDUP_RECIP, [p2p 'gaussianIIR'], projState, 'add');%0.05
projState.norm='aff';
orient = nw_modAddProj(orient, fS, 'SC_buildup', 'SG_in', 1, [p2p 'onetoone'], projState, 'add');%0.05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FEF etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
projState = defParsProj;

projState.sigma = 1.5;
projState.norm= 'aff';
projState.edge_compensation = 'wrapV';
orient = nw_modAddProj(orient, fS, 'FEF', 'THAL', FEF_2_THAL, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'THAL', 'FEF', THAL_2_FEF, [p2p 'onetoone'], projState, 'add');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
projState = defParsProj;
projState.srcDims = 1;
projState.norm = 'none';
BG = nw_modAddInput(BG, fS, 'DA', 'STR_D1', 1, [p2p 'diffuse'], projState, 'shunt');
BG = nw_modAddInput(BG, fS, 'DA', 'STR_D2', -1, [p2p 'diffuse'], projState, 'shunt');

projState = defParsProj;
if hack_model == false
    projState.sigma = 1.0;
    projState.norm = 'aff';
    projState.edge_compensation = 'wrapV';
    projState.delay = 0.0;
    BG = nw_modAddProj(BG, fS, 'STR_D1', 'SNr', STR_D1_TO_SNR, [p2p 'gaussianIIR'], projState, 'add');
    BG = nw_modAddProj(BG, fS, 'STR_D2', 'GPe', STR_D2_TO_GPE, [p2p 'gaussianIIR'], projState, 'add');
else
    projState.sigma = 2.0;% 1.0
    projState.norm = 'aff';
    projState.edge_compensation = 'wrapV';
    projState.delay = 0.0;
    BG = nw_modAddProj(BG, fS, 'STR_D1', 'SNr', STR_D1_TO_SNR, [p2p 'gaussianIIR'], projState, 'add');
    BG = nw_modAddProj(BG, fS, 'STR_D2', 'GPe', STR_D2_TO_GPE, [p2p 'gaussianIIR'], projState, 'add');
end

projState = defParsProj;
BG = nw_modAddProj(BG, fS, 'STN', 'SNr', STN_TO_SNR, [p2p 'diffuse'], projState, 'add');
BG = nw_modAddProj(BG, fS, 'STN', 'GPe', STN_TO_GPE, [p2p 'diffuse'], projState, 'add');
BG = nw_modAddProj(BG, fS, 'GPe', 'STN', GPE_TO_STN, [p2p 'onetoone'], projState, 'add');
BG = nw_modAddProj(BG, fS, 'GPe', 'SNr', GPE_TO_SNR, [p2p 'onetoone'], projState, 'add');

% % STN control source
% state = [];
% state.data = STN_CTRL;
% state.repeat = true;
% state.ndims = 1;
% BG = BG.addprocess('src_STN', 'std/2009/source/numeric', fS, state);
% 
% projState = [];
% projState.norm = 'none';
% projState.srcDims = 1;
% BG = nw_modAddInput(BG, fS, 'src_STN>out', 'STN', 1.0, [p2p 'diffuse'], projState, 'add');

orient = orient.addsubsystem('BG', BG);

%%%%%%%%%%%%%%%%%%%%%%%%% links between subsystems %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% orient to BG ------------------------------------------------------------

projState = defParsProj;

if fovea_striatum_comp_v2 == true

    
    projState.srci = zeros(layerDims(1)*layerDims(2),1);
    projState.dsti = zeros(layerDims(1)*layerDims(2),1);
    for i = 1:layerDims(1)
        for j = 1:layerDims(2)
            num = (i-1)*layerDims(2)+j;
            projState.srci(num) = single(num-1);
            projState.dsti(num) = single(num-1);
            projState.weights(num) = single(tanh(j./2-layerDims(1)/4+ fovea_damping_offset).*0.5+0.5);% was 0.5 and 0.5
        end
    end
        
    projState.sigma = STR_IN_SIGMA;
    projState.norm = 'none';
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D1', FEF_TO_STR_D1, [p2p 'manual'], projState, 'add');
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D2', FEF_TO_STR_D2, [p2p 'manual'], projState, 'add');
    projState.sigma = 3;
    projState.norm = 'aff';
    projState.edge_compensation = 'wrapV';
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STN', FEF_TO_STN, [p2p 'gaussianIIR'], projState, 'add');
    projState.sigma = STR_IN_SIGMA;
    projState.norm = 'none';
    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D1', THAL_TO_STR_D1, [p2p 'manual'], projState, 'add');
    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D2', THAL_TO_STR_D2, [p2p 'manual'], projState, 'add');
    projState.sigma = 3;
    projState.norm = 'aff';
    projState.edge_compensation = 'wrapV';
    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STN', THAL_TO_STN, [p2p 'gaussianIIR'], projState, 'add');

    
else
    
    projState.sigma = STR_IN_SIGMA;
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D1', FEF_TO_STR_D1, [p2p STR_IN_TYPE], projState, 'add');
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STR_D2', FEF_TO_STR_D2, [p2p STR_IN_TYPE], projState, 'add');
    projState.sigma = 3;
    projState.edge_compensation = 'wrapV';
    orient = nw_modAddProj(orient, fS, 'FEF', 'BG.STN', FEF_TO_STN, [p2p 'gaussianIIR'], projState, 'add');
    projState.sigma = STR_IN_SIGMA;

    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D1', THAL_TO_STR_D1, [p2p STR_IN_TYPE], projState, 'add');
    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STR_D2', THAL_TO_STR_D2, [p2p STR_IN_TYPE], projState, 'add');
    projState.sigma = 3;
    projState.edge_compensation = 'wrapV';
    orient = nw_modAddProj(orient, fS, 'THAL', 'BG.STN', THAL_TO_STN, [p2p 'gaussianIIR'], projState, 'add');

end

% Retina to orient --------------------------------------------------------

% sigma here can be decreased if necessary
projState = defParsProj;
projState.sigma = 0.6;
projState.delay = 0.05; % Wurtz and Albano
projState.norm = 'aff';
projState.edge_compensation = 'wrapV';
projState.sigma = 0.5;
orient = nw_modAddProj(orient, fS, 'retina_1', 'SC_sup', RETINA1_TO_SC_SUPERIOR, [p2p 'onetoone'], projState, 'add');

% orient to orient ------------------------------------------------------------
projState = defParsProj;
orient = nw_modAddProj(orient, fS, 'SC_sup', 'THAL', SC_SUPERIOR_TO_THAL, [p2p 'onetoone'], projState, 'add');
orient = nw_modAddProj(orient, fS, 'SC_buildup', 'THAL', SC_BUILDUP_TO_THAL, [p2p 'onetoone'], projState, 'add');

% BG to orient ------------------------------------------------------------
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'THAL', SNR_TO_THAL, [p2p 'onetoone'], projState, 'shunt');
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'THAL', SNR_TO_THAL_ADD, [p2p 'onetoone'], projState, 'add');

% orient to orient------------------------------------------------------------
projState = defParsProj;
projState.sigma = 0.6;
projState.edge_compensation = 'wrapV';
orient = nw_modAddProj(orient, fS, 'FEF', 'SC_buildup', FEF_TO_SC_BUILDUP, [p2p 'gaussianIIR'], projState, 'add');%0.3

% BG to orient----------------------------------------------------------------
projState = defParsProj;
projState.sigma = 4.0;
projState.edge_compensation = 'wrapVclampH';
if hack_model == false
    orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', SNR_TO_SC_BUILDUP, [p2p 'onetoone'], projState, 'shunt');
else
    orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', SNR_TO_SC_BUILDUP, [p2p 'onetoone'], projState, 'shunt');
%     orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', SNR_TO_SC_BUILDUP, [p2p 'gaussianIIR'], projState, 'shunt');
end
% orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', SNR_TO_SC_BUILDUP_D, [p2p 'onetoone'], projState, 'shunt_div');
orient = nw_modAddProj(orient, fS, 'BG.SNr', 'SC_buildup', SNR_TO_SC_BUILDUP_ADD, [p2p 'onetoone'], projState, 'add');

orient= orient.link('SG_in>out', 'SG<<SC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SCOPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if scopesOn == true
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [20 300];
    state.colours = 'fire';
    state.title = scopeTarg;
    orient = orient.addprocess('scopeFEF', 'dev/abrg/2009/scope', fS, state);
    orient =orient.link(scopeTarg, 'scopeFEF<<mono<in');

    
    state = [];
    state.dims = [layerDims];
    state.scale=[0.0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [400 300];
    state.colours = 'fire';
    state.title = scopeTargA;
    orient = orient.addprocess('scopeA', 'dev/abrg/2009/scope', fS, state);
    orient =orient.link(scopeTargA, 'scopeA<<mono<in');
    
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [20 600];
    state.colours = 'ice';
    state.title = scopeTargB;
    orient = orient.addprocess('scopeB', 'dev/abrg/2009/scope', fS, state);
    orient =orient.link(scopeTargB, 'scopeB<<mono<in');
     
    state = [];
    state.dims = [layerDims];
    state.scale=[0 1.01];
    state.zoom = 8;
    state.interval = inter;
    state.position = [400 600];
    state.colours = 'fire';
    state.title = scopeTarg2;
    orient = orient.addprocess('scope2', 'dev/abrg/2009/scope', fS, state);
    orient =orient.link(scopeTarg2, 'scope2<<mono<in');

%     state = [];
%     state.scale = [-0.3 1.4];
%     state.position = [20 900];
%     state.title = 'SG_inhib';
%     state.height = 100;
%     state.length =200;
%     state.interval = inter;
%     orient = orient.addprocess('scopeOPN', 'dev/abrg/2008/scalarScope', fS, state);
%     orient =orient.link('SG>inhib', 'scopeOPN<in');
    
end

%*************************************************************************%
%                              END ORIENT                                 %
%*************************************************************************%

sys = sys.addsubsystem('orient', orient);
