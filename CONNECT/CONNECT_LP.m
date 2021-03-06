%%%%%%%%%%%%%%%%%%%%%%%%%%% INTER SUB LINKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% INHIBIT POST SACCADE
    projState = [];
    projState.srcDims = [1];
    projState.norm = 'none';

    actpars.sigma_membrane = 0.0;
    actpars.tau_membrane = 0.00;
    actpars.p = 0;
        
    % phasic damping
%     sys = nw_modAddInput(sys, fS, 'orient.SG>inhib', 'orient.retina_1', -5, [p2p 'diffuse'], projState, 'add');
    
    % specific inhibition
    sys = nw_modAddPop(sys, 'inhib', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

    sys = nw_modAddInput(sys, fS, 'orient.SG>inhib', 'inhib', 5, [p2p 'diffuse'], projState, 'add');

    projState = struct();

    sys = nw_modAddProj(sys, fS, 'orient.SC_buildup', 'inhib', 1, [p2p 'onetoone'], projState, 'shunt');

    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.SC_buildup', SG_TO_SC_BUILDUP, [p2p 'diffuse'], projState, 'add');
    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.retina_1', -1, [p2p 'diffuse'], projState, 'add');

    % sys = nw_modAddProj(sys, fS, 'inhib', 'orient.FEF_mv', -0.5, [p2p 'onetoone'], projState, 'add');
    projState.sigma = 3;
    projState.norm = 'none';
    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.FEF', -0.3, [p2p 'gaussianIIR'], projState, 'add');
    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.FEF', -0.1, [p2p 'diffuse'], projState, 'add');




% projState.norm = 'affx';
% 
% HACK!!!!!!!!!!!!!!!
state = []; state.data = 0; state.ndims = 1; state.repeat = true;
sys = sys.addprocess('zeros', 'std/2009/source/numeric', fS, state);

state = []; state.data = 1; state.ndims = 1; state.repeat = true;
sys = sys.addprocess('ones', 'std/2009/source/numeric', fS, state);

sys = sys.link('orient/SG>x', 'extern/world<<pos<x');
sys = sys.link('orient/SG>y', 'extern/world<<pos<y'); 
%!!!!!!!!!!!!!!!!!!!!
% 
% %sys = sys.link('orient/SG>PanTilt', 'extern/absPos<absPanTiltTargetRad');
% 


% world to retina ---------------------------------------------------------

projState = [];
projState.srcDims = In_dims;
projState.srcLocs = In_locs;
projState.norm = 'aff';
projState.sigma = 5.0;%2
projState.weight = 6;
projState.dstDims = In_dims;
projState.dstLocs = In_locs;

in_layer_size = In_dims(1)/2;
out_layer_size = In_dims(1);

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

sys = sys.addprocess('input_proj_sum', 'std/2009/math/eproduct', fS, projState);
state = []; state.data = rand(In_dims).*SIG_NOISE + (1-SIG_NOISE/2); state.ndims = 2; state.repeat = true;
sys = sys.addprocess('background', 'std/2009/source/numeric', fS, state);
sys = sys.addprocess('input_proj1', [p2p 'IIRLPconv'], fS, projState);


sys = sys.link('extern/world>retinaImageLum', 'input_proj_sum<in',0);
sys = sys.link('input_proj_sum>out', 'input_proj1<in',0);
sys = sys.link('background>out', 'input_proj_sum<in',0);

sys = sys.link('input_proj1>out', 'orient/retina_in/act<in',0);

projState = [];
projState.sigma = 2.0;
projState.srcDims = In_dims;
projState.srcLocs = {[layerLocs]};
projState.edge_compensation = 'wrapV';
projState.norm = 'aff';
sys = nw_modAddProj(sys, fS, 'orient.retina_in', 'orient.retina_1', 1.0, [p2p 'gaussianIIR'], projState, 'add');
sys = nw_modAddProj(sys, fS, 'orient.retina_in', 'orient.retina_2', 1.0, [p2p 'gaussianIIR'], projState, 'add');

% sys = nw_modAddInput(sys, fS, 'input_proj1>out', 'orient.FEF_input', 1.0, [p2p 'onetoone'], projState, 'add');
% sys = nw_modAddInput(sys, fS, 'input_proj1>out', 'orient.FEF_input', 1.0, [p2p 'diffuse'], projState, 'shunt_div');

projState = struct();
projState.delay = 0.0;
projState.sigma = 6.2;
projState.sigma = 1.5;
projState.radius = 1.0;
projState.norm = 'aff';
projState.edge_compensation = 'wrapV';
sys = nw_modAddProj(sys, fS, 'vis.LIP', 'orient.FEF', LIP_TO_FEF, [p2p 'discMax'], projState, 'add');
%  sys = nw_modAddProj(sys, fS, 'vis.LIP', 'orient.FEF', LIP_TO_FEF, [p2p 'gaussianIIR'], projState, 'add');

%% INPUT TO VIS

projState = [];
projState.srcDims = In_dims;
projState.srcLocs = In_locs;
projState.norm = 'none';
projState.sigma = 1;

in_layer_size = In_dims(1)/2;
out_layer_size = In_dims(1);

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

% ADD FILTERED NOISE SOURCE
sys = sys.addprocess('input_mult', 'std/2009/math/eproduct', fS, projState);
sys = sys.addprocess('input_sum', 'std/2009/math/esum', fS, projState);
actpars.sigma_membrane = STIM_NOISE;
actpars.tau_membrane = 0.5;
outpars.limits = 0;
sys = nw_modAddPop(sys, 'in_noise', fS, [In_dims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

sys = sys.link('extern/world>retinaImageLum', 'input_mult<in',0);
sys = sys.link('in_noise/out>out', 'input_mult<in',0);

sys = sys.link('extern/world>retinaImageLum', 'input_sum<in',0);
sys = sys.link('input_mult>out', 'input_sum<in',0);

projState.type = 'second_derivative_horiz';
sys = nw_modAddInput(sys, fS, 'input_sum>out', 'vis.H_V1m', -VS_IN, [p2p 'IIRLPconv'], projState, 'add');
projState.type = 'second_derivative_vert';
sys = nw_modAddInput(sys, fS, 'input_sum>out', 'vis.V_V1m', -VS_IN, [p2p 'IIRLPconv'], projState, 'add');


%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP-DOWN NOGO FOR FIXATION %%%%%%%%%%%%%%%%%%%%
if fixation_nogo_on == true
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    w = (exp(-(y.^2.0)/FIX_ZONE_WIDTH/4));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));

%     sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D1', FIX_ZONE_D1_DRIVE, [p2p 'manual'], projState, 'add');
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D2', FIX_ZONE_D2_DRIVE, [p2p 'manual'], projState, 'add');
end
     
%%% DIMINISH RESPONSE AT FOVEA

if more_phasic_in_periphery == true
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    w = (exp(-(y.^2.0)/(20^2)));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.retina_1', -1.5, [p2p 'manual'], projState, 'shunt');
end

if comp_input_from_fovea == true
    projState = [];
    projState.srci = single(zeros(In_dims(1)*In_dims(2),1));
    projState.dsti = single(0:In_dims(1)*In_dims(2)-1)';
    projState.weights = single(zeros(In_dims(1)*In_dims(2),1));
    [x,y] = meshgrid(0:1:(In_dims(1)-1));
    w = (exp(-(y.^2.0)/(20^2)));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    
    sys = nw_modAddInput(sys, fS, 'ones>out', 'vis.H_V1m', 3.5, [p2p 'manual'], projState, 'shunt');
    sys = nw_modAddInput(sys, fS, 'ones>out', 'vis.V_V1m', 3.5, [p2p 'manual'], projState, 'shunt');
end
 
if more_input_from_periphery == true
    projState = [];
    projState.srci = single(zeros(In_dims(1)*In_dims(2),1));
    projState.dsti = single(0:In_dims(1)*In_dims(2)-1)';
    projState.weights = single(zeros(In_dims(1)*In_dims(2),1));
    [x,y] = meshgrid(0:1:(In_dims(1)-1));
    w = 1-(exp(-(y.^2.0)/(40^2)));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.FEF_input', 1, [p2p 'manual'], projState, 'shunt');
end
 
if fovea_striatum_compensation == true
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
%     w = (exp(-(y.^2.0)/(10^2)));
    y2 = y - layerDims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1.1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D1', -1, [p2p 'manual'], projState, 'shunt');
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D2', -1, [p2p 'manual'], projState, 'shunt');
    
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    y2 = y - layerDims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STN', -0.7, [p2p 'manual'], projState, 'shunt');
end

if fovea_striatum_comp_v2 == true

    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    y2 = y - layerDims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STN', -0.0, [p2p 'manual'], projState, 'shunt');
end

%%% SG centre off i.e. DON'T LOOK AT THINGS AT FIXATION
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(-(layerDims(1)-1)/2:1:(layerDims(1)-1)/2);
    [theta, rho] = cart2pol(x,y);
    w = (exp(-(rho.^2.0)/4.0));
    projState.srcDims = 1;
    projState.weights = projState.weights + squeeze(w(:));

    
% TOP DOWN BIAS TO D2
state = []; state.data = D2_BIAS; state.ndims = 1; state.repeat = true;
sys = sys.addprocess('d2_bias', 'std/2009/source/numeric', fS, state);

    projState = [];
    projState.norm = 'none';
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    y2 = y - layerDims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'd2_bias>out', 'orient.BG.STR_D2', 1, [p2p 'diffuse'], projState, 'add');

    if fix_passthough == true
    
    state = []; state.data = zeros(1, num_samples); state.data(1:0.2*fS) = 1.0;
    state.ndims = 1; state.repeat = true;
    sys = sys.addprocess('fix_bias', 'std/2009/source/numeric', fS, state);

    projState = [];
    projState.norm = 'none';
    projState.srci = single(zeros(ret_dims(1)*ret_dims(2),1));
    projState.dsti = single(0:ret_dims(1)*ret_dims(2)-1)';
    projState.weights = single(zeros(ret_dims(1)*ret_dims(2),1));
    [x,y] = meshgrid(0:1:(ret_dims(1)-1));
    y2 = y - ret_dims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'fix_bias>out', 'vis.H_V2b', 0.5, [p2p 'manual'], projState, 'shunt');
    
    end
    
