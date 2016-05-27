
% ORIENTATION VENTRAL STREAM SHUNT FB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2008 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters

layerSide = 80;

dopamine=0.2;
dims = In_dims; %[layerSide layerSide];
locs = In_locs; %{[layerSide layerSide]};
bgdims = [10];
bglocs = {[10]};

W_F = FEEDFORWARD_WEIGHT_SHUNT3;
W_B = FEEDBACK_WEIGHT_SHUNT3;
W_R = RECIPROCAL_WEIGHT_SHUNT3;
W_I = FEATURE_INHIBITION_SHUNT3;

%% %%%%% Create System
vis = sml_system();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL
%% %%%%% set up standard state data for processes
actState = [];
% membrane decay time constant
actState.tau_membrane = 0.005;
% We want eqm. = input do p = 1
actState.p = 1;
% No noise on the membrane
actState.sigma_membrane = MEMB_NOISE;

outState = [];
% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
% hard limits at 0 and 1:
outState.limits = 2;

%% %%%%% big vs small!

big = 0;
if big
    offsetVal = 2.0;
    oFactor = 3.3;
else
    offsetVal = 1.0;
    oFactor = 4.1;
end

%%%%%% do we jitter the top level reps?
robustFact = 0.0;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outFn = 'tanh';
if strcmp(outFn, 'sigmoid')
    outState.c = 0.5;
    outState.m = 12; % Get sigmoid between 0 and 1
end

