
inter = 10;

outFnType = 'tanh';

dopamine=DOPAMINE;

dims = ret_dims;
locs = ret_locs;


W_F = FEEDFORWARD_WEIGHT_GATING;
W_B = FEEDBACK_WEIGHT_GATING;
W_R = RECIPROCAL_WEIGHT_GATING;
W_I = FEATURE_INHIBITION_GATING;


vis = sml_system();
%%%%%%%%%%%%%%%%%%%%%%%%%% construct network 
%vis = nw_new('lin', 'sys');

%%%%%%%%%% set up standard parameters (see "help sub_nw_node_lin")
actState = [];
actState.tau_membrane = single(0.01);
actState.p = 1;
actState.sigma_membrane =  MEMB_NOISE;

outState = [];
outState.m = 1;
outState.limits = 2;

%%%%%%%%%%%%%%%%%%%%%% add neural populations

bgdims = [10];
bglocs = {[10]};


elements = {'R_V1' 'G_V1' 'B_V1' 'W_V1'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims, locs, [p2a ''leaky''], actState,[p2o outFnType], outState);']);
end


actState.p=0.0;
elements = {'R_V1o' 'G_V1o' 'B_V1o'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims, locs, [p2a ''leaky''], actState,[p2o outFnType], outState);']);
end
actState.p=1;


elements = {'R_V2' 'G_V2' 'B_V2' 'RG_V4' 'GB_V4' 'BR_V4' 'R_V4' 'G_V4' 'B_V4'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFnType], outState);']);
end

