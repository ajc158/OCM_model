%
% net = nw_addPop(net, name, dims, pars, locs)
%
% name:
%   the name by which the population will be
%   referenced within the network.
% 
% dims:
%   the dimensions of the pop in numbers of nodes.
%   this sets the node count N=prod(dims), and
%   organises the outputs of this layer into a
%   matrix with dimensions dims. for a population
%   with no spatial organisation, just pass a
%   scalar node count as dims.
% 
% locs:
%   if unsupplied, the location of each node will
%   be its dimension index. for example, if
%   dims=[2 5], the nodes will have locations [1
%   1], [2 1], [1 2], ...
%
%   pass a row vector of length between 1 and
%   length(dims) in a cell array to spread nodes
%   on a grid spanning a rectangle locs units in
%   size. for example, if dims=[10 5] and locs={[2
%   2]}, the fourth node will have location [0.7
%   0.2].
% 
%   if dims=[10 5 3] and locs={[2 2]}, the fourth
%   node is still at [0.7 0.2], since the last
%   dimension index does not affect location. pass
%   locs as a {2xD vector} to specify the lower
%   and upper bounds of a D-dimensional cuboid to
%   spread the nodes over. alternatively, pass
%   locs explicitly as an NxD location matrix (not
%   in a cell).
%
% pars:
%   parameters of the nodes in the population.
%   these will be passed to the compiler for this
%   node type when you compile the network.
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
% $Id:: nw_addPop.m 53 2008-05-25 13:05:59Z benj#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%

function net = nw_addPop(net, name, dims, pars, locs)

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end


if nargin<4 pars = struct; end
if nargin<5 locs = []; end


% check name is available
[index, set, nodesBefore] = sub_nw_findSet(net, 'populations', name);
if index
	error('a population with that name already exists');
end


% construct locs
if ~exist('locs','var') locs = []; end


% construct pop
pop = [];
pop.type = 'population';
pop.name = name;
pop.indices = uint32(nodesBefore + [1:prod(dims)]');
pop.dims = dims;
pop.locs = locs;
pop.pars = pars;

% add it to network
if nodesBefore
	net.structure.populations(end+1) = pop;
else
	net.structure.populations = pop;
end

