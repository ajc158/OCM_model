%
% net = sub_nw_node_lin(net, operation, ...)
% ________________________________________________
%
% pars - the parameters of each node, or a single
%   set of parameters to apply to all nodes.
%   should include the following:
%
%     tau_membrane      - membrane time constant (seconds)
%     p                 - nominal shunt gain
%     c                 - output offset
%     m                 - output gain
%     nonlin            - output non-linearity
%     sigma_membrane    - membrane additive noise s.d.
%     pos_reversal_potential
%     neg_reversal_potential
% ________________________________________________
%
% 	nonlin must be a single string (i.e. it can not be
% 	different for each node), and should be one of:
%
% 		none  - no output non-linearity
% 		hard1 - hard limit > 0
% 		hard2 - hard limit > 0, hard limit < 1
% 		soft1 - hard limit > 0, soft limit < 1 (tanh)
% 		soft2 - soft limit > 0, soft limit < 1 (jon's function)
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
% $Id::                                          $
% $Rev::                                         $
% $Author::                                      $
% $Date::                                        $
% ________________________________________________
%


function net = sub_nw_node_lin(net, operation, varargin)


switch(operation)
	
	case 'construct'
		
		% we can handle compact diffuse projections on this node type
		net.weavingPars.compactDiffuse = 1;
		
	
	case 'compile'
		
		% for each projection
		for p = 1:length(net.projections)
			
			% extract the uncompiled projection
			proj = net.projections(p);
			args = proj.pars;
			proj.pars = struct;
			
			% parse any arguments passed to addProj()
			if has(1, args, 'shunt')
				proj.pars.effect = 'multiplicative';
			else
				proj.pars.effect = 'additive';
			end
			
			% convert types
			proj.delay = single(proj.delay);
			
			% store the compiled projection
			net.projections(p) = proj;
			
		end

		% generate empty node set
		node = [];
		node.tau_membrane = single(zeros(0,1));
		node.c = single(zeros(0,1));
		node.m = single(zeros(0,1));
		node.p = single(zeros(0,1));
		node.nonlin = uint8(zeros(0,1));
		node.sigma_membrane = single(zeros(0,1));
		node.pos_reversal_potential = single(zeros(0,1));
		node.neg_reversal_potential = single(zeros(0,1));
		net.node = node;

		% add nodes for each population
		for n=1:length(net.structure.populations)
			net = addPop(net, n);
		end

		
	otherwise
		error('unsupported operation');
		
end



function net = addPop(net, n)


pop = net.structure.populations(n);
pars = pop.pars;

% translate nonlin field
if ischar(pars.nonlin)
	switch(pars.nonlin)
		case 'none'
			pars.nonlin = uint8(0);
		case 'hard1'
			pars.nonlin = uint8(1);
		case 'hard2'
			pars.nonlin = uint8(2);
		case 'soft1'
			pars.nonlin = uint8(3);
		case 'soft2'
			pars.nonlin = uint8(4);
		otherwise
			error('unrecognised nonlin type');
	end
end


% create node parameter arrays
fields = {'tau_membrane','c','m','p','nonlin','sigma_membrane','pos_reversal_potential','neg_reversal_potential'};
default_values = [];
default_values.pos_reversal_potential = Inf;
default_values.neg_reversal_potential = Inf;
for f=1:length(fields)
	
	key = fields{f};
	
	if isfield(pars, key)
		val = getfield(pars,key);
	else
		val = default_values.(key);
	end
	
	if isscalar(val)
		unity_in_correct_class = cast(1, class(val));
		val = val * repmat(unity_in_correct_class, length(pop.indices), 1);
	else
		if ~strcmp(key,'locs')
			if prod(size(val)) ~= pop.count
				error('number of parameters supplied does not match number of nodes requested');
			end
			val = reshape(val,pop.count,1); % in case they've been passed as a matrix of size "dims"
		end
	end

	existing_val = getfield(net.node, key);
	new_val = [existing_val; val];
	net.node = setfield(net.node, key, new_val);
	
end











function h = has(state, list, flag)

for n = 1:length(list)
	if ischar(list{n}) & strcmp(list{n}, flag)
		h = state;
		return
	end
end
h = ~state;



