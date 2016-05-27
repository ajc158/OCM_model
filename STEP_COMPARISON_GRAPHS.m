pars.delay = 0.3; %-0.5 -> 0.5
pars.dist = 25;

%%%%% VISUAL SEARCH CONTAINER SCRIPT, updated 2010 Alex Cope

%%% LOAD STANDARD PARAMETERS

DEFAULTS


%% MODIFY WEIGHTS FOR TESTING

%%% TRICKS

comp_input_from_fovea = false;
more_input_from_periphery = false;
more_phasic_in_periphery = false;
fixation_nogo_on = false;
input_normalised = false;
less_input_from_fovea = false;
nogo_on = false;

fovea_striatum_compensation = false;
fovea_striatum_comp_v2 = true;
fix_passthough = false;

fovea_STN_compensation = false;


%%%

jon_model = false;

degrees_to_edge = 24;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hack_model = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

STIM_NOISE = 10;

% FIXATION_STRENGTH = 1.0;
STIM_STRENGTH = 0.7;

% SC_SUPERIOR_TO_THAL = 7.0;

BACKGROUND_NOISE = 0.2;
% BACKGROUND_NOISE = 1.0;

big_noise = false;
BIG_NOISE_WEIGHT = 0.03;

SC_SUPERIOR_TO_THAL = 3.0;
SC_SUPERIOR_TO_SC_BUILDUP = 20.0;

long_delay = true;

%%%


%% Flags:
scopesOn = 0;
scopeOn = 0;  %% vis scopes
concerto = false;
logging_on = 3; % 0 = none, 1 = light, 2 = heavy, higher numbers are task specific

%% Scopes:
%scopeTarg = 'SC_buildup/out>out';
scopeTarg = 'FEF/out>out';
scopeTarg2 = 'BG/STN/out>out';
scopeTargA = 'SC_buildup/out>out';
scopeTargB = 'BG/SNr/out>out';

visModel = 'digit';
taskType = 'JON';

%% exePars
executionStop = 5.0;
fS = 1000;
num_samples = fS * executionStop;  

%% Bias:
%%%%%% set some interesting desire levels for features
if strcmp(visModel, 'digit')
    num_channels = 10;
else
    num_channels = 6;
end

D2_BIAS = 0.0;

DOPAMINE = 0.2;

%% Loop start:

colInd = 0;

rows = 9;
cols = 3;
fignum = figure('Units', 'pixels', 'Position', [0 0 cols*500 rows*100]);

for i = [-0.3] %40
    pars.delay = i;
    
    delay_amount = pars.delay;

    % end sim when we make a saccade, target set in STIMS.m
    targetMode = 0;
    targetVals = {};
    targetVals{1} = [pars.dist, 0, 5];
    targetVals{2} = [pars.dist, 0, 0.001];



    %%%%%%%%%%% RUN IT
    overrideName = ['sys_plot_delay'];
    
    FEF = [];
    SNr = [];
    FEF_in = [];
    SCB = [];
    THAL = [];
    D1 = [];
    STN = [];
    
    reRuns = 1;
    for repeatRun = 1:reRuns
        RUN_MODEL
        if repeatRun == 1
            FEF = out.orient.FEF.out.out;
            SNr = out.orient.BG.SNr.out.out;
            D1 = out.orient.BG.STR_D1.out.out;
            STN = out.orient.BG.STN.out.out;
            THAL = out.orient.THAL.out.out;
            FEF_in = out.orient.FEF_input.out.out;
            SCB = out.orient.SC_buildup.out.out;
        else
            FEF = FEF + out.orient.FEF.out.out;
            SNr = SNr + out.orient.BG.SNr.out.out;
            THAL = THAL + out.orient.THAL.out.out;
            FEF_in = FEF_in + out.orient.FEF_input.out.out;
            SCB = SCB + out.orient.SC_buildup.out.out;
        end
    end
    
    %%% divide by number of runs
    FEF = FEF./ reRuns;
    SNr = SNr./ reRuns;
    THAL = THAL./ reRuns;
    FEF_in = FEF_in./ reRuns;
    SCB = SCB./ reRuns;

    %% Loop end:


colInd = colInd + 1;

big_out = [squeeze(FEF(30,38,:)), squeeze(SNr(30,38,:)),squeeze(FEF(2,38,:)), squeeze(SNr(2,38,:)), squeeze(THAL(30,38,:)),squeeze(SCB(30,38,:)), squeeze(FEF_in(30*3,38*3,:)), squeeze(STN(30,38,:)),squeeze(D1(30,38,:)), squeeze(STN(2,38,:)), squeeze(FEF_in(2*3,38*3,:))];

csvwrite('~/Dropbox/OCM_data/gap_w_STN_D1_5', big_out);

error('moo');

paradigm_diag = zeros(2,4000);

paradigm_diag(1,1:1000-pars.delay*1000) = 1;

paradigm_diag(2,1000:4000) = 1;

figure(fignum);

