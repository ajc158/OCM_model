
% ORIENTATION VENTRAL STREAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alex Cope 2009 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP
%% %%%%% Model Parameters

layerSide = 150;

dopamine=0.2;
dims = In_dims; %[layerSide layerSide];
locs = In_locs; %{[layerSide layerSide]};
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
actState.sigma_membrane = 0;%MEMB_NOISE;

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
    oFactor = 8;
end

%%%%%% do we jitter the top level reps?
robustFact = 0.0;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%% add neural populations

outFn = 'tanh';
if strcmp(outFn, 'sigmoid')
    outState.c = 0.5;
    outState.m = 12; % Get sigmoid between 0 and 1
end

%vis = nw_modAddPopZD(vis, 'H_V1', fS/10, dims, locs, [p2a 'feedfw'], actState,[p2o outFn], outState);
%vis = nw_modAddPopZD(vis, 'V_V1', fS/10, dims, locs, [p2a 'feedfw'], actState,[p2o outFn], outState);

% automajic creation of populations!
elements = {'H_V1' 'V_V1'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'm'', fS/10, dims, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
end

elements = {'V_V2' 'TL_V2' 'TR_V2' 'BL_V2' 'BR_V2'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'b'', fS/10, dims, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) ''', fS/10, dims, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'm'', fS/10, dims./2, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
end

elements = {'ot_V4' 'ob_V4' 'Rc_V4' 'c_V4'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'b'', fS/10, dims./2, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) ''', fS/10, dims./2, locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'm'', fS/10, round(dims./8), locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
end

elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT' 'o_IT' 'Rc_IT' 'c_IT'};
for i = 1:size(elements,2)
    actState.p = 0.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) 'b'', fS/10, round(dims./8), locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
    actState.p = 1.0;
    eval(['vis = nw_modAddPopZD(vis, ''' cell2mat(elements(i)) ''', fS/10, round(dims./8), locs, [p2a ''feedfw''], actState,[p2o outFn], outState);']);
end

% slope of the output function squashing ...
outState.m = 1;
% ... and offset
outState.c = 0.0;
actState.p = 1.0;
vis = nw_modAddPopZD(vis, 'LIP', fS, layerDims, {[layerLocs(1) layerLocs(2)]}, [p2a 'leaky'], actState,[p2o 'linear'], outState);

%% %%%%%%%%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")
projState = [];
projState.delay = 0;
projState.norm = 'none';
projState.minw = 1e-2;
projState.decimate = 0.0;

%% %%%%%%%%%%%%%%%%% BG

BGloopRobot

%% %%%%%%%%%%%%%%%%%%%% Feedforward connections

offScale = 2.0;

%% %%%%% V2

projState.sigma = 1.0;
projState.offset = [-1.0 0.0].*offScale;
projState.norm = 'affx';
vis = nw_modAddProjMultZD(vis, fS/10, 'H_V1m', {'TR_V2' 'TL_V2'}, W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [1.0 0.0].*offScale;
vis = nw_modAddProjMultZD(vis, fS/10, 'H_V1m', {'BR_V2' 'BL_V2'}, W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [0.0 -1.0].*offScale;
vis = nw_modAddProjMultZD(vis, fS/10, 'V_V1m', {'TL_V2' 'BL_V2'}, W_F/2, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'V_V1m', 'V_V2', W_F/2.2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [0.0 1.0].*offScale;
vis = nw_modAddProjMultZD(vis, fS/10, 'V_V1m', {'TR_V2' 'BR_V2'}, W_F/2, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'V_V1m', 'V_V2', W_F/2.2, [p2p 'gaussianIIR'], projState, 'add');


vis = vis.addprocess('multMaxV2', 'dev/abrg/2009/multMax', fS, {});

vis = vis.link('TR_V2/out>out', 'multMaxV2<i1',0);
vis = vis.link('BL_V2/out>out', 'multMaxV2<i2',0);
vis = vis.link('BR_V2/out>out', 'multMaxV2<i3',0);
vis = vis.link('TL_V2/out>out', 'multMaxV2<i4',0);

projState.radius = 2.0;
projState.srcDims = dims;
projState.srcLocs = locs;

vis = nw_modAddInputZD(vis, fS/10, 'multMaxV2>i1', 'TR_V2m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV2>i2', 'BL_V2m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV2>i3', 'BR_V2m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV2>i4', 'TL_V2m', W_F, [p2p 'discMax'], projState, 'add');

vis = nw_modAddProjZD(vis, fS/10, 'V_V2', 'V_V2m', W_F, [p2p 'discMax'], projState, 'add');



%% %%%%% V4

projState = {};
projState.sigma = 0.2;
V4fact = 0.6;
projState.norm = 'affx';
projState.offset = [4 0].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'TL_V2m', 'ot_V4', W_F/3, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'TL_V2m', 'c_V4', W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [2 -4].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'TR_V2m', 'ot_V4', W_F/3, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'TR_V2m', 'c_V4', W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [-3 1].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'BL_V2m', 'ot_V4', W_F/3, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'BL_V2m', 'Rc_V4', W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [-4 -3].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'BR_V2m', 'ot_V4', W_F/3, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'BR_V2m', 'Rc_V4', W_F/2, [p2p 'gaussianIIR'], projState, 'add');

projState.offset = [4 2].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'TL_V2m', 'ob_V4', W_F/4, [p2p 'gaussianIIR'], projState, 'add');
projState.offset = [2 -2].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'TR_V2m', 'ob_V4', W_F/4, [p2p 'gaussianIIR'], projState, 'add');
projState.offset = [-3 3].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'BL_V2m', 'ob_V4', W_F/4, [p2p 'gaussianIIR'], projState, 'add');
projState.offset = [-4 -1].*V4fact;
vis = nw_modAddProjZD(vis, fS/10, 'BR_V2m', 'ob_V4', W_F/4, [p2p 'gaussianIIR'], projState, 'add');

vis = vis.addprocess('multMaxV4', 'dev/abrg/2009/multMax', fS, {});

vis = vis.link('ot_V4/out>out', 'multMaxV4<i1',0);
vis = vis.link('c_V4/out>out', 'multMaxV4<i2',0);
vis = vis.link('Rc_V4/out>out', 'multMaxV4<i3',0);
vis = vis.link('ob_V4/out>out', 'multMaxV4<i4',0);

projState.radius =  3.1;
projState.srcDims = dims./2;
projState.srcLocs = locs;

vis = nw_modAddInputZD(vis, fS/10, 'multMaxV4>i1', 'ot_V4m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV4>i2', 'c_V4m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV4>i3', 'Rc_V4m', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddInputZD(vis, fS/10, 'multMaxV4>i4', 'ob_V4m', W_F, [p2p 'discMax'], projState, 'add');


%% %%%%% IT
projState = {};
projState.norm = 'affx';

vis = nw_modAddProjZD(vis, fS/10, 'ot_V4m', 'o_IT', W_F*0.38, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'Rc_IT', W_F*0.38, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_V4m', 'c_IT', W_F*0.38, [p2p 'onetoone'], projState, 'add');

projState.sigma = 1;
projState.offset = [5 0];
vis = nw_modAddProjZD(vis, fS/10, 'ot_V4m', 'n8_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'ot_V4m', 'n9_IT', W_F/2, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'n3_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_V4m', 'n6_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_V4m', 'n5_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'n2_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [-5 0];
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'n9_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_V4m', 'n2_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'n5_IT', W_F/2, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'ob_V4m', 'n6_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

projState.offset = [0 0];
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4m', 'n3_IT', W_F/2, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'ob_V4m', 'n8_IT', W_F/2, [p2p 'gaussian'], projState, 'add');

% automajic!
elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
for i = 1:size(elements,2)
%     eval(['vis = nw_modAddProjZD(vis, fS/10, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
%     eval(['vis = nw_modAddProjZD(vis, fS/10, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 4.0;
            projState.norm = 'affx';
            eval(['vis = nw_modAddProj(vis, fS/10, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''gaussianIIR''], projState, ''add'');']);
        end
    end
end

elements = {'o_IT' 'Rc_IT' 'c_IT'};
for i = 1:size(elements,2)
%     eval(['vis = nw_modAddProjZD(vis, fS/10, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
%     eval(['vis = nw_modAddProjZD(vis, fS/10, ''' cell2mat(elements(i)) 'b'',''' cell2mat(elements(i)) ''', W_A, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.sigma = 4.0;
            projState.norm = 'affx';
%             eval(['vis = nw_modAddProjZD(vis, fS/10, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''gaussianIIR''], projState, ''add'');']);
        end
    end
end

%% %%%%% Mux to IT Cortex  

projState.type = 'mux';
projState.position = 2;
vis = nw_modAddProjZD(vis, fS/10, 'n2_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProjZD(vis, fS/10, 'n3_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 4;
vis = nw_modAddProjZD(vis, fS/10, 'n5_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 5;
vis = nw_modAddProjZD(vis, fS/10, 'n6_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 6;
vis = nw_modAddProjZD(vis, fS/10, 'n8_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 7;
vis = nw_modAddProjZD(vis, fS/10, 'n9_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 8;
vis = nw_modAddProjZD(vis, fS/10, 'o_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 9;
vis = nw_modAddProjZD(vis, fS/10, 'c_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 10;
vis = nw_modAddProjZD(vis, fS/10, 'Rc_IT', 'IT', W_F, [p2p 'muxMax'], projState, 'add');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Feedback Connections
% build BRAHMS process to represent source
state = [];
state.data = data;
state.repeat = true;
state.ndims = 1;
vis = vis.addprocess('src', 'std/2009/source/numeric', fS/10, state);
projState = [];
projState.srcDims = bgdims;
vis = nw_modAddInput(vis, fS/10, 'src>out', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddInput(vis, fS/10, 'src>out', 'VAmc_Thalamus', 0.5, [p2p 'onetoone'], projState, 'add');


%% %%%%% IT
projState = [];
projState.type = 'demux';
projState.norm = 'none';
projState.position = 2;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n2_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 3;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n3_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 4;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n5_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 5;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n6_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 6;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n8_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 7;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'n9_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 8;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'o_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 9;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'c_ITb', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 10;
vis = nw_modAddProjZD(vis, fS/10, 'ITfb', 'Rc_ITb', W_B, [p2p 'mux'], projState, 'shunt');

projState = [];
projState.sigma = 3*6;
projState.norm = 'none';

% vis = nw_modAddProjZD(vis, fS/10, 'n2_IT', 'n2_ITb', 1, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProjZD(vis, fS/10, 'n3_IT', 'n3_ITb', 1, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProjZD(vis, fS/10, 'n5_IT', 'n5_ITb', 1, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProjZD(vis, fS/10, 'n6_IT', 'n6_ITb', 1, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProjZD(vis, fS/10, 'n8_IT', 'n8_ITb', 1, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProjZD(vis, fS/10, 'n9_IT', 'n9_ITb', 1, [p2p 'onetoone'], projState, 'add');

vis = vis.addprocess('multMax', 'dev/abrg/2009/multMax', fS, {});

% vis = vis.link('n2_IT/out>out', 'multMax<i1',0);
% vis = vis.link('n3_IT/out>out', 'multMax<i2',0);
vis = vis.link('n5_IT/out>out', 'multMax<i3',0);
vis = vis.link('n6_IT/out>out', 'multMax<i4',0);
% vis = vis.link('n8_IT/out>out', 'multMax<i5',0);
vis = vis.link('n9_IT/out>out', 'multMax<i6',0);

% vis = vis.link('multMax>i1', 'n2_ITb/act<add',0);
% vis = vis.link('multMax>i2', 'n3_ITb/act<add',0);
vis = vis.link('multMax>i3', 'n5_ITb/act<add',0);
vis = vis.link('multMax>i4', 'n6_ITb/act<add',0);
% vis = vis.link('multMax>i5', 'n8_ITb/act<add',0);
vis = vis.link('multMax>i6', 'n9_ITb/act<add',0);


vis = nw_modAddProjZD(vis, fS/10, 'o_IT', 'o_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_IT', 'Rc_ITb', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_IT', 'c_ITb', 1, [p2p 'onetoone'], projState, 'add');

%% %%%%% V4
vis = nw_modAddProjZD(vis, fS/10, 'Rc_V4', 'Rc_V4b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'c_V4', 'c_V4b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'ot_V4', 'ot_V4b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'ob_V4', 'ob_V4b', 1, [p2p 'onetoone'], projState, 'add');

projState = [];
projState.norm = 'none';
projState.radius = 4;
 
vis = nw_modAddProjZD(vis, fS/10, 'n8_ITb', 'ot_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjZD(vis, fS/10, 'n3_ITb', 'Rc_V4b', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjMultZD(vis, fS/10, 'n9_ITb', {'ot_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjMultZD(vis, fS/10, 'n6_ITb', {'ob_V4b' 'c_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjMultZD(vis, fS/10, 'n5_ITb', {'c_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjMultZD(vis, fS/10, 'n2_ITb', {'c_V4b' 'Rc_V4b'}, W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProjZD(vis, fS/10, 'o_ITb', 'ot_V4b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjZD(vis, fS/10, 'Rc_ITb', 'Rc_V4b', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProjZD(vis, fS/10, 'c_ITb', 'c_V4b', W_B, [p2p 'discMax'], projState, 'shunt');

%% %%%%% V2

vis = nw_modAddProjZD(vis, fS/10, 'TR_V2', 'TR_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'TL_V2', 'TL_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'BR_V2', 'BR_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'BL_V2', 'BL_V2b', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProjZD(vis, fS/10, 'V_V2', 'V_V2b', 1, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddProjZD(vis, fS/10, 'V_V2', 'V_V2b', 1, [p2p 'onetoone'], projState, 'add');

projState.radius = 8;
if cal == false
    vis = nw_modAddProjMultZD(vis, fS/10, 'ot_V4b', {'TR_V2b' 'BR_V2b' 'TL_V2b' 'BL_V2b'}, W_B/4, [p2p 'discMax'], projState, 'shunt');

    vis = nw_modAddProjMultZD(vis, fS/10, 'ob_V4b', {'TR_V2b' 'BR_V2b' 'TL_V2b' 'BL_V2b'}, W_B/4, [p2p 'discMax'], projState, 'shunt');

    vis = nw_modAddProjMultZD(vis, fS/10, 'c_V4b', {'TL_V2b' 'BL_V2b' 'V_V2b'}, W_B/3, [p2p 'discMax'], projState, 'shunt');

    vis = nw_modAddProjMultZD(vis, fS/10, 'Rc_V4b', {'TR_V2b' 'BR_V2b' 'V_V2b'}, W_B/3, [p2p 'discMax'], projState, 'shunt');
end
%% %%%%% Output to LIP

vis = vis.addprocess('visResampOut', 'std/2009/resample/numeric', fS, {});
vis = vis.addprocess('visOutSum', 'std/2009/math/esum', fS/10, {});

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
out_layer_size = layerDims(1);

projState.hack = 0.6;% maps the LP conversion onto a hackth of the visual field!

projState.E_2 = 2.5/degrees_to_edgeS*(in_layer_size);
projState.M_f = out_layer_size/(projState.E_2*log(1+(in_layer_size/projState.E_2)));
vis = vis.addprocess('convProj', [p2p 'IIRLPconv'], fS/10, projState);

vis = vis.link('visOutSum>out', 'convProj<in',0);
vis = vis.link('convProj>out', 'visResampOut',0);

vis = vis.link('visResampOut>out', 'LIP/act<add',0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINISHING
%% %%%%% Scopes
if scopeOn==true
    state = [];
    state.scale=[0 1.0];
    state.interval = 0;
    state.colours = 'fire';

    state.dims = dims;
    state.zoom = 4 / state.dims(1) * dims(1);
    shiftAm = 600;

    elements = {'V_V2' 'TR_V2' 'TL_V2' 'BR_V2' 'BL_V2'};
    
    elements = {'multMaxV2>i1' 'multMaxV2>i2' 'multMaxV2>i3' 'multMaxV2>i4' 'V_V2/out>out'};
%     elements = {'H_V1m' 'V_V1m'};
    for i = 1:size(elements,2)
        state.position = [shiftAm 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope' num2str(i) ''', ''dev/abrg/2009/scope'', fS/10, state);']);
       % eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope' num2str(i) '<<mono<in'');']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) ''', ''scope' num2str(i) '<<mono<in'');']);
    end
    state.dims = dims./2;
     state.zoom = 4 / state.dims(1) * dims(1);
     
     
    elements = {'ot_V4' 'Rc_V4' 'c_V4' 'ob_V4'};
    
    elements = {'multMaxV4>i1' 'multMaxV4>i2' 'multMaxV4>i3' 'multMaxV4>i4'};
    for i = 1:size(elements,2)
        state.position = [shiftAm+500 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope2b_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/10, state);']);
%         eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope2b_' num2str(i) '<<mono<in'');']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) ''', ''scope2b_' num2str(i) '<<mono<in'');']);
    end


    state.dims = dims./8;
    state.zoom = 4 / state.dims(1) * dims(1);

