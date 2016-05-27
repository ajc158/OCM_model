%
% pop = nw_getSet(net, desc)
%
% returns a set from a network's structure, either
% an input, population, or output set. the set
% returned may be all or some subset of a
% structure set, but may not contain nodes from
% more than one net set. desc should generally be
% a cell array:
%
%   {setname, dim1, dim2, ...}
%
% where setname is either the name of a net
% population or has the form '>INPUTNAME' or
% 'OUTPUTNAME>'. dimN should be the indices to be
% accepted in that dimension - all can be
% specified using ':'. unsupplied dimensions are
% not used as constraints. if no dimensions are to
% be supplied, the setname need not be in a cell.
% ________________________________________________
%
% INPUTNAME generally takes the form
% NETNAME_POPNAME (if set using nw_setInput), but
% OUTPUTNAME is just the POPNAME of a population
% in the network. the only difference in
% specifying an output name is that the returned
% set has indices into the output stack rather
% than into the node stack.
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
% $Id:: nw_getSet.m 53 2008-05-25 13:05:59Z benj#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%


function pop = nw_getSet(net, desc)

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end


% parse shortcuts
if ischar(desc)
	setname = desc;
	dims = {};
elseif length(desc) == 1
	setname = desc{1};
	dims = {};
else
	setname = desc{1};
	dims = desc(2:end);
end



% what was asked for
if setname(1) == '>'
	setname = setname(2:end);
	pops = net.structure.inputs;
	lookingfor = 'input';
elseif setname(end) == '>'
	setname = setname(1:end-1);
	pops = net.structure.outputs;
	lookingfor = 'output';
else
	pops = net.structure.populations;
	lookingfor = 'population';
end


% extract whole pop
found = 0;
for p = 1:length(pops)
	if strcmp(pops(p).name, setname)
		found = p;
		break;
	end
end
if (~found)
	error(['requested ' lookingfor ' "' setname '" was not found in this network']);
end
pop = pops(found);



% restrict if requested
if isempty(dims) return; end

% build dimension indices of all cells
ind = sub_nw_expandDims(double(pop.dims));

% start by assuming all are included
include = (1:size(ind,1))';

% and knock out using supplied dims
for n=1:size(dims,2)
	
	% colon means don't exclude on this dimension
	if ischar(dims{n}) & dims{n} == ':' continue; end
	
	% otherwise, exclude
	M = min(sub_nw_sepsq(double(ind(:,n)'),dims{n}),[],2);
	include = include & M == 0;
	
end
include = find(include);

% now update pop details
pop.count = length(include);
pop.indices = pop.indices(include);

% propagate locs if it is present
if ~isempty(pop.locs)
	pop.locs = pop.locs(include,:);
end

% pop.dims is slightly harder
for n=1:size(dims,2)
	if ischar(dims{n}) & dims{n} == ':' continue; end
	pop.dims(n) = uint32(length(dims{n}));
end

% check
if pop.count ~= prod(double(pop.dims))
	error('internal error');
end