vis = nw_modAddPop(vis, 'H_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
vis = nw_modAddPop(vis, 'V_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);

% automajic creation of populations!
elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
for i = 1:size(elements,2)
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'o_V4' 'Rc_V4' 'c_V4'};
for i = 1:size(elements,2)
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS, dims./4, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
for i = 1:size(elements,2)
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./4, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
vis = nw_modAddPop(vis, 'LIP', fS, dims, layerLocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);

%% %%%%%%%%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")
projState = [];
projState.delay = 0;
projState.norm = 'none';
projState.minw = 1e-2;
projState.decimate = 0.0;

%% %%%%%%%%%%%%%%%%% BG

BGloop

%% %%%%%%%%%%%%%%%%%%%% Feedforward connections

%% %%%%% V2

projState.sigma = 1.5;
projState.offset = [0.0 1.0];
projState.norm = 'affx';
vis = nw_modAddProj(vis, fS, 'H_V1m', 'TR_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'BR_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'V_V1m', 'V_V2', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [0.0 -1.0];
vis = nw_modAddProj(vis, fS, 'H_V1m', 'TL_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'BL_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'V_V1m', 'V_V2', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [1.0 0.0];
vis = nw_modAddProj(vis, fS, 'V_V1m', 'BR_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'V_V1m', 'BL_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'H_V2', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [-1.0 0.0];
vis = nw_modAddProj(vis, fS, 'V_V1m', 'TR_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'V_V1m', 'TL_V2', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'H_V2', W_F/2, [p2p 'gaussian'], projState, 'add');

% automajic!
elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
projState.radius = 2.0;
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% V4

projState.sigma = 1.5;
factor1 = 2.0;
projState.offset = [1.0 1.0].*factor1;
projState.norm = 'affx';
vis = nw_modAddProj(vis, fS, 'TL_V2m', 'o_V4', W_F/oFactor, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'TL_V2m', 'c_V4', W_F/3, [p2p 'gaussian'], projState, 'add');
projState.offset = [1.0 0.0].*factor1;
vis = nw_modAddProj(vis, fS, 'H_V2m', 'Rc_V4', W_F/8, [p2p 'gaussian'], projState, 'add');

projState.offset = [-offsetVal 1.0].*factor1;
vis = nw_modAddProj(vis, fS, 'BL_V2m', 'o_V4', W_F/oFactor, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BL_V2m', 'c_V4', W_F/3, [p2p 'gaussian'], projState, 'add');
projState.offset = [-1.0 0.0].*factor1;
vis = nw_modAddProj(vis, fS, 'H_V2m', 'Rc_V4', W_F/8, [p2p 'gaussian'], projState, 'add');

projState.offset = [1.0 -offsetVal].*factor1;
vis = nw_modAddProj(vis, fS, 'TR_V2m', 'o_V4', W_F/oFactor, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'TR_V2m', 'Rc_V4', W_F/3, [p2p 'gaussian'], projState, 'add');
projState.offset = [1.0 0.0].*factor1;
vis = nw_modAddProj(vis, fS, 'H_V2m', 'c_V4', W_F/8, [p2p 'gaussian'], projState, 'add');

projState.offset = [-1.0 -offsetVal].*factor1;
vis = nw_modAddProj(vis, fS, 'BR_V2m', 'o_V4', W_F/oFactor, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V2m', 'Rc_V4', W_F/3, [p2p 'gaussian'], projState, 'add');
projState.offset = [0.0 -1.0].*factor1;
vis = nw_modAddProj(vis, fS, 'H_V2m', 'c_V4', W_F/8, [p2p 'gaussian'], projState, 'add');


% automajic!
elements = {'o_V4' 'Rc_V4' 'c_V4'};
projState.radius = 2.1;
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 0.5;
            projState.norm = 'affx';
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% IT

projState.sigma = 1.5*2;
projState.offset = [(offsetVal - 1.0) robustFact].*4;
projState.norm = 'affx';
vis = nw_modAddProj(vis, fS, 'o_V4m', 'n8_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'o_V4m', 'n9_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'n3_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'c_V4m', 'n6_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'c_V4m', 'n5_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'n2_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [-1.0 robustFact].*4;
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'n9_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'c_V4m', 'n2_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'n5_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'o_V4m', 'n6_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [-2.0 robustFact].*4;
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'n3_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'o_V4m', 'n8_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

% automajic!
elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 4.0;
            projState.norm = 'affx';
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''gaussian''], projState, ''add'');']);
        end
    end
end

%% %%%%% Mux to IT Cortex

projState.type = 'mux';
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'n2_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'n3_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 4;
vis = nw_modAddProj(vis, fS, 'n5_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'n6_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'n8_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 7;
vis = nw_modAddProj(vis, fS, 'n9_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 8;
vis = nw_modAddProj(vis, fS, 'o_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 9;
vis = nw_modAddProj(vis, fS, 'c_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 10;
vis = nw_modAddProj(vis, fS, 'Rc_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Feedback Connections
% build BRAHMS process to represent source
state = [];
state.data = data;
state.repeat = true;
state.ndims = 1;
vis = vis.addprocess('src', 'std/2009/source/numeric', fS, state);
projState = [];
projState.srcDims = bgdims;
vis = nw_modAddInput(vis, fS, 'src>out', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddInput(vis, fS, 'src>out', 'VAmc_Thalamus', 1.0, [p2p 'onetoone'], projState, 'add');

%% %%%%% IT
projState = [];
projState.type = 'demux';
projState.norm = 'none';
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n2_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n3_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 4;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n5_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n6_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n8_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 7;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n9_IT', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 8;
vis = nw_modAddProj(vis, fS, 'ITfb', 'o_V4', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 9;
vis = nw_modAddProj(vis, fS, 'ITfb', 'c_V4', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 10;
vis = nw_modAddProj(vis, fS, 'ITfb', 'Rc_V4', W_B, [p2p 'mux'], projState, 'shunt');

%% %%%%% V4
projState = [];
projState.norm = 'none';
projState.sigma = 3*2;

vis = nw_modAddProj(vis, fS, 'n8_IT', 'o_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n3_IT', 'Rc_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n9_IT', 'o_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n9_IT', 'Rc_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n6_IT', 'o_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n6_IT', 'c_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n5_IT', 'c_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n5_IT', 'Rc_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n2_IT', 'c_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n2_IT', 'Rc_V4', W_B/2, [p2p 'gaussian'], projState, 'shunt');

%% %%%%% V2
projState.sigma = 3;

vis = nw_modAddProj(vis, fS, 'o_V4', 'TR_V2', W_B/4, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'o_V4', 'BR_V2', W_B/4, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'o_V4', 'TL_V2', W_B/4, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'o_V4', 'BL_V2', W_B/4, [p2p 'gaussian'], projState, 'shunt');

vis = nw_modAddProj(vis, fS, 'c_V4', 'TL_V2', W_B/3, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'c_V4', 'BL_V2', W_B/3, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'c_V4', 'H_V2', W_B/8, [p2p 'gaussian'], projState, 'shunt');

vis = nw_modAddProj(vis, fS, 'Rc_V4', 'TR_V2', W_B/3, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'Rc_V4', 'BR_V2', W_B/3, [p2p 'gaussian'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'Rc_V4', 'H_V2', W_B/8, [p2p 'gaussian'], projState, 'shunt');

%% %%%%% Output to LIP

vis = nw_modAddProj(vis, fS, 'BL_V2', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V2', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'TR_V2', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'TL_V2', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'V_V2b', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V2', 'LIP', 1, [p2p 'onetoone'], projState, 'add');


% connect world to model (gabor filters)
% projState = [];
% projState.srcDims = dims;
% projState.srcLocs = locs;
% projState.sigma = 1.0;
% projState.lambda = 3;
% projState.offset = 0;
% projState.aspect = 0.7;
% 
% projState.rotation = 0;
% vis = nw_modAddInput(vis, fS, 'world>retinaImageLum', 'H_V1m', 0.2, [p2p 'gabor'], projState, 'add');
% 
% projState.rotation = 90;
% vis = nw_modAddInput(vis, fS, 'world>retinaImageLum', 'V_V1m', 0.2, [p2p 'gabor'], projState, 'add');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING
%% %%%%% Scopes
if scopeOn==true
    state = [];
    state.scale=[0 1.01];
    state.interval = 20;
    state.colours = 'fire';

    state.dims = dims./2;
    state.zoom = 2 / state.dims(1) * dims(1);
    shiftAm = 600;

    elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope' num2str(i) ''', ''dev/abrg/2008/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) 'm/out>out'', ''scope' num2str(i) '<<mono<in'');']);
    end

%     elements = {'o_V4b' 'Rc_V4b' 'c_V4b'};
%     for i = 1:size(elements,2)
%         state.position = [shiftAm+500 160*(i-1)];
%         state.title = cell2mat(elements(i));
%         eval(['vis = vis.addprocess(''scope2b_' num2str(i) ''', ''dev/abrg/2008/scope'', fS, state);']);
%         eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope2b_' num2str(i) '<<mono<in'');']);
%     end


    state.dims = dims./4;
    state.zoom = 2 / state.dims(1) * dims(1);

    elements = {'o_V4' 'Rc_V4' 'c_V4'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+150 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope2_' num2str(i) ''', ''dev/abrg/2008/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) 'm/out>out'', ''scope2_' num2str(i) '<<mono<in'');']);
    end


    elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+300 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope3_' num2str(i) ''', ''dev/abrg/2008/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope3_' num2str(i) '<<mono<in'');']);
    end

    state.title = 'IT';
    state.position = [100 500];
    state.zoom = 24;
    state.dims = [num_channels 1];
    vis = vis.addprocess('scopeIT', 'dev/abrg/2008/scope', fS, state);
    vis = vis.link('IT/out>out', 'scopeIT<<mono<in');

    state.title = 'LIP';
    state.dims = dims;
    state.zoom = 4 / state.dims(1) * dims(1);
    state.position = [100 700];
    vis = vis.addprocess('scopeLIP', 'dev/abrg/2008/scope', fS, state);
    vis = vis.link('LIP/out>out', 'scopeLIP<<mono<in');


    state = [];
    state.caption = 'FeatMap';
    %state.interval =20/(fS);
    state.location = [8 4 3 2];
    %state.range = [0 1];
    state.colormap = 'hot';
    %vis = vis.addprocess('image', 'dev\std\gui\numeric\image', fS, state);
    %vis = vis.link('o_V4/out>out', 'image');
end

if noise == true
        state = [];	state.dims = uint32(dims); state.dist = 'normal';
		state.pars = [0 0.4];	state.complex = false;
		vis = vis.addprocess('rndH', 'std/2009/random/numeric', fS, state);
		vis = vis.addprocess('rndV', 'std/2009/random/numeric', fS, state);
        
        projState = [];
        projState.srcDims = dims;

        % NOISE
        vis = nw_modAddInput(vis, fS, 'rndH>out', 'H_V1m', 0.5, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndV>out', 'V_V1m', 0.5, [p2p 'onetoone'], projState, 'add');
end      

sys = sys.addsubsystem('vis', vis);