%     elements = {'o_IT' 'Rc_IT' 'c_IT'};
%     for i = 1:size(elements,2)
%         state.position = [shiftAm+150 160*(i-1)];
%         state.title = cell2mat(elements(i));
%         eval(['vis = vis.addprocess(''scope2_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/10, state);']);
%         eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope2_' num2str(i) '<<mono<in'');']);
%     end


    elements = {'n2_IT' 'n3_IT' 'n5_IT' 'n6_IT' 'n8_IT' 'n9_IT'};
%     elements = { 'o_V4m' 'c_V4m' 'Rc_V4m'};

    for i = 1:size(elements,2)
        state.position = [shiftAm+300 160*(i-1)];
        state.title = cell2mat(elements(i));
        eval(['vis = vis.addprocess(''scope3_' num2str(i) ''', ''dev/abrg/2009/scope'', fS/10, state);']);
        eval(['vis = vis.link(''' cell2mat(elements(i)) '/out>out'', ''scope3_' num2str(i) '<<mono<in'');']);
    end

    state.title = 'IT';
    state.position = [100 500];
    state.zoom = 24;
    state.dims = [num_channels 1];
    vis = vis.addprocess('scopeIT', 'dev/abrg/2009/scope', fS/10, state);
    vis = vis.link('ITfb/out>out', 'scopeIT<<mono<in');