fontSize = 14;

fontSizeTick = 10;

graphStart = 501 - pars.delay * 1000;

graphLen = 1601;
    
plotInd = colInd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes1 = subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

imagesc(paradigm_diag(:,graphStart:graphLen), [0 1]); colormap(gray); h=colorbar;
set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [50], ...
  'LineWidth'   , 2         );

pos1 = get(axes1, 'Position');

if colInd == 1
    
    hYLabel = ylabel('Stimuli    '                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

imagesc(squeeze(FEF_in(:,38*3,graphStart:graphLen)), [0 0.4]); colormap(hot); colorbar
set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [1 150], ...
  'LineWidth'   , 2         );

if colInd == 1
    
    hYLabel = ylabel('Visual Input'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

imagesc(squeeze(SNr(:,38,graphStart:graphLen)),[0 0.5]); colormap(hot); colorbar
set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [1 50], ...
  'LineWidth'   , 2         );

if colInd == 1
    
    hYLabel = ylabel('SNr'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes2 = subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

hold off;
hTarg= plot(squeeze(SNr(30,38,graphStart:graphLen))); 
hold on;
hFix = plot(squeeze(SNr(2,38,graphStart:graphLen))); 

set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [0 1], ...
  'LineWidth'   , 2         );

axis([1 graphLen-graphStart 0 1]);

set(hFix, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'LineStyle', '-.' ,                ...
    'LineWidth' , 2         );

set(hTarg, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...              ...
    'LineWidth' , 2         );

pos2 = get(axes2, 'Position');
pos2(3) = pos1(3);
set(axes2, 'Position', pos2);

if colInd == 1
    
    hYLabel = ylabel('SNr '                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

imagesc(squeeze(SCB(:,38,graphStart:graphLen)), [0 0.4]); colormap(hot); colorbar
set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [1 50], ...
  'LineWidth'   , 2         );

if colInd == 1
    
    hYLabel = ylabel('SC deep layers'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes2 = subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

hold off;
hTarg= plot(squeeze(SCB(30,38,graphStart:graphLen))); 
hold on;
hFix = plot(squeeze(SCB(2,38,graphStart:graphLen))); 

set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [0 1], ...
  'LineWidth'   , 2         );

axis([1 graphLen-graphStart 0 1]);

set(hFix, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'LineStyle', '-.' ,                ...
    'LineWidth' , 2         );

set(hTarg, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...              ...
    'LineWidth' , 2         );

pos2 = get(axes2, 'Position');
pos2(3) = pos1(3);
set(axes2, 'Position', pos2);

if colInd == 1
    
    hYLabel = ylabel('SC deep layers'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes2 = subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

hold off;
hTarg= plot(squeeze(THAL(30,38,graphStart:graphLen))); 
hold on;
hFix = plot(squeeze(THAL(2,38,graphStart:graphLen))); 

set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [], ...
  'YTick'       , [0 1], ...
  'LineWidth'   , 2         );

axis([1 graphLen-graphStart 0 1]);

set(hFix, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'LineStyle', '-.' ,                ...
    'LineWidth' , 2         );

set(hTarg, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...              ...
    'LineWidth' , 2         );

pos2 = get(axes2, 'Position');
pos2(3) = pos1(3);
set(axes2, 'Position', pos2);
if colInd == 1
    
    hYLabel = ylabel('Thalamus'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes2 = subplotb(rows,cols,plotInd); plotInd = plotInd + cols;

hold off;
hTarg= plot(squeeze(FEF(30,38,graphStart:graphLen))); 
hold on;
hFix = plot(squeeze(FEF(2,38,graphStart:graphLen))); 

set(gca, ...
  'FontSize'    , fontSizeTick        , ... 
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , [1 (graphLen-graphStart)/2 graphLen-graphStart], ...
  'YTick'       , [0 1], ...
  'LineWidth'   , 2         );

axis([1 graphLen-graphStart 0 1]);

set(hFix, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...
    'LineStyle', '-.' ,                ...
    'LineWidth' , 2         );

set(hTarg, ...
    'Color'     , [0.0 0.0 0.0]    ,   ...              ...
    'LineWidth' , 2         );

hXLabel = xlabel('Simulation time (ms)'                     );

set(gca                      , ...
    'FontName'   , 'Helvetica' );
set([hXLabel], ...
    'FontName'   , 'Helvetica');
set([hXLabel]  , ...
    'FontSize'   , fontSize        );

pos2 = get(axes2, 'Position');
pos2(3) = pos1(3);
set(axes2, 'Position', pos2);

if colInd == 1
    
    hYLabel = ylabel('FEF'                     );
set([hYLabel], ...
    'FontName'   , 'Helvetica', ...
    'Rotation'   ,  0 ,  ...
    'HorizontalAlignment','right', ...
    'FontSize'   , fontSize        );
end

end

 set(gcf, 'PaperPositionMode', 'auto'); print -depsc2 ~/big_overlap_gap_step.eps