%     sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.SG_in', -2.0, [p2p 'manual'], projState, 'add');

% %%% ATTEMPT TOP DOWN CONTROL OF RATE OF INTEGRATION
%     projState.norm = 'affx';
%     sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D2', 1, [p2p 'diffuse'], projState, 'add');
% 


%%% SCOPE OF VISUAL SCENE
if scopesOn == true
    state = [];
    state.dims = [In_dims];
    state.scale=[0 1.01];
    state.zoom = 1;
    state.interval = inter;
    state.position = [0 0];
    state.colours = 'fire';
    state.title = 'VISUAL INPUT';
    sys = sys.addprocess('scopeVIS', 'dev/abrg/2009/scope', fS, state);
    sys = sys.link('extern/world>retinaImageLum', 'scopeVIS<<mono<in');

end

%% LOGGING

% log some particular outputs
if logging_on == 2
    exe = exe.log('extern/world>retinaImageR');
    exe = exe.log('extern/world>retinaImageG');
    exe = exe.log('extern/world>retinaImageB');
    exe = exe.log('orient/FEF/out>out');
    exe = exe.log('orient/BG/SNr/out>out');
    exe = exe.log('orient/SC_buildup/out>out');
   
end
if logging_on == 1
    exe = exe.log('orient/SG>inhib');
    exe = exe.log('orient/SG>x');
    exe = exe.log('orient/SG>y');
    exe = exe.log('orient/FEF/out>out');
    exe = exe.log('vis/ITfb/out>out');
   % exe = exe.log('vis/LIP/out>out');
    exe = exe.log('orient/BG/SNr/out>out');
    exe = exe.log('vis/LIP');
end
if logging_on == 3
    exe = exe.log('vis/LIP');
    exe = exe.log('orient/FEF');
    exe = exe.log('orient/BG/SNr/out>out');
    exe = exe.log('orient/BG/STN/out>out');
    exe = exe.log('orient/SG>inhib');
    exe = exe.log('inhib');
    exe = exe.log('input_proj1');
    exe = exe.log('vis/ITfb/out>out');
    exe = exe.log('d2_bias');
    
end
if logging_on == 20
    exe = exe.log('orient/SG>target');
end

if logging_on == 325
%     exe = exe.log('vis/LIP/out>out');
    exe = exe.log('orient/SG>target');
    exe = exe.log('orient/FEF/out>out');
%     exe = exe.log('orient/BG/SNr/out>out');
%     exe = exe.log('vis/ITfb/out>out'); 
%     exe = exe.log('extern/world');
%     exe = exe.log('orient/SC_sup/out>out');
    exe.all = false;
    
end
