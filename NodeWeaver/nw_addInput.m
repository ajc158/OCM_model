%
% net = nw_addInput(net, ...)
%
% add a new input to an existing network. this
% input can then be used as a source when adding
% extrinsic projections. 
% ________________________________________________
%
% net = nw_addInput(net, srcnet, srcpop)
%
% 'srcnet' should be another nodeweaver network,
% 'srcpop' the name of its output population to
% add. the name of the input for use as a
% reference when adding projections is derived as
% '[srcnet.name]_[srcpop]'.
% ________________________________________________
%
% net = nw_addInput(net, name, dims[, locs])
%
% here, the name, dims, and locs are given
% explicitly, rather than being extracted from
% another network. you need not supply 'locs' (see
% nw_addPop).
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
% $Id:: nw_addInput.m 53 2008-05-25 13:05:59Z be#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%

function net = nw_addInput(net, varargin)

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end


if nargin<3
	error('not enough arguments');
end

% switch on form
if ischar(varargin{2})
	
	input_net = varargin{1};
	input_pop = varargin{2};
	
	% construct name
	name = [input_net.head.name '_' input_pop];

	% check name is available
	[index, set, nodesBefore] = sub_nw_findSet(net, 'inputs', name);
	if index
		error('an input with that name already exists');
	end
	
	% get output population
	pop = nw_getSet(input_net, [input_pop '>']);
	
	% discard srcindices (not relevant outside home
	% network)
	pop = rmfield(pop, 'srcindices');
	
	% name becomes srcnetname_srcnetoutputname
	pop.name = [input_net.head.name '_' pop.name];

	% restructure population index and node indices
	% so that they make sense in the input array of
	% this net, rather than in the output array of
	% the src net
	pop.type = 'input';
	count = length(pop.indices);
	pop.indices = uint32(nodesBefore + (1:count)');
	
	% add it to network
	if nodesBefore
		net.structure.inputs(end+1) = pop;
	else
		net.structure.inputs = pop;
	end

	% ok
	return
	
end


% switch on form
if isnumeric(varargin{2})
	
	name = varargin{1};
	dims = varargin{2};
	if nargin>=4
		locs = varargin{3};
	else
		locs = [];
	end

	% check name is available
	[index, set, nodesBefore] = sub_nw_findSet(net, 'inputs', name);
	if index
		error('an input with that name already exists');
	end

	% construct pop
	pop = [];
	pop.type = 'input';
	pop.name = name;
	pop.indices = uint32(nodesBefore + (1:prod(dims))');
	pop.dims = dims;
	pop.locs = locs;

	% add it to network
	if nodesBefore
		net.structure.inputs(end+1) = pop;
	else
		net.structure.inputs = pop;
	end
	
	% ok
	return
	
end



error('unrecognised argument list');


