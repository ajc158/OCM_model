inter = 30;

%%% VIS

vis = sml_system('Vis Add');

dopamine=0.2;
num_channels = 6;
fS = 400;
%num_samples = fS * executionStop;

dims = [In_dims];
locs = {[In_locs]};

% 

W_F = FEEDFORWARD_WEIGHT_ADD;
W_B = FEEDBACK_WEIGHT_ADD;
W_R = RECIPROCAL_WEIGHT_ADD;   

% performance eval:
W_B = w_back_test;
W_R = w_recip_test;
% /performance eval

w_inh_v1=FEATURE_INHIBITION_ADD;

w_for_v1 = W_F;%0.05
w_inh_v4 = FEATURE_INHIBITION_ADD;
w_for_v2 = W_F;
w_for_v4 = W_F;
w_recip =W_R;%0.5

w_bac_v2=W_B;%0.3
w_bac_v4=W_B;


data1 = ones(6,1);

%%%%%%%%%% set up standard parameters (see "help sub_nw_node_lin")
actState = [];
actState.tau_membrane = single(0.005);
actState.p = 1;
actState.sigma_membrane = 0.0;

outState = [];
outState.m = 1;
outState.c = single(0.0);
outState.limits = 2;


%%%%%%%%%%%%%%%%%%%%%% add neural populations

bgdims = [6];
bglocs = {[6]};
    
actState.tau_membrane = single(0.005);

