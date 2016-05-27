%
% net = sub_nw_node_snn(net, operation, ...)
% ________________________________________________
%
% pars - the parameters of each node, or a single
%   set of parameters to apply to all nodes.
%   should include the following:
%
%     V_min             - minimum membrane potential
%     V_refractory      - reset membrane potential
%     V_threshold       - threshold membrane potential
%     t_refractory      - refractory period (seconds)
%     tau_membrane      - membrane time constant (seconds)
%     I_spontaneous     - spontaneous current
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


function net = sub_nw_node_snn(net, operation, varargin)


switch(operation)
	
	case 'construct'
		
		% here's some ideas for currents!
% 	0.002,	-1.0,		//	GABA-A
% 	0.002,	+1.0,		//	AMPA
% 	0.100,	-1.0,		//	GABA-B
% 	0.100,	+1.0,		//	NMDA
% 	0.020,	-1.0,		//	MIDINH
% 	0.020,	+1.0,		//	MIDEXC
		
		
	case 'compile'
		
		% extract currents
		if ~isfield(net.global, 'currents')
			error('global currents not set');
		end
		currents = net.global.currents;

		% for each projection
		for p = 1:length(net.projections)
			
			% extract the uncompiled projection
			proj = net.projections(p);
			args = proj.pars;
			proj.pars = struct;
			
			% default arguments
			% none...
			
			% parse any arguments passed to addProj()
			for n = 1:length(args)
				
				arg = args{n};
				
				if ischar(arg)
					if isfield(currents, arg)
						proj.pars.current = arg;
						continue
					end

					error(['unrecognised projection argument "' arg '"']);
				end
				
				disp(arg)
				error(['unrecognised projection argument (above)']);
				
			end
			
			% convert weight to single precision
			proj.weight = single(proj.weight);

			% store the compiled projection
			net.projections(p) = proj;
			
		end
		
		
		
% 		min_weight = 0;
% 		offset = 1;
% 
% 
% 		% extract uncompiled projections
% 		uncompiled = net.projections.uncompiled;
% 		net.projections = rmfield(net.projections, 'uncompiled');
% 
% 		% get nature of projections
% 		intrinsics = cell2double({uncompiled.intrinsic});
% 		shunts = cell2double({uncompiled.shunt});
% 		counts = cell2double({uncompiled.count});
% 		compacts = cell2double({uncompiled.compact});
% 		if any(compacts) error('internal error'); end
% 
% 
% 		% break into intrinsic and extrinsic, shunt and additive
% 		roots = {'extrinsic','intrinsic'};
% 		for intrinsic=0:1
% 			for shunt=0:1
% 
% 				projind = find(intrinsics == intrinsic & shunts == shunt);
% 				counts_ = counts(projind);
% 				counttot = sum(counts_);
% 				offsets = [cumsum(counts_)];
% 				offsets = [1 offsets(1:end-1)+1; offsets];
% 
% 				s = [];
% 				if (~intrinsic) s.input = zeros(counttot,1,'uint32'); end
% 				s.src = zeros(counttot,1,'uint32');
% 				s.dst = zeros(counttot,1,'uint32');
% 				s.weight = zeros(counttot,1);
% 				s.delay = zeros(counttot,1,'single');
% 				s.current = zeros(counttot,1,'uint8');
% 
% 				for n=1:length(projind)
% 					if uncompiled(projind(n)).args.shunt error('shunting not supported currently in SNN'); end
% 					s.current(offsets(1,n):offsets(2,n)) = interpretCurrentType(uncompiled(projind(n)).args.current);
% 					if (~intrinsic) s.input(offsets(1,n):offsets(2,n)) = uncompiled(projind(n)).input - offset; end
% 					s.src(offsets(1,n):offsets(2,n)) = uncompiled(projind(n)).src - offset;
% 					s.dst(offsets(1,n):offsets(2,n)) = uncompiled(projind(n)).dst - offset;
% 					s.weight(offsets(1,n):offsets(2,n)) = uncompiled(projind(n)).weight;
% 					s.delay(offsets(1,n):offsets(2,n)) = uncompiled(projind(n)).delay;
% 				end
% 
% 				% number of sources
% 				if intrinsic
% 					num_sources = net.structure.populations_count(2);
% 				else
% 					num_sources = net.structure.inputs_count(2);
% 				end
% 
% 				% pre-processing optimisations
% 				if ~isempty(s.src)
% 
% 					% pare by min weight
% 					if min(abs(s.weight)) < min_weight
% 						ind = abs(s.weight) >= min_weight;
% 						s.src = s.src(ind);
% 						s.dst = s.dst(ind);
% 						s.weight = s.weight(ind);
% 						s.delay = s.delay(ind);
% 						s.current = s.current(ind);
% 						if (~intrinsic) s.input = s.input(ind); end
% 					end
% 
% 				end
% 
% 				% zero arrays
% 				n_delays = zeros(num_sources,1);
% 				delays = zeros(num_sources,0);
% 				bounds = zeros(num_sources,1);
% 
% 				% update src for inputs
% 				if ~intrinsic
% 					f = fieldnames(net.structure.inputs);
% 					offsets = [0];
% 					for fi=2:length(f)
% 						offsets(end+1) = offsets(end) + net.structure.inputs.(f{fi}).count;
% 					end
% 					if size(offsets,2)>1 offsets=offsets'; end
% 					offsets = uint32(offsets);
% 					s.src = s.src + offsets(s.input + 1);
% 				end
% 
% 				% sort by src index and delay
% 				if ~isempty(s.src)
% 					[src_delay, ind] = sort(double(s.src) + s.delay / (max(s.delay)+1e-3));
% 					s.src = s.src(ind);
% 					s.dst = s.dst(ind);
% 					s.weight = s.weight(ind);
% 					s.delay = s.delay(ind);
% 					s.current = s.current(ind);
% 					if (~intrinsic) s.input = s.input(ind); end
% 				else
% 					src_delay = [];
% 				end
% 
% 				% build store structure
% 				S = [];
% 				S.target = uint32(s.dst);
% 				S.weight = double(s.weight);
% 				S.type = uint8(s.current);
% 
% 				% break into pieces by src neuron/delay
% 				chunks = [];
% 				for n=1:length(src_delay)
% 					if ~isempty(chunks) & chunks(end) == src_delay(n)
% 						continue;
% 					end
% 					chunks(end+1) = src_delay(n);
% 				end
% 
% 				% do each chunk
% 				c = 0;
% 				for n=1:length(chunks)
% 					ind = find(src_delay == chunks(n));
% 					src = s.src(ind(1)) + 1;
% 					n_delays(src) = n_delays(src) + 1;
% 					delays(src, n_delays(src)) = s.delay(ind(1));
% 					bounds(src, n_delays(src)) = c;
% 					d = c + length(ind);
% 					bounds(src, n_delays(src)+1) = d;
% 					c = d;
% 				end
% 
% 				% fill source details
% 				S.n_delays = uint32(n_delays);
% 				S.delays = double(delays);
% 				S.bounds = uint32(bounds);
% 
% 				if shunt
% 					net.(roots{intrinsic+1}).shunt = S;
% 				else
% 					net.(roots{intrinsic+1}) = S;
% 				end
% 
% 			end
% 		end
% 
% 
		% set default global parameters for those not already set
		if ~isfield(net.global,'noise_thresh_sd') net.global.noise_thresh_sd = 0; end


		% generate empty node set
		net.node.V_min = zeros(0,1);
		net.node.V_refractory = zeros(0,1);
		net.node.V_threshold = zeros(0,1);
		net.node.t_refractory = zeros(0,1);
		net.node.tau_membrane = zeros(0,1);
		net.node.I_spontaneous = zeros(0,1);


		% add nodes for each population
		for n=1:length(net.structure.populations)
			net = addPop(net, n);
		end

		
	otherwise
		error('unsupported operation');
		
