function sys = nw_modAddInputLearning(sys, fS, src, dst, weight, projClass, projState, setName)

%link a non-neural src to a neural population dst

%NOTE: src must be of form 'sub1.sub2.srcProc>srcPort' where sub1 and sub2
%are subsystems, within sys, that contain the process srcProc with the
%output port srcPort, while dst must be of form 'sub1.sub2.dstPop' where sub1 and sub2
%are subsystems, within sys, that contain the population dstPop.

%process proj_name is automatically generated
proj_name = generateUniqueName(sys, src, dst); %TODO make sure this works now that ports are named on src

%strip off enclosing subsystems
[dst_names, dst_paths, dst_parents, dst_children] = parsepaths(dst, sys);

%append writer proj_name to state (opportunity to do more processing)
% actState.stateml_write = 'nw_projml_write'; % generic projection markup writer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge default state with that supplied

% we don't attempt to create defaults for src dims and locs as if supplied,
% it means we are probably connecting a none modlin src to a modlin dst

%NOTE must pass srcDims, srcLocs can be defaulted

if ~isfield(projState, 'srcDims')
    error('state structure must contain the field srcDims');
end
if ~isfield(projState, 'srcLocs')
    defaultState.srcLocs = {[1,1]};
end

defaultState.dstDims = eval(['sys.' dst '.act.state.dims']);
defaultState.dstLocs = eval(['sys.' dst '.act.state.locs']);

%defaultState.sigma = []; % want an error from BRAHMS if missing
%defaultState.weight = 1;
defaultState.invert = 0;
defaultState.minw = 0;
defaultState.delay = 0;
defaultState.norm = 'none';
defaultState.minw = 1e-2;
defaultState.decimate = 0;
defaultState.step = 1;
defaultState.report = false;
%args.compilerargs = {};

% merge defaults with passed values
projState = catstruct(defaultState, projState, 'sorted');

% weight overwrites existing state
projState.weight = weight;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%add proj subsystem and propagate port exposure to sys root
subCount = length(dst_paths);
child_sys = eval(['sys.' dst]);
for i = 1:subCount
    parent_sys = dst_parents{i};
    parent_sys = parent_sys.removesubsystem(dst_names{i});
    if i == 1
        %add proj process to dst pathsystem and link to activation process
           child_sys = child_sys.addprocess(proj_name, projClass, fS, projState);
           child_sys = child_sys.link([proj_name '>out'], ['act<<' setName]);
        child_sys = child_sys.expose([proj_name '<in'], [proj_name '_in']);
    else
        child_sys = child_sys.expose([dst_names{i-1} '<' proj_name '_in'], [proj_name '_in']);
    end
    child_sys = parent_sys.addsubsystem(dst_names{i}, child_sys);
end
sys = child_sys;

%strip any port info off
[src, srcPort] = strtok(src, '>');
if isempty(srcPort)
    srcPort = '>out';
end
%strip off enclosing subsystems
[src_names, src_paths, src_parents, src_children] = parsepaths(src, sys);
safe_src_port = sanatize([src srcPort]);

%propagate src out port exposure to sys root
subCount = length(src_paths);
for i = 2:subCount
    if i == 2
        child_sys = src_children{2};
        child_sys = child_sys.expose([src_names{1} srcPort], safe_src_port);
    else
        child_sys = child_sys.expose([src_names{i-1} '>' safe_src_port], safe_src_port);
    end
    parent_sys = src_parents{i};
    parent_sys = parent_sys.removesubsystem(src_names{i});
    child_sys = parent_sys.addsubsystem(src_names{i}, child_sys);
end
sys = child_sys;

%link src to newly exposed input
if subCount < 2
    sys = sys.link([src_names{end} srcPort], [dst_names{end} '<' proj_name '_in']);
else
    sys = sys.link([src_names{end} '>' safe_src_port], [dst_names{end} '<' proj_name '_in']);
end

% connect up the inputs:
targetName = proj_name;
for i = size(dst_names,2):-1:1
    str = dst_names{i};
    targetName = [str '/' targetName];
end
for i = 1:size(fieldnames(projState.learning.inputs),1)
    inputNames = fieldnames(projState.learning.inputs);
    inputName = inputNames(i);
    eval(['numArgs = size(projState.learning.inputs.' inputName{1} ',2);']);
    if numArgs == 1
        eval(['inputPort = projState.learning.inputs.' inputName{1} '{1};']);
        sys = sys.link(inputPort, [targetName '<<learning<' inputName{1}]);
    elseif numArgs == 2
        eval(['inputPort = projState.learning.inputs.' inputName{1} '{1};']);
        eval(['delayTime = projState.learning.inputs.' inputName{1} '{2};']);
        sys = sys.link(inputPort, [targetName '<<learning<' inputName{1}], delayTime);
    else
        error('too many arguments for learning input');
   end    
end

function proj_name = generateUniqueName(sys, src, dst)

% this is now high in win and low in fail
proj_name = [src '__2__' dst];
proj_name = sanatize(proj_name);
name_taken = 1;
name_index = 1;
while name_taken
    try
        if name_index == 1
            eval(['sys.' dst '.' proj_name ';']);
        else
            eval(['sys.' dst '.' proj_name '_' num2str(name_index) ';']);
        end
        name_index = name_index + 1;
    catch
        if name_index ~= 1
            proj_name = [proj_name '_' num2str(name_index)];
        end
        name_taken = 0;
    end
end

function name = sanatize(name)
pat = '\.';
name = regexprep(name, pat, '_');
pat = '>';
name = regexprep(name, pat, '_');

%% parsepaths
function [names, paths, parents, children] = parsepaths(fullpath, sys)

remain = fullpath;
i = 1;
while true
    [str, remain] = strtok(remain, '.');
    if isempty(str),  break;  end
    parts{i} = str;
    i = i + 1;
end

paths = {};
names = fliplr(parts);
num_name = length(names);
for i = 1:num_name-1
    str = [];
    for j = 1:num_name-1-i
        str = [str parts{j} '.'];
    end
    str = [str parts{num_name-i}];
    paths{i} = str;
end
paths{end+1} = '';

parents = {};
children = {};
for i = 1:num_name-1
    parents{i} = eval(['sys.' paths{i}]);
    children{i} = eval(['sys.' paths{i} '.' names{i}]);
end
parents{end+1} = sys;
children{end+1} = eval(['sys.' names{end}]);

% names = ...
%     'pop'
%     'sub3'
%     'sub2'
%     'sub1'
%
% paths = ...
%     'sub1.sub2.sub3'
%     'sub1.sub2'
%     'sub1'
%     ''

% parents = ...
%     'sys.sub1.sub2.sub3'
%     'sys.sub1.sub2'
%     'sys.sub1'
%     'sys'

% children = ...
%     'pop'
%     'sub3'
%     'sub2'
%     'sub1'
