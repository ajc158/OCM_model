%
% net = nw_setOutputs(net, ...)
%
% set the output nodes of an existing net. each
% argument can be anything accepted by nw_getSet,
% or 'all' to set all network populations as
% outputs.
% ________________________________________________
%
% This software is licensed under the GNU GPL. For
% details and terms of use, see this source file.

% ________________________________________________
%
% This file is part of NodeWeaver
% Copyright (C) 2007 Ben Mitch(inson)
% URL: http:sourceforge.net/projects/nodeweaver
%
% This program is free software; you can
% redistribute it and/or modify it under the terms
% of the GNU General Public License as published
% by the Free Software Foundation; either version
% 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it
% will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU
% General Public License along with this program;
% if not, write to the Free Software Foundation,
% Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA  02110-1301, USA.
% ________________________________________________
%
% Subversion Repository Information
%
% $Id:: nw_setOutputs.m 53 2008-05-25 13:05:59Z #$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%

function net = nw_setOutputs(net, varargin)

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end

popnames = {net.structure.populations.name};
net.structure.outputs = [];

for n=2:nargin
	arg=varargin{n-1};
	if strcmp(arg,'all')
		if nargin ~= 2 error(['"all" should be sole argument']); end
		for n=1:length(popnames)
			net = nw_addOutput(net, popnames{n});
		end
	else
		net = nw_addOutput(net, arg);
	end
end



function net = nw_addOutput(net, name)

% check name is available
[index, set, nodesBefore] = sub_nw_findSet(net, 'outputs', name);
if index
	error('an output with that name already exists');
end

% get population
set = nw_getSet(net, name);

% not allowed to add inputs as outputs, so let's just check
if ~strcmp(set.type, 'population') error('can only add populations as outputs'); end

% remove unneeded fields
set = rmfield(set, 'pars');

% change type
set.type = 'output';

% population indices become the srcindices of this
% output
set.srcindices = set.indices;

% and the indices are the indices into the outputs
% array, as for all structural populations
count = length(set.srcindices);
set.indices = uint32(nodesBefore + (1:count))';

% add it to network
if nodesBefore
	net.structure.outputs(end+1) = set;
else
	net.structure.outputs = set;
end


