function sys = nw_modAddPop(sys, name, fS, dims, locs, actClass, actState, outClass, outState, varargin)

%process names are subsystem name with role appended
% actName = [name '_act'];
% outName = [name '_out'];
actName = 'act';
outName = 'out';

%append writer name to state (opportunity to do more processing)
% actState.stateml_write = 'nw_actml_write'; % generic activation markup writer
% outState.stateml_write = 'nw_outml_write'; % generic output function markup writer

% add or overwrite dims of act and out state
actState.dims = dims;
outState.dims = dims;

% and the same for locs and act
if isempty(locs)
    locs = {[1, 1]}; %default normalised node space
end
actState.locs = locs;

%set activation defaults
defaultState.tau_membrane = 0.5;
defaultState.p = 1;
defaultState.sigma_membrane = 0.0;
defaultState.pos_reversal_potential = inf;
defaultState.neg_reversal_potential = inf;

% merge defaults with passed values
actState = catstruct(defaultState, actState, 'sorted');

%set output defaults
defaultState= [];
defaultState.m = 1;
defaultState.c = 0;
defaultState.limits = 0;

% merge defaults with passed values
outState = catstruct(defaultState, outState, 'sorted');

% correct data types
actState.sigma_membrane = single(actState.sigma_membrane);
actState.pos_reversal_potential = single(actState.pos_reversal_potential);
actState.neg_reversal_potential = single(actState.neg_reversal_potential);
actState.p = single(actState.p);
actState.tau_membrane = single(actState.tau_membrane);

outState.c = single(outState.c);
outState.m = single(outState.m);
outState.limits = single(outState.limits);

%add act and out processes and link act->out
subsys = sml_system(name);
subsys = subsys.addprocess(actName, actClass, fS, actState);
subsys = subsys.addprocess(outName, outClass, fS, outState);
subsys = subsys.link([actName '>out'], outName);

%expose output function process' output to outside world
subsys = subsys.expose([outName '>out'], 'out');
subsys = subsys.expose([actName '<in'], 'in');

%add the subsystem to the system
sys = sys.addsubsystem(name, subsys);