%     state.title = 'LIP';
%     state.dims = layerDims;
%     state.zoom = 4 / state.dims(1) * dims(1);
%     state.position = [100 700];
%     vis = vis.addprocess('scopeLIP', 'dev/abrg/2009/scope', fS/10, state);
%     vis = vis.link('LIP/out>out', 'scopeLIP<<mono<in');


    state = [];
    state.caption = 'FeatMap';
    %state.interval =20/(fS);
    state.location = [8 4 3 2];
    %state.range = [0 1];
    state.colormap = 'hot';
    %vis = vis.addprocess('image', 'dev\std\gui\numeric\image', fS/10, state);
    %vis = vis.link('o_V4/out>out', 'image');
end

% if noise == true
%         state = [];	state.dims = uint32(dims); state.dist = 'normal';
% 		state.pars = [0.1 0.3];	state.complex = false;
% 		vis = vis.addprocess('rndH', 'std/2009/random/numeric', fS/10, state);
% 		vis = vis.addprocess('rndV', 'std/2009/random/numeric', fS/10, state);
%         
%         projState = [];
%         projState.srcDims = dims;
% 
%         % NOISE
%         vis = nw_modAddInput(vis, fS/10, 'rndH>out', 'H_V1m', 1.0, [p2p 'onetoone'], projState, 'add');
%         vis = nw_modAddInput(vis, fS/10, 'rndV>out', 'V_V1m', 1.0, [p2p 'onetoone'], projState, 'add');
% end      

sys = sys.addsubsystem('vis', vis);