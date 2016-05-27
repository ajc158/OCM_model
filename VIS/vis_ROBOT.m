
% ORIENTATION ROBOT VENTRAL STREAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2010 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 0.1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters

dims = ret_dims; %[layerSide layerSide];
locs = ret_locs; %{[layerSide layerSide]};
bgdims = num_channels;
bglocs = num_channels;
 
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
actState.sigma_membrane =  MEMB_NOISE;

outState = [];
% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
% hard limits at 0 and 1:
outState.limits = 2;


%%%%%%%%%% ACCOUNT FOR SCALING

off_fact = 1.0*ret_dims(1)/In_dims(1);

%% %%%%%%%%%%%%%%%%% BG

BGloop


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outFn = 'tanh';
if strcmp(outFn, 'sigmoid')
    outState.c = 0.5;
    outState.m = 12; % Get sigmoid between 0 and 1
end
outState.c = 0.0;
% actState.sigma_membrane = BACKGROUND_NOISE;
vis = nw_modAddPop(vis, 'H_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
vis = nw_modAddPop(vis, 'V_V1m', fS, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
outState.c = 0.0;

elements = {'BL_V2' 'TR_V2' 'LM_V2' 'RM_V2'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS, dims, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'y_V4' 'h_V4' 'BL_V4' 'TR_V4'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS, dims./12, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'n5_IT' 'n6_IT' 'n9_IT'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS, dims./12, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./12, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
actState.sigma_membrane = BACKGROUND_NOISE;
vis = nw_modAddPop(vis, 'LIP', fS, dims, {[layerLocs(1) layerLocs(2)]}, [p2a 'leaky'], actState,[p2o 'linear'], outState);

%% %%%%%%%%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")
projState = [];
projState.delay = 0;
projState.norm = 'affx';
projState.minw = 1e-2;
projState.decimate = 0.0;

in_layer_size = In_dims(1)/2;
out_layer_size = ret_dims(1);

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

%% %%%%%%%%%%%%%%%%%%%% Feedforward connections

%% %%%%% V2

%projState.sigma = 1; normF = 0.16;
projState.sigma = 1.0; normF = 1;

projState.offset = [2.0 0.0].*off_fact;
projState.norm = 'aff';
vis = nw_modAddProj(vis, fS, 'V_V1m', 'RM_V2', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-2.0 0.0].*off_fact;
projState.norm = 'aff';
vis = nw_modAddProj(vis, fS, 'V_V1m', 'LM_V2', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [0.0 0.0].*off_fact;
vis = nw_modAddProjMult(vis, fS, 'V_V1m', {'TR_V2' 'BL_V2'}, normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProjMult(vis, fS, 'V_V1m', {'RM_V2' 'LM_V2'}, normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [1.0 1.0].*off_fact;
vis = nw_modAddProj(vis, fS, 'H_V1m', 'TR_V2', normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'RM_V2', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-1.0 -1.0].*off_fact;
vis = nw_modAddProj(vis, fS, 'H_V1m', 'BL_V2', normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'H_V1m', 'LM_V2', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');

% automajic!
elements = {'BL_V2' 'TR_V2' 'LM_V2' 'RM_V2'};
projState.radius = 1.5;
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'b'', 1, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% V4

in_layer_size = In_dims(1)/2;
out_layer_size = ret_dims(1) / 2;

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

projState.sigma = 0.2;
projState.norm = 'aff';

normF = 2;

projState.offset = [1.0 1.0].*off_fact;
% vis = nw_modAddProj(vis, fS, 'BL_V2m', 'h_V4', normF*W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BL_V2m', 'BL_V4', normF*W_F, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'LM_V2m', 'h_V4', normF*W_F, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-1.0 -1.0].*off_fact;
% vis = nw_modAddProj(vis, fS, 'TR_V2m', 'y_V4', normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'TR_V2m', 'TR_V4', normF* W_F, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'RM_V2m', 'y_V4', normF* W_F, [p2p 'gaussianLPF'], projState, 'add');


% automajic!
elements = {'y_V4' 'h_V4' 'BL_V4' 'TR_V4'};
projState.radius = 4;%2.1
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'b'', 1, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 0.5;
            projState.norm = 'affx';
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I*0.5, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% IT

in_layer_size = In_dims(1)/2;
out_layer_size = ret_dims(1) / 12;

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

projState.sigma = 40.9;

projState.norm = 'aff';
normF = 1;
projState.offset = [-2.0 -2.0].*off_fact;
vis = nw_modAddProj(vis, fS, 'y_V4m', 'n9_IT', W_F*normF, [p2p 'gaussianLP'], projState, 'add');
projState.offset = [2.0 2.0].*off_fact;
vis = nw_modAddProj(vis, fS, 'h_V4m', 'n6_IT', W_F*normF, [p2p 'gaussianLP'], projState, 'add');

vis = nw_modAddProjMult(vis, fS, 'TR_V4m', {'n5_IT'}, W_F/2.1*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProjMult(vis, fS, 'BL_V4m', {'n5_IT'}, W_F/2.1*normF, [p2p 'gaussianLP'], projState, 'add');


% automajic!
elements = {'n5_IT' 'n6_IT' 'n9_IT'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'b'', 1, [p2p ''onetoone''], projState, ''add'');']);
   for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 3.0;
            projState.norm = 'aff';
            normF = 0.01;
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% Mux to IT Cortex

projState.norm = 'none';
projState.type = 'mux';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'n5_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'n6_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'n9_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Feedback Connections
% build BRAHMS process to represent source
state = [];
state.data = data;
state.repeat = true;
state.ndims = 1;
vis = vis.addprocess('src', 'std/2009/source/numeric', fS, state);
projState = [];
projState.srcDims = bgdims;
vis = nw_modAddInput(vis, fS, 'src>out', 'ITfb', W_B, [p2p 'onetoone'], projState, 'shunt');
vis = nw_modAddInput(vis, fS, 'src>out', 'VAmc_Thalamus', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'IT', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');


%% %%%%% IT
projState = [];
projState.type = 'demux';
projState.norm = 'none';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n5_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n6_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'ITfb', 'n9_ITb', W_B, [p2p 'mux'], projState, 'shunt');


%% %%%%% V4
projState = [];
projState.norm = 'none';
projState.sigma = 1;
projState.edge_compensation = 'wrapV';
projState.radius = 20;

vis = nw_modAddProj(vis, fS, 'n5_ITb', 'TR_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n5_ITb', 'BL_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n6_ITb', 'h_V4b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'n9_ITb', 'y_V4b', W_B, [p2p 'discMax'], projState, 'shunt');

%% %%%%% V2
projState.sigma = 2;
projState.radius = 8;

vis = nw_modAddProjMult(vis, fS, 'h_V4b', {'BL_V2b' 'LM_V2b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS, 'y_V4b', {'TR_V2b' 'RM_V2b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProj(vis, fS, 'TR_V4b', 'TR_V2b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'BL_V4b', 'BL_V2b', W_B, [p2p 'discMax'], projState, 'shunt');



%% %%%%% Output to LIP

vis = nw_modAddProj(vis, fS, 'TR_V2b', 'LIP', 0.4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BL_V2b', 'LIP', 0.4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'RM_V2b', 'LIP', 0.4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'LM_V2b', 'LIP', 0.4, [p2p 'onetoone'], projState, 'add');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING

if scopeOn==true
    state = [];
    state.scale=[0 1.01];
    state.interval = 1;
    state.colours = 'fire';

    state.dims = dims;
    state.zoom = 2 / state.dims(1) * dims(1);
    shiftAm = 600;
    
     elements = {'H_V1m' 'V_V1m' 'TR_V2' 'BL_V2' 'RM_V2' 'LM_V2'};
      %elements = {'H_V1m' 'V_V1m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 200*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope' num2str(i) ''', ''dev/abrg/2009/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope' num2str(i) '<<mono<in'');']);
    end
    
        state.dims = dims./2;
    state.zoom = 2 / state.dims(1) * dims(1);
    shiftAm = 200;
    
     elements = {'y_V4' 'TR_V4' 'BL_V4' 'h_V4' 'TR_V2m' 'BL_V2m'};
      %elements = {'H_V1m' 'V_V1m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 200*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scopev4' num2str(i) ''', ''dev/abrg/2009/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scopev4' num2str(i) '<<mono<in'');']);
    end
    
    state.dims = dims./12;
    state.zoom = 2 / state.dims(1) * dims(1);
    shiftAm = 0;
    
     elements = {'n5_IT' 'n6_IT' 'n9_IT'};
      %elements = {'H_V1m' 'V_V1m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 200*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scopeIT' num2str(i) ''', ''dev/abrg/2009/scope'', fS, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scopeIT' num2str(i) '<<mono<in'');']);
    end
end

sys = sys.addsubsystem('vis', vis);