actState.p=0.0;
elements = {'RG_V4o' 'GB_V4o' 'BR_V4o' 'R_V4o' 'G_V4o' 'B_V4o'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddPop(vis, ''' cell2mat(elements(i)) ''', fS, dims./2, locs, [p2a ''leaky''], actState,[p2o outFnType], outState);']);
end
actState.p=1;

vis = nw_modAddPop(vis, 'W_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o outFnType], outState);

vis = nw_modAddPop(vis, 'LIP', fS, dims, {[layerLocs]}, [p2a 'leaky'], actState,[p2o, 'linear'], outState);

vis = nw_modAddPop(vis, 'comb_V4', fS, bgdims, bglocs, [p2a 'leaky'], actState,[p2o outFnType], outState);

%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")
projState = [];
projState.delay = 0;
projState.norm = 'none';
projState.type = 'gaussian';
projState.minw = 1e-2;
projState.decimate = 0.0;

BGloop


% Feedforward connections

projState.radius = 2.0;
projState.norm = 'none';

vis = nw_modAddProj(vis, fS, 'R_V1', 'R_V2', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'G_V2', W_F, [p2p 'discMax'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'B_V2', W_F, [p2p 'discMax'], projState, 'add');

projState.sigma = 3.2;%1.5
projState.lambda = 6;%projState.sigma * 0.5357;
projState.offset = 0;
projState.aspect = 0.7;%0.6

W_fact = 0.6;

projState.rotation = 45;

vis = nw_modAddProj(vis, fS, 'G_V2', 'RG_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'GB_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'BR_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V2', 'W_V4', W_F*W_fact*1.3/2, [p2p 'gaborNot'], projState, 'add');
% vis = nw_modAddProj(vis, fS, 'B_V2', 'W_V4', W_F*W_fact/2, [p2p 'gaborNot'], projState, 'add');

projState.rotation = -45;

vis = nw_modAddProj(vis, fS, 'R_V2', 'RG_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'GB_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'R_V2', 'BR_V4', W_F/2, [p2p 'gaborNot'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'G_V2', 'W_V4', W_F*W_fact*1.3/2, [p2p 'gaborNot'], projState, 'add');
% vis = nw_modAddProj(vis, fS, 'B_V2', 'W_V4', W_F*W_fact/2, [p2p 'gaborNot'], projState, 'add');

projState = [];
projState.sigma = 1.5;
projState.type = 'gaussian';
projState.norm = 'none';

vis = nw_modAddProj(vis, fS, 'R_V2', 'R_V4', W_F, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'G_V4', W_F, [p2p 'gaussianIIR'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'B_V4', W_F, [p2p 'gaussianIIR'], projState, 'add');

projState.sigma = 3.0;

% vis = nw_modAddProj(vis, fS, 'R_V2', 'R_V4', -W_F/6, [p2p 'gaussianIIR'], projState, 'add');
% vis = nw_modAddProj(vis, fS, 'G_V2', 'G_V4', -W_F/6, [p2p 'gaussianIIR'], projState, 'add');
% vis = nw_modAddProj(vis, fS, 'B_V2', 'B_V4', -W_F/6, [p2p 'gaussianIIR'], projState, 'add');


% automajic!
elements = {'R_V1' 'G_V1' 'B_V1' 'W_V1'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.norm = 'none';
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

elements = {'R_V1' 'G_V1' 'B_V1'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'o'', 1, [p2p ''onetoone''], projState, ''add'');']);
 end

elements = {'R_V2' 'G_V2' 'B_V2'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
end

elements = {'RG_V4' 'GB_V4' 'BR_V4' 'W_V4'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    for j = 1:size(elements,2)
        if i ~= j
            projState.norm = 'none';
            eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(j)) ''', W_I, [p2p ''onetoone''], projState, ''add'');']);
        end
    end
end

elements = {'RG_V4' 'GB_V4' 'BR_V4'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'o'', 1, [p2p ''onetoone''], projState, ''add'');']);
end

elements = {'R_V4' 'G_V4' 'B_V4'};
for i = 1:size(elements,2)
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) ''', W_R, [p2p ''onetoone''], projState, ''add'');']);
    eval(['vis = nw_modAddProj(vis, fS, ''' cell2mat(elements(i)) ''',''' cell2mat(elements(i)) 'o'', 1, [p2p ''onetoone''], projState, ''add'');']);
end




projState.type = 'mux';
projState.norm = 'none';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'RG_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'RG_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'GB_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'GB_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'BR_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'BR_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 4;
vis = nw_modAddProj(vis, fS, 'R_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'G_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'B_V4', 'comb_V4', W_F, [p2p 'muxMax'], projState, 'add');

%vis = nw_modAddProj(vis, fS, 'comb_V4', 'ITfb', w_for_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'comb_V4', 'IT', W_F, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'IT', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');

% and feedback ones: hmmmm.... needs some thought 

projState.sigma = 1.7;
projState.norm = 'none';
projState.radius = 4;
%%%% FEEDBACK

vis = nw_modAddProj(vis, fS, 'RG_V4o', 'R_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'GB_V4o', 'G_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'BR_V4o', 'B_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');

vis = nw_modAddProj(vis, fS, 'RG_V4o', 'G_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'GB_V4o', 'B_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'BR_V4o', 'R_V1o', W_B/2, [p2p 'discMax'], projState, 'shunt');
%%%

vis = nw_modAddProj(vis, fS, 'R_V4o', 'R_V1o', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'G_V4o', 'G_V1o', W_B, [p2p 'discMax'], projState, 'shunt');
vis = nw_modAddProj(vis, fS, 'B_V4o', 'B_V1o', W_B, [p2p 'discMax'], projState, 'shunt');


% Joining up the system with IT feedback

projState.norm = 'none';
projState.type = 'demux';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'ITfb', 'RG_V4o', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'ITfb', 'GB_V4o', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'ITfb', 'BR_V4o', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 4;
vis = nw_modAddProj(vis, fS, 'ITfb', 'R_V4o', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'ITfb', 'G_V4o', W_B, [p2p 'mux'], projState, 'shunt');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'ITfb', 'B_V4o', W_B, [p2p 'mux'], projState, 'shunt');



% and output feature map

vis = nw_modAddProj(vis, fS, 'R_V1o', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1o', 'LIP', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1o', 'LIP', 1, [p2p 'onetoone'], projState, 'add');

% build BRAHMS process to represent source
state1 = [];
state1.data = data;
state1.repeat = true;
state1.ndims = 1;
vis = vis.addprocess('src', 'std/2009/source/numeric', fS, state1);
% 
projState = [];
projState.srcDims = bgdims;
vis = nw_modAddInput(vis, fS, 'src>out', 'ITfb', W_B, [p2p 'onetoone'], projState, 'shunt');
vis = nw_modAddInput(vis, fS, 'src>out', 'VAmc_Thalamus', 1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'IT', 'ITfb', 1, [p2p 'onetoone'], projState, 'add');

% %% scope
if scopeOn==true
         
        state = [];
        state.dims = dims;
        state.scale=[0 0.72];
        state.zoom = 6;
        state.interval = inter;
        state.position = [240 280];
        state.colours = 'ice';
        state.title = 'LIP';
        state.trace = 0;
        state.trace_cut = 7;
        state.vertical_trace = false;
        state.trace_only = false;
        
        
        vis = vis.addprocess('scope2', 'dev/abrg/2009/scope', fS, state);
        
        state.scale=[0 1.02];
        state.title = 'R_V2';
        state.position = [800 5];
        state.dims = [dims./2];       
        vis = vis.addprocess('scoperv2', 'dev/abrg/2009/scope', fS, state);
        state.title = 'G_V2';
        state.position = [800 225];
        state.dims = [dims./2];       
        vis = vis.addprocess('scopegv2', 'dev/abrg/2009/scope', fS, state);
        state.title = 'B_V2';
        state.position = [800 445];
        state.dims = [dims./2];       
        vis = vis.addprocess('scopebv2', 'dev/abrg/2009/scope', fS, state);
        
        state.scale=[0 1.02];
        state.title = 'RG_V4';
        state.position = [580 5];
        state.dims = [dims./2];       
        vis = vis.addprocess('scoperg', 'dev/abrg/2009/scope', fS, state);
        state.title = 'GB_V4';
        state.position = [580 225];
        state.dims = [dims./2];       
        vis = vis.addprocess('scopegb', 'dev/abrg/2009/scope', fS, state);
        state.title = 'BR_V4';
        state.position = [580 445];
        state.dims = [dims./2];       
        vis = vis.addprocess('scopebr', 'dev/abrg/2009/scope', fS, state);
        
        state.scale=[0 1.02];
        state.zoom = 3;
        state.dims = [dims];
        state.position = [1000 5];
        state.title = 'R_V1';
        vis = vis.addprocess('scoperv1', 'dev/abrg/2009/scope', fS, state);
        state.position = [1000 225];
        state.title = 'G_V1';
        vis = vis.addprocess('scopegv1', 'dev/abrg/2009/scope', fS, state);
        state.position = [1000 445];
        state.title = 'B_V1';
        vis = vis.addprocess('scopebv1', 'dev/abrg/2009/scope', fS, state);
        state.position = [1000 665];
        state.title = 'W_V1';
        vis = vis.addprocess('scopewv1', 'dev/abrg/2009/scope', fS, state);
        
        state = [];
        state.dims = [6 1];
        state.scale=[0 1];
        state.zoom = 80;
        state.interval = inter;
        state.position = [20 780];
        state.colours = 'fire';
        state.title = 'IT';
        state.trace = 0;
        state.trace_cut = 0;
        state.vertical_trace = false;
        state.trace_only = false;
        
        vis = vis.addprocess('scopeIT', 'dev/abrg/2009/scope', fS, state);
        
        vis = vis.link('LIP/out>out', 'scope2<<mono<in');
        vis = vis.link('R_V2/out>out', 'scoperv2<<mono<in');
        vis = vis.link('G_V2/out>out', 'scopegv2<<mono<in');
        vis = vis.link('B_V2/out>out', 'scopebv2<<mono<in');
        vis = vis.link('R_V1/out>out', 'scoperv1<<mono<in');
        vis = vis.link('G_V1/out>out', 'scopegv1<<mono<in');
        vis = vis.link('B_V1/out>out', 'scopebv1<<mono<in');
        vis = vis.link('W_V1/out>out', 'scopewv1<<mono<in');
        vis = vis.link('RG_V4o/out>out', 'scoperg<<mono<in');
        vis = vis.link('GB_V4o/out>out', 'scopegb<<mono<in');
        vis = vis.link('BR_V4o/out>out', 'scopebr<<mono<in');
        
        vis = vis.link('ITfb/out>out', 'scopeIT<<mono<in');

end

 



sys = sys.addsubsystem('vis', vis);