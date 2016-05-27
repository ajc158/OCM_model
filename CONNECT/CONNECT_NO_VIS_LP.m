%%%%%%%%%%%%%%%%%%%%%%%%%%% INTER SUB LINKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% INHIBIT POST SACCADE
    projState = [];
    projState.srcDims = [1];
    projState.norm = 'none';

    actpars.sigma_membrane = 0.0;
    actpars.tau_membrane = 0.1;
    actpars.p = 0;

    sys = nw_modAddPop(sys, 'inhib', fS, [layerDims], {[layerLocs]}, [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

    sys = nw_modAddInput(sys, fS, 'orient.SG>inhib', 'inhib', 5, [p2p 'diffuse'], projState, 'add');
    
    projState = struct();
    
    % input to dampen phasic during eye movement and prevent it affecting THAL

    

    sys = nw_modAddProj(sys, fS, 'orient.SC_buildup', 'inhib', 1, [p2p 'onetoone'], projState, 'shunt');

    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.SC_buildup', SG_TO_SC_BUILDUP, [p2p 'diffuse'], projState, 'add');

    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.SC_sup', -5, [p2p 'diffuse'], projState, 'add');
disp('here');

    % sys = nw_modAddProj(sys, fS, 'inhib', 'orient.FEF_mv', -0.5, [p2p 'onetoone'], projState, 'add');
    projState.sigma = 5;
    projState.norm = 'none';
    sys = nw_modAddProj(sys, fS, 'inhib', 'orient.FEF', -0.7, [p2p 'gaussianIIR'], projState, 'add');
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
projState.sigma = 2.0;
projState.weight = 1;
projState.dstDims = In_dims;
projState.dstLocs = In_locs;

in_layer_size = In_dims(1)/2;
out_layer_size = In_dims(1);

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

sys = sys.addprocess('input_proj_sum', 'std/2009/math/eproduct', fS, projState);
state = []; state.dist = 'normal'; state.dims = In_dims; state.pars = [0.0, SIG_NOISE];
%state = []; state.data = double(rand(In_dims).*SIG_NOISE + (1-SIG_NOISE/2)); state.ndims = 2; state.repeat = true;
%sys = sys.addprocess('background', 'std/2009/source/numeric', fS, state);
sys = sys.addprocess('background', 'std/2009/random/numeric', fS, state);
sys = sys.addprocess('input_proj1', [p2p 'IIRLPconv'], fS, projState);

sys = sys.addprocess('input_add', 'std/2009/math/esum', fS, []);

sys = sys.link('background>out', 'input_proj_sum<in',0);
sys = sys.link('extern/world>retinaImageLum', 'input_proj_sum<in',0);

sys = sys.link('extern/world>retinaImageLum', 'input_add<in',0);
sys = sys.link('input_proj_sum>out', 'input_add<in',0);

sys = sys.link('input_add>out', 'input_proj1<in',0);
sys = sys.link('input_proj1>out', 'orient/retina_in/act<in',0);

projState = [];
projState.sigma = 3.0;
projState.srcDims = In_dims;
projState.srcLocs = {[layerLocs]};
projState.edge_compensation = 'wrapV';
projState.norm = 'aff';
sys = nw_modAddProj(sys, fS, 'orient.retina_in', 'orient.retina_1', 1.0, [p2p 'gaussianIIR'], projState, 'add');
sys = nw_modAddProj(sys, fS, 'orient.retina_in', 'orient.retina_2', 1.0, [p2p 'gaussianIIR'], projState, 'add');

sys = nw_modAddInput(sys, fS, 'input_proj1>out', 'orient.FEF_input', 1.0, [p2p 'onetoone'], projState, 'add');
% sys = nw_modAddInput(sys, fS, 'input_proj1>out', 'orient.FEF_input', 1.0, [p2p 'diffuse'], projState, 'shunt_div');

% input normalisation layer
actpars.p = 0.0;
sys = nw_modAddPop(sys, 'FEF_norm', fS, [layerLocs], [layerDims], [p2a 'leaky'], actpars, [p2o 'linear'], outpars);

projState = struct();
projState.delay = 0.0;
projState.sigma = 0.2;
projState.norm = 'aff';
projState.edge_compensation = 'wrapV';
sys = nw_modAddProj(sys, fS, 'orient.FEF_input', 'FEF_norm', 0.5, [p2p 'gaussianIIR'], projState, 'add');

projState.delay = 0.07;
if input_normalised == true
    sys = nw_modAddProj(sys, fS, 'FEF_norm', 'orient.FEF', 40.0, [p2p 'onetoone'], projState, 'add');
    projState.sigma = 3;
    projState.edge_compensation = 'wrapV';
    projState.norm = 'none';
    sys = nw_modAddProj(sys, fS, 'FEF_norm', 'orient.FEF', 10.0, [p2p 'gaussianIIR'], projState, 'shunt_div');
else
    sys = nw_modAddProj(sys, fS, 'FEF_norm', 'orient.FEF', 1.0, [p2p 'onetoone'], projState, 'add');
end

% 
% % sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageLum', 'orient.retina_1', 1.0, [p2p 'gaussianLPconvF'], projState, 'add');
% % sys = nw_modAddInput(sys, fS, 'extern.world>retinaImageLum', 'orient.retina_2', 1.0, [p2p 'gaussianLPconvF'], projState, 'add');
% 
% gain_cam=1;
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP-DOWN NOGO FOR FIXATION %%%%%%%%%%%%%%%%%%%%
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    w = (exp(-(y.^2.0)/FIX_ZONE_WIDTH/4));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));

