
% ORIENTATION VENTRAL STREAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2008 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters

dopamine=DOPAMINE;
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
actState.tau_membrane = 0.0;
% We want eqm. = input do p = 1
actState.p = 1;
% No noise on the membrane
actState.sigma_membrane =  0;%MEMB_NOISE;

outState = [];
% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
% hard limits at 0 and 1:
outState.limits = 2;


%%%%%%%%%% ACCOUNT FOR SCALING

off_fact = 2.0*ret_dims(1)/In_dims(1);



%%%%%% do we jitter the top level reps?
robustFact = 0.0;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outFn = 'tanh';
if strcmp(outFn, 'sigmoid')
    outState.c = 0.5;
    outState.m = 12; % Get sigmoid between 0 and 1
end
outState.c = 0.05;
% actState.sigma_membrane = BACKGROUND_NOISE;
vis = nw_modAddPop(vis, 'H_V1m', fS/20, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
vis = nw_modAddPop(vis, 'V_V1m', fS/20, dims, locs, [p2a 'leaky'], actState,[p2o outFn], outState);
outState.c = 0.0;

% actState.sigma_membrane = 0.0;
% automajic creation of populations!
elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS/20, dims, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS/20, dims, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS/20, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'o_V4' 'Rc_V4' 'c_V4'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS/20, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS/20, dims./2, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'm'', fS/20, dims./25, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
end

elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT' 'o_IT' 'c_IT' 'Rc_IT'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) 'b'', fS/20, dims./25, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS/20, dims./25, locs, [p2a ''leaky''], actState,[p2o outFn], outState);']);
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

%% %%%%%%%%%%%%%%%%% BG

BGloopRobot

%% %%%%%%%%%%%%%%%%%%%% Feedforward connections

%% %%%%% V2

%projState.sigma = 1; normF = 0.16;
projState.sigma = 0.7; normF = 1;

