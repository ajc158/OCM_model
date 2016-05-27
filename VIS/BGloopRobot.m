%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASAL GANGLIA
outState.c = single(0.15);
actState.tau_membrane = 0.0;
vis = nw_modAddPop(vis, 'Striatum_D1', fS/10, bgdims, bglocs, [p2a 'leaky'], actState, [p2o 'linear'], outState);
vis = nw_modAddPop(vis, 'Striatum_D2', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);


outState.c = -0.25;
actState.tau_membrane = 0.00;
vis = nw_modAddPop(vis, 'STN', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);

actState.tau_membrane = 0.02;
outState.c = -0.2;
vis = nw_modAddPop(vis, 'GPe', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);
vis = nw_modAddPop(vis, 'GPi', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);

outState.c = -0.0;       
vis = nw_modAddPop(vis, 'VAmc_Thalamus', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
outState.c = 0;
vis = nw_modAddPop(vis, 'TRN_Thalamus', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);

outState.c = 0;
vis = nw_modAddPop(vis, 'IT', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'tanh'], outState);
actState.p = 0;
vis = nw_modAddPop(vis, 'ITfb', fS/10, bgdims, bglocs, [p2a 'leaky'], actState,[p2o 'linear'], outState);
actState.p = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BG 

% vis = nw_modAddProj(vis, fS/10, 'Striatum_D1', 'GPi', VS_STR_D1_TO_SNR, [p2p 'onetoone'], projState, 'add');%-1.5
% projState.norm = 'none';
% vis = nw_modAddProj(vis, fS/10, 'STN', 'GPi', VS_STN_TO_SNR, [p2p 'diffuse'], projState, 'add');%0.4
% vis = nw_modAddProj(vis, fS/10, 'GPe', 'GPi', VS_GPE_TO_SNR, [p2p 'onetoone'], projState, 'add');%-0.4
% vis = nw_modAddProj(vis, fS/10, 'STN', 'GPe', VS_STN_TO_GPE, [p2p 'diffuse'], projState, 'add');%0.8
% vis = nw_modAddProj(vis, fS/10, 'GPe', 'STN', VS_GPE_TO_STN, [p2p 'onetoone'], projState, 'add');%-0.2
% vis = nw_modAddProj(vis, fS/10, 'Striatum_D2', 'GPe', VS_STR_D2_TO_GPE, [p2p 'onetoone'], projState, 'add');%-1.0
% vis = nw_modAddProj(vis, fS/10, 'GPi', 'TRN_Thalamus', -0.2, [p2p 'onetoone'], projState, 'add');
% %vis = nw_modAddProj(vis, fS/10, 'GPi', 'VAmc_Thalamus', VS_SNR_TO_THAL, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'GPi', 'VAmc_Thalamus', -0.9, [p2p 'onetoone'], projState, 'shunt');
% projState.norm = 'none';
% ratio = 0.3;
% level = 2.0;
% vis = nw_modAddProj(vis, fS/10, 'TRN_Thalamus', 'VAmc_Thalamus', VS_TRN_TO_THAL_OUTSIDE, [p2p 'allbutsame'], projState, 'shunt');
% vis = nw_modAddProj(vis, fS/10, 'TRN_Thalamus', 'VAmc_Thalamus', VS_TRN_TO_THAL_WITHIN, [p2p 'onetoone'], projState, 'add');%-0.07
% 
% vis = nw_modAddProj(vis, fS/10, 'VAmc_Thalamus', 'TRN_Thalamus', VS_THAL_TO_TRN, [p2p 'onetoone'], projState, 'add');
% 
% vis = nw_modAddProj(vis, fS/10, 'ITfb', 'Striatum_D1', IT_TO_STR_D1*(1+DOPAMINE), [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'ITfb', 'Striatum_D2', IT_TO_STR_D2*(1-DOPAMINE), [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'ITfb', 'STN', IT_TO_STN, [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'IT', 'Striatum_D1', 0.5*(1+dopamine), [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'IT', 'Striatum_D2', 0.5*(1-dopamine), [p2p 'onetoone'], projState, 'add');
% vis = nw_modAddProj(vis, fS/10, 'IT', 'STN', 0.5, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddProj(vis, fS/10, 'ITfb', 'TRN_Thalamus', IT_TO_TRN, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddProj(vis, fS/10, 'ITfb', 'VAmc_Thalamus', IT_TO_THAL, [p2p 'onetoone'], projState, 'add');

% here we can control the ratio of gains (overall gain =1) to control the system 

% vis = nw_modAddProj(vis, fS/10, 'VAmc_Thalamus', 'ITfb', THAL_TO_IT, [p2p 'onetoone'], projState, 'add');
%vis = nw_modAddProj(vis, fS/10, 'GPi', 'ITfb', -0.1, [p2p 'onetoone'], projState, 'add');

vis = nw_modAddProj(vis, fS/10, 'ITfb', 'ITfb', IT_RECIP, [p2p 'onetoone'], projState, 'add');