end




function net = addPop(net, n)


pop = net.structure.populations(n);
count = length(pop.indices);
name = pop.name;
pars = pop.pars;


% create node parameter arrays
fields = {'V_min','V_refractory','V_threshold','t_refractory','tau_membrane','I_spontaneous'};
for f=1:length(fields)
	
	key = fields{f};
	if ~isfield(pars,key)
		error(['Parameter "' key '" not supplied for population "' name '"']);
	end
	val = getfield(pars,key);
	
	if isscalar(val)
		unity_in_correct_class = cast(1, class(val));
		val = val * repmat(unity_in_correct_class, length(pop.indices), 1);
	else
		if ~strcmp(key,'locs')
			if prod(size(val)) ~= pop.count
				error('number of parameters supplied does not match number of nodes requested');
			end
			val = reshape(val,count,1); % in case they've been passed as a matrix of size "dims"
		end
	end

	existing_val = getfield(net.node, key);
	new_val = [existing_val; val];
	net.node = setfield(net.node, key, new_val);
	
end




% indices = interpretCurrentType(currentType)
%
% if currentType is a string, it will be interpreted either as a
% known receptor type or as a known current description. if it is an
% index, it will be used as is. known receptor types and current
% descriptions are:
%
%   * (0) fastinh GABAA
%   * (1) fastexc AMPA
%   * (2) slowinh GABAB
%   * (3) slowexc NMDA

function currentType = interpretCurrentType(currentType)

if ischar(currentType)
	switch(lower(currentType))
		case {'fastinh','gabaa'}
			currentType = 0;
		case {'fastexc','ampa'}
			currentType = 1;
		case {'slowinh','gabab'}
			currentType = 2;
		case {'slowexc','nmda'}
			currentType = 3;
			
			% not in the standard!
		case {'midinh'}
			currentType = 4;
		case {'midexc'}
			currentType = 5;
		otherwise
			error(['Unrecognised current type "' currentType '"']);
	end
else
	if ~isnumeric(currentType)
		error('Current type should be numeric or a string');
	end
	if ~isscalar(currentType)
		error('Current type should be scalar or a string');
	end
	if currentType < 0 | currentType > 255 | currentType ~= floor(currentType)
		error('Current type should be an integer in 0-255 or a string');
	end
	currentType = uint8(currentType);
end