projState.offset = [1.0 0.0].*off_fact;
projState.norm = 'aff';
vis = nw_modAddProjMult(vis, fS/20, 'V_V1m', {'BR_V2' 'BL_V2'}, normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-1.0 0.0].*off_fact;
vis = nw_modAddProjMult(vis, fS/20, 'V_V1m', {'TR_V2' 'TL_V2'}, normF* W_F/2, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [0.0 -1.0].*off_fact;
vis = nw_modAddProjMult(vis, fS/20, 'H_V1m', {'TL_V2' 'BL_V2'},  normF*W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'H_V1m', 'H_V2', normF* W_F/1.5, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [0.0 1.0].*off_fact;
vis = nw_modAddProjMult(vis, fS/20, 'H_V1m', {'TR_V2' 'BR_V2'},  normF*W_F/2, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'H_V1m', 'H_V2',  normF*W_F/1.5, [p2p 'gaussianLPF'], projState, 'add');

% automajic!
elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
projState.radius = 1.5;
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% V4

in_layer_size = In_dims(1)/2;
out_layer_size = ret_dims(1) / 2;

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

projState.sigma = 4.2;
projState.norm = 'aff';

normF = 3;
oFactor = 3.4;

projState.offset = [1.0 1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'TL_V2m', 'o_V4', normF*W_F/oFactor, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'TL_V2m', 'c_V4', normF*W_F/3, [p2p 'gaussianLPF'], projState, 'add');
projState.offset = [1.0 1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'H_V2m', 'Rc_V4', normF* W_F/8, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-1 1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'BL_V2m', 'o_V4', normF* W_F/oFactor, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'BL_V2m', 'c_V4', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');
projState.offset = [-1.0 1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'H_V2m', 'Rc_V4',  normF*W_F/8, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [1.0 -1].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'TR_V2m', 'o_V4',  normF*W_F/oFactor, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'TR_V2m', 'Rc_V4', normF* W_F/3, [p2p 'gaussianLPF'], projState, 'add');
projState.offset = [1.0 -1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'H_V2m', 'c_V4',  normF*W_F/8, [p2p 'gaussianLPF'], projState, 'add');

projState.offset = [-1.0 -1].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'BR_V2m', 'o_V4',  normF*W_F/oFactor, [p2p 'gaussianLPF'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'BR_V2m', 'Rc_V4',  normF*W_F/3, [p2p 'gaussianLPF'], projState, 'add');
projState.offset = [-1.0 -1.0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'H_V2m', 'c_V4',  normF*W_F/8, [p2p 'gaussianLPF'], projState, 'add');


% automajic!
elements = {'o_V4' 'Rc_V4' 'c_V4'};
projState.radius = 10;%2.1
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'm'', W_F, [p2p ''discMax''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 0.5;
            projState.norm = 'affx';
            eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% IT

in_layer_size = In_dims(1)/2;
out_layer_size = ret_dims(1) / 25;

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));

projState.sigma = 20.9;
projState.offset = [0.0 0].*off_fact;
projState.norm = 'aff';
normF = 1;
vis = nw_modAddProjMult(vis, fS/20, 'o_V4m', {'n8_IT' 'n9_IT'}, W_F/2 *normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProjMult(vis, fS/20, 'Rc_V4m', {'n3_IT' 'n2_IT'}, W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProjMult(vis, fS/20, 'c_V4m', {'n6_IT' 'n5_IT'}, W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');

vis = nw_modAddProj(vis, fS/20, 'o_V4m', 'o_IT', W_F, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'Rc_V4m', 'Rc_IT', W_F, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'c_V4m', 'c_IT', W_F, [p2p 'onetoone'], projState, 'add');

projState.offset = [0 0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'Rc_V4m', 'n9_IT', W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'c_V4m', 'n2_IT', W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'Rc_V4m', 'n5_IT', W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'o_V4m', 'n6_IT', W_F/2*normF, [p2p 'gaussianLP'], projState, 'add');

 projState.offset = [0.0 0].*off_fact;
vis = nw_modAddProj(vis, fS/20, 'Rc_V4m', 'n3_IT', W_F/4*normF, [p2p 'gaussianLP'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'o_V4m', 'n8_IT', W_F/4*normF, [p2p 'gaussianLP'], projState, 'add');

% automajic!
elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 4.0;
            projState.norm = 'none';
            normF = 0.01;
            eval(['vis = nw_modAddProj(vis, fS/20, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

%% %%%%% Mux to IT Cortex

projState.norm = 'none';
projState.type = 'mux';
projState.position = 2;
vis = nw_modAddProj(vis, fS/20, 'n2_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS/20, 'n3_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 4;
vis = nw_modAddProj(vis, fS/20, 'n5_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 5;
vis = nw_modAddProj(vis, fS/20, 'n6_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 6;
vis = nw_modAddProj(vis, fS/20, 'n8_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 7;
vis = nw_modAddProj(vis, fS/20, 'n9_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 8;
vis = nw_modAddProj(vis, fS/20, 'o_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 9;
vis = nw_modAddProj(vis, fS/20, 'c_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 10;
vis = nw_modAddProj(vis, fS/20, 'Rc_V4m', 'IT', W_F, [p2p 'muxMax'], projState, 'add');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Feedback Connections
% build BRAHMS process to represent source
state = [];
state.data = data;
state.repeat = true;
state.ndims = 1;
vis = vis.addprocess('src', 'std/2009/source/numeric', fS/20, state);
projState = [];
projState.srcDims = bgdims;
vis = nw_modAddInput(vis, fS/20, 'src>out', 'ITfb', W_B, [p2p 'onetoone'], projState, 'shunt');
vis = nw_modAddInput(vis, fS/20, 'src>out', 'VAmc_Thalamus', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'IT', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');


%% %%%%% IT
projState = [];
projState.type = 'demux';
projState.norm = 'none';
projState.position = 2;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n2_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 3;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n3_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 4;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n5_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 5;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n6_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 6;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n8_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 7;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'n9_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 8;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'o_ITb', W_B/2, [p2p 'mux'], projState, 'shunt');
projState.position = 9;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'c_ITb', W_B/2, [p2p 'mux'], projState, 'shunt');
projState.position = 10;
vis = nw_modAddProj(vis, fS/20, 'ITfb', 'Rc_ITb', W_B/2, [p2p 'mux'], projState, 'shunt');

projState = [];
projState.norm = 'none';

vis = nw_modAddProj(vis, fS/20, 'n2_IT', 'n2_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'n3_IT', 'n3_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'n5_IT', 'n5_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'n6_IT', 'n6_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'n8_IT', 'n8_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'n9_IT', 'n9_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'o_IT', 'o_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'Rc_IT', 'Rc_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'c_IT', 'c_ITb', 1, [p2p 'onetoone'], projState, 'add');

%% %%%%% V4
vis = nw_modAddProj(vis, fS/20, 'Rc_V4', 'Rc_V4b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'c_V4', 'c_V4b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'o_V4', 'o_V4b', 1, [p2p 'onetoone'], projState, 'add');

projState = [];
projState.norm = 'none';
projState.sigma = 1;
projState.edge_compensation = 'wrapV';
projState.radius = 20;

vis = nw_modAddProj(vis, fS/20, 'n8_ITb', 'o_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS/20, 'n3_ITb', 'Rc_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'n9_ITb', {'o_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'n6_ITb', {'o_V4b' 'c_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'n5_ITb', {'c_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'n2_ITb', {'c_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProj(vis, fS/20, 'Rc_ITb', 'Rc_V4b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS/20, 'c_ITb', 'c_V4b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS/20, 'o_ITb', 'o_V4b', W_B, [p2p 'discMax'], projState, 'shunt');

%% %%%%% V2

vis = nw_modAddProj(vis, fS/20, 'TR_V2', 'TR_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'TL_V2', 'TL_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'BR_V2', 'BR_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'BL_V2', 'BL_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS/20, 'H_V2', 'H_V2b', 1, [p2p 'onetoone'], projState, 'add');

projState.sigma = 2;
projState.radius = 8;

vis = nw_modAddProjMult(vis, fS/20, 'o_V4b', {'TR_V2b' 'BR_V2b' 'TL_V2b' 'BL_V2b'}, W_B/4, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'c_V4b', {'TL_V2b' 'BL_V2b'}, W_B/3, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS/20, 'c_V4b', 'H_V2b', W_B/8, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjMult(vis, fS/20, 'Rc_V4b', {'TR_V2b' 'BR_V2b'}, W_B/3, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS/20, 'Rc_V4b', 'H_V2b', W_B/8, [p2p 'discMax'], projState, 'shunt');

%% %%%%% Output to LIP

vis = vis.addprocess('visResampOut', 'std/2009/resample/numeric', fS, {});
vis = vis.addprocess('visOutSum', 'std/2009/math/esum', fS/20, {});

vis = vis.link('BL_V2b/out>out', 'visOutSum',0);
vis = vis.link('BR_V2b/out>out', 'visOutSum',0);
vis = vis.link('TR_V2b/out>out', 'visOutSum',0);
vis = vis.link('TL_V2b/out>out', 'visOutSum',0);
vis = vis.link('BL_V2b/out>out', 'visOutSum',0);

projState = [];
projState.srcDims = In_dims;
projState.srcLocs = In_locs;
projState.norm = 'aff';
projState.sigma = 2.0;
projState.weight = 1;
projState.dstDims = layerDims;
projState.dstLocs = layerLocs;

in_layer_size = In_dims(1)/2;
out_layer_size = layerLocs(1);

projState.E_2 = 2.5/degrees_to_edge*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));
vis = vis.addprocess('convProj', [p2p 'IIRLPconv'], fS, projState);

vis = vis.link('visOutSum>out', 'convProj<in',0);
vis = vis.link('convProj>out', 'visResampOut',0);

vis = vis.link('visResampOut>out', 'LIP/act<add',0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING
%% %%%%% Scopes
if scopeOn==true
    state = [];
    state.scale=[0 1.01];
    state.interval = 0;
    state.colours = 'fire';

    state.dims = dims;
    state.zoom = 2 / state.dims(1) * dims(1);
    shiftAm = 600;
    
 

    elements = {'H_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
      %elements = {'H_V1m' 'V_V1m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 200*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope' num2str(i) ''', ''dev/abrg/2009/scope'', fS/20, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope' num2str(i) '<<mono<in'');']);
    end
    
    state.dims = dims./25;
    state.zoom = 1 / state.dims(1) * dims(1);
        
    elements = {'o_V4m' 'Rc_V4m' 'c_V4m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+500 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope2b_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/20, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope2b_' num2str(i) '<<mono<in'');']);
    end


    state.dims = dims./2;
    state.zoom = 1 / state.dims(1) * dims(1);

    elements = {'o_V4' 'Rc_V4' 'c_V4'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+150 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope2_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/20, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope2_' num2str(i) '<<mono<in'');']);
    end

    state.dims = dims./25;
    state.zoom = 1 / state.dims(1) * dims(1);
    
    elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+300 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope3_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/20, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope3_' num2str(i) '<<mono<in'');']);
    end

    state.title = 'IT';
    state.position = [100 500];
    state.zoom = 24;
    state.dims = [num_channels 1];
    vis = vis.addprocess('scopeIT', 'dev/abrg/2009/scope', fS/20, state);
    vis = vis.link('ITfb/out>out', 'scopeIT<<mono<in');

    state.title = 'LIP';
    state.dims = dims;
    state.zoom = 2 / state.dims(1) * dims(1);
    state.position = [100 700];
    vis = vis.addprocess('scopeLIP', 'dev/abrg/2009/scope', fS/20, state);
    vis = vis.link('LIP/out>out', 'scopeLIP<<mono<in');


    state = [];
    state.caption = 'FeatMap';
    %state.interval =20/(fS);
    state.location = [8 4 3 2];
    %state.range = [0 1];
    state.colormap = 'hot';
    %vis = vis.addprocess('image', 'dev\std\gui\numeric\image', fS/20, state);
    %vis = vis.link('o_V4/out>out', 'image');
end

% if noise == true
%         state = [];	state.dims = uint32(dims); state.dist = 'normal';
% 		state.pars = [0.1 0.3];	state.complex = false;
% 		vis = vis.addprocess('rndH', 'std/2009/random/numeric', fS/20, state);
% 		vis = vis.addprocess('rndV', 'std/2009/random/numeric', fS/20, state);
%         
%         projState = [];
%         projState.srcDims = dims;
% 
%         % NOISE
%         vis = nw_modAddInput(vis, fS/20, 'rndH>out', 'H_V1m', 1.0, [p2p 'onetoone'], projState, 'add');
%         vis = nw_modAddInput(vis, fS/20, 'rndV>out', 'V_V1m', 1.0, [p2p 'onetoone'], projState, 'add');
% end      

sys = sys.addsubsystem('vis', vis);