%     sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D1', FIX_ZONE_D1_DRIVE, [p2p 'manual'], projState, 'add');
%     sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D2', FIX_ZONE_D2_DRIVE, [p2p 'manual'], projState, 'add');
 
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
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.retina_1', -1, [p2p 'manual'], projState, 'shunt');
end

if big_noise == true
    
    % add some gaussian noise, filterd both temporally and spatially!
    actpars = [];
    actpars.sigma_membrane = 1.0;
    actpars.tau_membrane = 0.1;
    actpars.p = 0;
    outpars = [];
    defParsOut.limits = [-inf inf];
    defParsOut.m = 1;
    defParsOut.c = 0;
    sys = nw_modAddPop(sys, 'FEF_noise', fS, [layerLocs], [layerDims], [p2a 'leaky'], actpars, [p2o 'linear'], outpars);
    projState = [];
    projState.sigma = 3.0;
    projState.norm = 'none';
    projState.edge_compensation = 'wrapV';
    sys = nw_modAddProj(sys, fS, 'FEF_noise', 'orient.FEF', BIG_NOISE_WEIGHT, [p2p 'gaussianIIR'], projState, 'add');

end

if less_input_from_fovea == true
    projState = [];
    projState.srci = single(zeros(In_dims(1)*In_dims(2),1));
    projState.dsti = single(0:In_dims(1)*In_dims(2)-1)';
    projState.weights = single(zeros(In_dims(1)*In_dims(2),1));
    [x,y] = meshgrid(0:1:(In_dims(1)-1));
    w = (exp(-(y.^2.0)/(40^2)));
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:));
    
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.FEF_input', -1, [p2p 'manual'], projState, 'shunt');
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
    
end
    
if fovea_STN_compensation == true
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));
    y2 = y - layerDims(1)/2+2;
    y2 = tanh(y2./2).*0.5 + 0.5;
    w = 1-y2;
    projState.srcDims = [1];
    projState.weights = projState.weights + squeeze(w(:)).*0.99;
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STN', -1, [p2p 'manual'], projState, 'shunt');
end


if nogo_on == true
    projState = [];
    projState.srci = single(zeros(layerDims(1)*layerDims(2),1));
    projState.dsti = single(0:layerDims(1)*layerDims(2)-1)';
    projState.weights = single(zeros(layerDims(1)*layerDims(2),1));
    [x,y] = meshgrid(0:1:(layerDims(1)-1));

    tempW = reshape(projState.weights,50,50);
    tempW(1:12,:) = 1;
    projState.weights = reshape(tempW,50*50,1);
       
    
    projState.srcDims = [1];
%     projState.weights = projState.weights + squeeze(w(:));
    sys = nw_modAddInput(sys, fS, 'ones>out', 'orient.BG.STR_D2', 1.0, [p2p 'manual'], projState, 'add');
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
end
if logging_on == 3
    exe = exe.log('orient/SG');
    exe = exe.log('orient/SC_buildup/out>out');
    exe = exe.log('orient/SC_sup/out>out');
    exe = exe.log('orient/THAL/out>out');
    exe = exe.log('orient/retina_1/out>out');
    exe = exe.log('orient/FEF/out>out');
    exe = exe.log('orient/FEF_input/out>out');
    exe = exe.log('orient/BG/SNr');
    exe = exe.log('orient/BG/STN/out>out');
    exe = exe.log('orient/BG/STR_D1/out>out');
%     exe = exe.log('orient/SG>inhib');
    exe = exe.log('inhib');
        exe = exe.log('input_proj1');
    exe = exe.log('FEF_noise/out>out');
        
end
if logging_on == 4
    exe = exe.log('orient/SG');
    exe = exe.log('orient/SG>target');
    exe = exe.log('orient/SC_buildup/out>out');
%     exe = exe.log('orient/SC_sup/out>out');
%     exe = exe.log('orient/THAL/out>out');
%     exe = exe.log('orient/retina_1/out>out');
%     exe = exe.log('orient/FEF/out>out');
     exe = exe.log('orient/BG/SNr');
%     exe = exe.log('orient/BG/STN/out>out');
%     exe = exe.log('orient/BG/STR_D1/out>out');
%     exe = exe.log('inhib');
        
end

if logging_on == 20
    exe = exe.log('orient/SG>target');
end
if logging_on == 21
    exe = exe.log('orient/SG>target');
    exe = exe.log('orient/FEF/out>out');
    exe = exe.log('FEF_norm/out>out');
    exe = exe.log('orient/BG/SNr/out>out');
    exe = exe.log('orient/retina_1/out>out');
    exe = exe.log('orient/retina_in/out>out');
    exe = exe.log('orient/FEF_input/out>out');
end
