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
orient = nw_modAddPop(orient, 'retina_in', fS, [32 32], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
orient = nw_modAddPop(orient, 'retina_1', fS, [32 32], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
actpars.tau_membrane = 0.1;
orient = nw_modAddPop(orient, 'retina_2', fS, [32 32], {[layerLocs]},[p2a 'leaky'], actpars, [p2o 'linear'], outpars);


orient= nw_modAddPop(orient, 'SG_in', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

state.E_2 = 2.5;
state.M_f = in_layer_size/(state.E_2*log(1+(degrees_to_edgeP/state.E_2)));

%state.quadraticFactor = 0.0006;%0.00146
state.threshold = 0.4;%15*(layerDims(1)/layerLocs(1))*(layerDims(2)/layerLocs(2));
if strcmp(taskType,'TEST_APRON')
    state.xRange2 = 26/50;
    state.yRange2 = 26/50;
    state.xRange = degrees_to_edgeP*2 * 1.1;
    state.yRange = degrees_to_edgeP*2 * 1.1;% 1.1 is a fix factor
    state.mode = 1.0;
    state.quadraticFactor = 0.0006;%0.00146
    orient = orient.addprocess('SG', 'dev/abrg/2009/emSGLProbot', fS, state);
else
    orient = orient.addprocess('SG', 'dev/abrg/2009/emSGLP', fS, state);
end


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
