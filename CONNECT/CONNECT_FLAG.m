%%%%%%%%%%%%%%%%%%%%%%%%%%% INTER SUB LINKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% INHIBIT POST SACCADE
    projState = [];
    projState.srcDims = [1];
    projState.norm = 'none';

    actpars.sigma_membrane = 0.0;
    actpars.tau_membrane = 0.0;
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


sys = sys.addprocess('input_proj_sum', 'std/2009/math/eproduct', fS, projState);
state = []; state.data = rand(In_dims).*SIG_NOISE + (1-SIG_NOISE/2); state.ndims = 2; state.repeat = true;
sys = sys.addprocess('background', 'std/2009/source/numeric', fS, state);
sys = sys.addprocess('input_proj1', [p2p 'onetoone'], fS, projState);


sys = sys.link('extern/world>retinaImageLum', 'input_proj_sum<in',0);
sys = sys.link('input_proj_sum>out', 'input_proj1<in',0);
sys = sys.link('background>out', 'input_proj_sum<in',0);

sys = sys.link('input_proj1>out', 'orient/retina_in/act<in',0);

projState = [];
projState.sigma = 2.0;
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

in_strength = 0.1;

sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageR', 'vis.R_V1', in_strength, [p2p 'onetoone'], projState, 'add');
sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageG', 'vis.G_V1', in_strength, [p2p 'onetoone'], projState, 'add');
sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageB', 'vis.B_V1', in_strength, [p2p 'onetoone'], projState, 'add');

sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageR', 'vis.W_V1', in_strength/3, [p2p 'onetoone'], projState, 'add');
sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageG', 'vis.W_V1', in_strength/3, [p2p 'onetoone'], projState, 'add');
sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageB', 'vis.W_V1', in_strength/3, [p2p 'onetoone'], projState, 'add');

%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP-DOWN NOGO FOR FIXATION %%%%%%%%%%%%%%%%%%%%

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
    exe = exe.log('vis/LIP/out>out');
    exe = exe.log('orient/FEF/out>out');
    exe = exe.log('orient/BG/SNr/out>out');
    exe = exe.log('vis/ITfb/out>out'); 
        exe = exe.log('extern/world');
            exe = exe.log('orient/SC_sup/out>out');
    
end