outState.c = single(0);
vis = nw_modAddPop(vis, 'R_V1', fS, dims, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'G_V1', fS, dims, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'B_V1', fS, dims, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'W_V1', fS, dims, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
outState.limits = 2;

vis = nw_modAddPop(vis, 'R_V2', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'G_V2', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'B_V2', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);

vis = nw_modAddPop(vis, 'RG_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'GB_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'BR_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'W_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);

vis = nw_modAddPop(vis, 'R_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'G_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
vis = nw_modAddPop(vis, 'B_V4', fS, dims./2, locs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);

vis = nw_modAddPop(vis, 'comb_V4', fS, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
outState.c = 0.0;
vis = nw_modAddPop(vis, 'LIP', fS, dims, {[layerLocs]}, [p2a 'leaky'], actState,[p2o, 'linear'], outState);
outState.c = 0.0;

%%%%%%%%%%%%%%%% add internal projections (see "help nw_addProj")
projState = [];
projState.delay = 0;
projState.norm = 'none';
projState.minw = 1e-2;
projState.decimate = 0.0;


% selection mechanism in IT
gpe2stn = 1.0;
stn2gpe=1.0;
d22gpe=0.9;
BGloop



% Feedforward connections

projState.sigma = 1.0;

vis = nw_modAddProj(vis, fS, 'R_V1', 'R_V2', w_for_v1, [p2p 'gaussianMax'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'G_V2', w_for_v1, [p2p 'gaussianMax'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'B_V2', w_for_v1, [p2p 'gaussianMax'], projState, 'add');

projState.norm = 'affx';
projState.sigma = 3.2;%1.5
projState.lambda = 6;%projState.sigma * 0.5357;
projState.rotation = 45;
projState.offset = 0;
projState.aspect = 0.7;%0.6

W_fact = 0.6;
factGab = 1;
vis = nw_modAddProj(vis, fS, 'G_V2', 'RG_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'GB_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'BR_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V2', 'W_V4', w_for_v2*W_fact*1.3*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'W_V4', w_for_v2*W_fact*factGab, [p2p 'gabor_not'], projState, 'add');

projState.rotation = -45;

vis = nw_modAddProj(vis, fS, 'R_V2', 'RG_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'GB_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'R_V2', 'BR_V4', w_for_v2*factGab, [p2p 'gabor_not'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'G_V2', 'W_V4', w_for_v2*W_fact*1.3*factGab, [p2p 'gabor_not'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'W_V4', w_for_v2*W_fact*factGab, [p2p 'gabor_not'], projState, 'add');

projState = [];
projState.sigma = 1.5;
projState.norm = 'none';

vis = nw_modAddProj(vis, fS, 'R_V2', 'R_V4', W_F*0.9, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'G_V4', W_F*0.9, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'B_V4', W_F*0.9, [p2p 'gaussian'], projState, 'add');

projState.sigma = 3.0;

vis = nw_modAddProj(vis, fS, 'R_V2', 'R_V4', -W_F/6, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'G_V4', -W_F/6, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'B_V4', -W_F/6, [p2p 'gaussian'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V1', 'B_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'R_V1', 'G_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'R_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'G_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'R_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'B_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'R_V1', 'W_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'W_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'W_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V1', 'R_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V1', 'G_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V1', 'B_V1', w_inh_v1, [p2p 'onetoone'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'RG_V4', 'BR_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'RG_V4', 'GB_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'RG_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'GB_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'RG_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'BR_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V4', 'RG_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V4', 'BR_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V4', 'GB_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'RG_V4', 'W_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'W_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'W_V4', w_inh_v4, [p2p 'onetoone'], projState, 'add');

% vis = nw_addProj(vis, 'RG_V4', 'IT_max', w_for_v4*200, 'Mux', 'position=1', 'norm=none');
% vis = nw_addProj(vis, 'GB_V4', 'IT_max', w_for_v4*200, 'Mux', 'position=2', 'norm=none');
% vis = nw_addProj(vis, 'BR_V4', 'IT_max', w_for_v4*200, 'Mux', 'position=3', 'norm=none');


projState.type = 'mux';
projState.norm = 'none';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'RG_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'RG_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'GB_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'GB_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'BR_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');
%vis = nw_modAddProj(vis, fS, 'BR_V4', 'IT', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 4;
vis = nw_modAddProj(vis, fS, 'R_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'G_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'B_V4', 'comb_V4', w_for_v4, [p2p 'muxMax'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'comb_V4', 'ITfb', w_for_v4, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'comb_V4', 'IT', w_for_v4, [p2p 'onetoone'], projState, 'add');

% and feedback ones: hmmmm.... needs some thought 

projState.sigma = 1.0;
projState.norm = 'affx';
factorG = ((2*3.14)^0.5*projState.sigma);

vis = nw_modAddProj(vis, fS, 'RG_V4', 'R_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'G_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'B_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'RG_V4', 'G_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'B_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'R_V1', w_bac_v2*factorG, [p2p 'gaussian'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V4', 'R_V1', W_B*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V4', 'G_V1', W_B*factorG, [p2p 'gaussian'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V4', 'B_V1', W_B*factorG, [p2p 'gaussian'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V1', 'R_V1', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'G_V1', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'B_V1', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V1', 'W_V1', w_recip, [p2p 'onetoone'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'R_V2', 'R_V2', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V2', 'G_V2', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V2', 'B_V2', w_recip, [p2p 'onetoone'], projState, 'add');

vis = nw_modAddProj(vis, fS, 'RG_V4', 'RG_V4', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'GB_V4', 'GB_V4', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'BR_V4', 'BR_V4', w_recip, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'W_V4', 'W_V4', w_recip, [p2p 'onetoone'], projState, 'add');

% Joining up the system with IT feedback

projState.norm = 'none';
projState.type = 'demux';
projState.position = 1;
vis = nw_modAddProj(vis, fS, 'ITfb', 'RG_V4', w_bac_v4, [p2p 'mux'], projState, 'add');
projState.position = 2;
vis = nw_modAddProj(vis, fS, 'ITfb', 'GB_V4', w_bac_v4, [p2p 'mux'], projState, 'add');
projState.position = 3;
vis = nw_modAddProj(vis, fS, 'ITfb', 'BR_V4', w_bac_v4, [p2p 'mux'], projState, 'add');

projState.position = 4;
vis = nw_modAddProj(vis, fS, 'ITfb', 'R_V4', w_bac_v4, [p2p 'mux'], projState, 'add');
projState.position = 5;
vis = nw_modAddProj(vis, fS, 'ITfb', 'G_V4', w_bac_v4, [p2p 'mux'], projState, 'add');
projState.position = 6;
vis = nw_modAddProj(vis, fS, 'ITfb', 'B_V4', w_bac_v4, [p2p 'mux'], projState, 'add');

% and output feature map

vis = nw_modAddProj(vis, fS, 'R_V1', 'LIP', 1.2, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'G_V1', 'LIP', 1.2, [p2p 'onetoone'], projState, 'add');
vis = nw_modAddProj(vis, fS, 'B_V1', 'LIP', 1.2, [p2p 'onetoone'], projState, 'add');


% build BRAHMS process to represent source
state1 = [];
state1.data = data;
state1.repeat = true;
state1.ndims = 1;
vis = vis.addprocess('src', 'dev/std/source/numeric', fS, state1);
% 


 %%% scope
 if scopeOn == true
       
        state = [];
        state.dims = dims;
        state.scale=[0 1.02];
        state.zoom = 3;
        state.interval = inter;
        state.position = [240 280];
        state.colours = 'ice';
        state.title = 'LIP';
        state.trace = 0;
        state.trace_cut = 7;
        state.vertical_trace = false;
        state.trace_only = false;
        
        
        vis = vis.addprocess('scope2', 'dev\abrg\2008\scope', fS, state);
        state.zoom = 6;
        state.scale=[0 1.01];
        state.title = 'R_V2';
        state.position = [800 5];
        state.dims = [dims./2];       
        vis = vis.addprocess('scoperv2', 'dev\abrg\2008\scope', fS, state);
        state.title = 'G_V2';
        state.position = [800 225];
        vis = vis.addprocess('scopegv2', 'dev\abrg\2008\scope', fS, state);
        state.title = 'B_V2';
        state.position = [800 445];
        vis = vis.addprocess('scopebv2', 'dev\abrg\2008\scope', fS, state);
        
        state.scale=[0 1.01];
        state.title = 'RG_V4';
        state.position = [580 5];
        vis = vis.addprocess('scoperg', 'dev\abrg\2008\scope', fS, state);
        state.title = 'GB_V4';
        state.position = [580 225];
        vis = vis.addprocess('scopegb', 'dev\abrg\2008\scope', fS, state);
        state.title = 'BR_V4';
        state.position = [580 445];
        vis = vis.addprocess('scopebr', 'dev\abrg\2008\scope', fS, state);
        
        state.scale=[0 1.02];
        state.zoom = 3;
        state.dims = [dims];
        state.position = [1000 5];
        state.title = 'R_V1';
        vis = vis.addprocess('scoperv1', 'dev\abrg\2008\scope', fS, state);
        state.position = [1000 225];
        state.title = 'G_V1';
        vis = vis.addprocess('scopegv1', 'dev\abrg\2008\scope', fS, state);
        state.position = [1000 445];
        state.title = 'B_V1';
        vis = vis.addprocess('scopebv1', 'dev\abrg\2008\scope', fS, state);
        state.position = [1000 665];
        state.title = 'W_V1';
        vis = vis.addprocess('scopewv1', 'dev\abrg\2008\scope', fS, state);
        
        state = [];
        state.dims = [6 1];
        state.scale=[0 1];
        state.zoom = 80;
        state.interval =inter;
        state.position = [20 780];
        state.colours = 'fire';
        state.title = 'IT';
        state.trace = 0;
        state.trace_cut = 0;
        state.vertical_trace = false;
        state.trace_only = false;
        
        

        vis = vis.addprocess('scopeIT', 'dev\abrg\2008\scope', fS, state);

    
    
        vis = vis.link('LIP/out>out', 'scope2<<mono<in');
        vis = vis.link('R_V2/out>out', 'scoperv2<<mono<in');
        vis = vis.link('G_V2/out>out', 'scopegv2<<mono<in');
        vis = vis.link('B_V2/out>out', 'scopebv2<<mono<in');
        vis = vis.link('R_V1/out>out', 'scoperv1<<mono<in');
        vis = vis.link('G_V1/out>out', 'scopegv1<<mono<in');
        vis = vis.link('B_V1/out>out', 'scopebv1<<mono<in');
        vis = vis.link('W_V1/out>out', 'scopewv1<<mono<in');
        vis = vis.link('RG_V4/out>out', 'scoperg<<mono<in');
        vis = vis.link('GB_V4/out>out', 'scopegb<<mono<in');
        vis = vis.link('BR_V4/out>out', 'scopebr<<mono<in');
        
        vis = vis.link('ITfb/out>out', 'scopeIT<<mono<in');
 end

        vis = vis.link('src>out', 'ITfb<in');  
        

        
        state = [];	state.dims = uint32(dims); state.dist = 'normal';
		state.pars = [0 0.4];	state.complex = false;
		vis = vis.addprocess('rndR', 'dev/std/random/numeric', fS, state);
		vis = vis.addprocess('rndG', 'dev/std/random/numeric', fS, state);
        vis = vis.addprocess('rndB', 'dev/std/random/numeric', fS, state);
        
        projState = [];
        projState.srcDims = dims;

         
        % NOISE
        if noise == true
        vis = nw_modAddInput(vis, fS, 'rndR>out', 'R_V1', 0.1, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndG>out', 'G_V1', 0.1, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndB>out', 'B_V1', 0.1, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndR>out', 'W_V1', 0.035, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndG>out', 'W_V1', 0.035, [p2p 'onetoone'], projState, 'add');
        vis = nw_modAddInput(vis, fS, 'rndB>out', 'W_V1', 0.035, [p2p 'onetoone'], projState, 'add');                               
        end
        
        
 sys = sys.addsubsystem('vis', vis);