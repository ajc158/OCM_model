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
defaultState.tau_membrane = 0.51;
defaultState.p = 1;
defaultState.sigma_membrane = 0.0;
defaultState.pos_reversal_potential = inf;
defaultState.neg_reversal_potential = inf;

% merge defaults with passed values
if ~isfield(actState,'tau_membrane')
	actState.tau_membrane = defaultState.tau_membrane;
end
if ~isfield(actState,'p')
	actState.p = defaultState.p;
end
if ~isfield(actState,'sigma_membrane')
	actState.sigma_membrane = defaultState.sigma_membrane;
end
if ~isfield(actState,'pos_reversal_potential')
	actState.pos_reversal_potential = defaultState.pos_reversal_potential;
end
if ~isfield(actState,'neg_reversal_potential')
	actState.neg_reversal_potential = defaultState.neg_reversal_potential;
end
%actState = catstruct(defaultState, actState, 'sorted')

%set output defaults
defaultState= [];
defaultState.m = 1;
defaultState.c = 0;
defaultState.limits = 0;

% merge defaults with passed values
if ~isfield(outState,'m')
	outState.m= defaultState.m;
end
if ~isfield(outState,'c')
	outState.c= defaultState.c;
end
if ~isfield(outState,'limits')
	outState.limits= defaultState.limits;
end

%outState = catstruct(defaultState, outState, 'sorted');

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
subsys = sml_system();
subsys = subsys.addprocess(actName, actClass, fS, actState);
subsys = subsys.addprocess(outName, outClass, fS, outState);
subsys = subsys.link([actName '>out'], outName,0);

%expose output function process' output to outside world
subsys = subsys.expose([outName '>out'], 'out');
subsys = subsys.expose([actName '<in'], 'in');

%add the subsystem to the system
sys = sys.addsubsystem(name, subsys);
