%
% net = nw_addProj(net, src, dst, weight, ...)
%
% 'src' and 'dst' can be anything accepted by
% nw_getSet. 'weight' is the total weight for some
% set of connections, dependent on the
% normalisation technique, described below.
%
% further arguments are either: parameter/value
% pairs, that can be specified as a string
% ('par=val'), as an argument pair (..., 'par',
% val, ...) or, in the case of 'expected' string
% values, just by passing the value (..., val,
% ...); or flags, which are just string arguments.
%
% if the compiler for this network type requires
% additional arguments, pass a single cell array
% containing them in a comma-separated list.
% ________________________________________________
%
% dist:
%   one of 'onetoone', 'gaussian or 'diffuse'
%   (synonym 'uniform'). for 'onetoone',
%   populations must have identical dimensions
%   (dims). for 'gaussian', Euclidean distance
%   between nodes is used, and trailing dimensions
%   are discarded in a population of higher
%   dimension; specify 'sigma' either as a scalar
%   for use in all dimensions, or as a vector with
%   an element for each dimension. use sigma
%   values of zero or infinity if appropriate.
%   some projections may be inverted by prepending
%   '!' to their name. all these strings are
%   'expected'.
%
% delay:
%   a scalar time delay in seconds (default zero).
%
% norm:
%   the normalisation technique, for normalisation
%   over efferents/afferents/projection, use
%   'eff'/'aff'/'proj' - to disable normalisation,
%   specify 'none'. 'effx'/'affx' are as
%   'eff'/'aff', but they use the same
%   normalisation factor for all connections,
%   being the maximum normalisation factor
%   computed across all eff/aff sets, thereby
%   eliminating edge effects. the default is
%   'affx'. all these strings are 'expected'.
%
% minw:
%   weights smaller than minw * the largest weight
%   will be culled (default 0.01).
%
% decimate:
%   scalar between 0 and 1, fraction of links to
%   be culled at random (default 0).
%
% step:
%   positive integer controlling regular culling -
%   only links with index differences of multiples
%   of step in all dimensions are included. like
%   'onetoone', step therefore requires
%   identically dimensioned populations. step=2,
%   for instance, will cull 3 of every 4 links in
%   a 2D population (default 1).
%
% 'report' [FLAG]:
%   if present, the process is reported to
%   console.
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
% $Id:: nw_addProj.m 57 2008-07-31 10:34:45Z ben#$
% $Rev:: 57                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-07-31 11:34:45 +0100 (Thu, 31 Jul#$
% ________________________________________________
%

function net = nw_addProj(net, src, dst, weight, varargin)

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end



if nargin<4 || ~(ischar(src) || iscell(src)) || ~(ischar(dst) || iscell(dst)) || ~isnumeric(weight)
	error('invalid call, see help');
end

% interpret arguments
args.dist = '';
args.delay = 0;
args.norm = 'affx';
args.minw = 1e-2;
args.decimate = 0;
args.step = 1;
args.report = false;
args.compilerargs = {};
expects = { 'dist',{'gaussian','!gaussian','onetoone','!onetoone','diffuse','uniform', 'Mux', 'DMux', 'manual'}, 'norm',{'eff','aff','proj','none','effx','affx'} };
flags = {'report'};
args = interpretArgs(varargin, args, expects, flags);

% convert synonyms
if strcmp(args.dist,'uniform') args.dist = 'diffuse'; end

% check required argas
if isempty(args.dist) error('projection distribution not specified'); end

% convert src and dst descriptors into real src and dst
src = nw_getSet(net, src);
dst = nw_getSet(net, dst);
if isfield(dst,'input') error('dst cannot be an input'); end

src.count = length(src.indices);
dst.count = length(dst.indices);



% generate distribution
if args.dist(1) == '!'
	args.invert = true;
	args.dist = args.dist(2:end);
else
	args.invert = false;
end


% switch on distribution type and call the appropriate dist func
distfunc = ['sub_nw_dist_' args.dist];
if ~exist(distfunc,'file') error(['unrecognised distribution "' args.dist '"']); end
args.compactDiffuse = net.weavingPars.compactDiffuse;
[W,srci,dsti] = feval(distfunc,src,dst,args);
compact = isscalar(W) & (~isscalar(srci) | ~isscalar(dsti));


% cull by step
if isfield(args,'step') & args.step ~= 1
	
	if compact error('"step" illegal with compact projections'); end
	error('disabled - code needs updating for new W format');
	
	if length(src.dims)~=length(dst.dims) | any(src.dims~=dst.dims)
		error('layers must have identical dims for cull-by-step');
	end
	
	N = prod(double(src.dims));
	Y = repmat((1:src.dims(1))',src.dims(2),1);
	X = reshape(repmat((1:src.dims(2)),src.dims(1),1),N,1);
	
	Ysrc = repmat(Y,1,N);
	Xsrc = repmat(X,1,N);
	Xsep = Xsrc - Xsrc'; % transpose is Xdst
	Ysep = Ysrc - Ysrc'; % transpose is Ydst
	
	Xsep = Xsep / args.step;
	Ysep = Ysep / args.step;
	
	Xcull = Xsep ~= round(Xsep);
	Ycull = Ysep ~= round(Ysep);
	
	W(Xcull | Ycull) = 0;
end


% cull by weight
if args.minw > 0 & ~compact
	minW = max(max(W)) * args.minw;
	r = find(W >= minW);
	W = W(r);
	srci = srci(r);
	dsti = dsti(r);
end



% cull by decimation
if args.decimate > 0
	if compact error('"decimate" illegal with compact projections'); end
	r = rand(size(W)) >= args.decimate;
	W = W(r);
	srci = srci(r);
	dsti = dsti(r);
end


% normalise
switch(args.norm)
	
	case 'none'
		% no normalisation
	
	case 'aff'
		% normalise sum of weights to a single receiving node - this
		% normalisation will tend to maintain the same firing rate in
		% the receiving nucleus regardless of the granularisation of
		% the model
		if compact
			W = W / dst.count;
		else
			W = sub_nw_norm(dst.count,uint32(dsti),W);
		end
		
	case 'eff'
		if compact
			W = W / src.count;
		else
			W = sub_nw_norm(src.count,uint32(srci),W);
		end
		
	case 'affx'
		if compact
			W = W / dst.count;
		else
			W = sub_nw_normx(dst.count,uint32(dsti),W);
		end
		
	case 'effx'
		if compact
			W = W / src.count;
		else
			W = sub_nw_normx(src.count,uint32(srci),W);
		end
		
	case 'proj'
		if compact
			W = W / dst.count / src.count;
		else
			W = W / sum(sum(W));
		end
		
	otherwise
		error(['unrecognised normalisation "' args.norm '"'])
		
end


% convert population indices into network indices
srci = src.indices(srci);
dsti = dst.indices(dsti);


% apply weight
W = W * weight;


% check shape is good now
if size(W,2) > 1
	W = reshape(W,prod(size(W)),1);
	srci = reshape(srci,prod(size(srci)),1);
	dsti = reshape(dsti,prod(size(dsti)),1);
end


% report?
if args.report
	persrc = [];
	for n=1:src.count
		persrc(n) = sum(srci==src.indices(n));
	end
	perdst = [];
	for n=1:dst.count
		perdst(n) = sum(dsti==dst.indices(n));
	end
	rsrc = range(persrc);
	rsrc.mean = round(rsrc.mean);
	rdst = range(perdst);
	rdst.mean = round(rdst.mean);
	disp(sprintf('[%i-(%i-%i-%i)-%i] links per src,\n[%i-(%i-%i-%i)-%i] links per dst,\n%i total links', rsrc.min, rsrc.ltail, rsrc.mean, rsrc.utail, rsrc.max, rdst.min, rdst.ltail, rdst.mean, rdst.utail, rdst.max, length(srci)));
	disp(sprintf('max weight is: %f\n', max(max(max(abs(W))))));
end


% input index
if strcmp(src.type, 'input')
	proj.intrinsic = 0;
else
	proj.intrinsic = 1;
end


proj.src = srci;
proj.dst = dsti;
proj.weight = W;
proj.delay = args.delay;
proj.pars = args.compilerargs; % node-specific pars, to be handled by compiler



% add to network
if isempty(net.projections)
	net.projections = proj;
else
	net.projections(end+1) = proj;
end






function args = interpretArgs(argsIn, args, expects, flags)

%
% args = interpretArgs(argsIn, args, expects, flags)
%
% args, if supplied, is used instead of an empty structure as a
% starting point (i.e. it can be used to supply default
% arguments).
%
% when argsIn is a cell array of strings of the form 'key=val',
% args is returned as a structure of the form args.key=val - for
% instance, try args = interpretArgs(varargin) in a function. if
% there is no equals sign in the string, the following procedure
% is followed in order:
%
% 1) expects should be a cell array of size 1x2N, which defines N
% pairs:
%
%  {expected_key_1, {expected_string_1, expected_string_2, ...}, ...}
%
% if an element of argsIn matches an expected_string, it is
% assigned to args as 'expected_key=expected_string'.
%
% 2) flags should be a cell array of size 1xN, which defines N
% keys that, if matched, will be assigned into args as 'key=1'.
% that is, they represent flags.
%
% 3) otherwise, the next element of argsIn is assumed to be the
% val to the current element's key. this allows the passing of
% arguments through interpretArgs that cannot be represented as a
% string.
%
% example - if the arguments are as follows:
%
% argsIn = {'key1=13.6','key2=[1 2; 3 4]','expected1','flag2','key3',<struct>}
% args = struct('key2','default_val2','flag2',0)
% expects = {'key4',{'expected1','expected2'}}
% flags = {'flag1','flag2'}
%
% the returned structure will be:
% 
%   args = 
% 
%      key2: [2x2 double]
%      key1: 13.6000
%      key4: 'expected1'
%     flag2: 1
%      key3: [1x1 struct]
		 
argIndex = 1;
if ~exist('args','var') args = []; end
if ~exist('expects','var') expects = {}; end
if ~exist('flags','var') flags = {}; end

while argIndex <= length(argsIn)
	
	arg = argsIn{argIndex};
	
	if iscell(arg)
		% compiler arguments
		args.compilerargs = arg;
		argIndex = argIndex + 1;
		continue;
	end
	
	if ~ischar(arg)
		disp(arg)
		error('expected a string argument here');
	end
	
	if ndims(arg)~=2 | size(arg,1)~=1
		error('expected a 1xN string');
	end
	
	f = find(arg == '=');
	
	if isempty(f)
		key = arg;
		val = [];
		% expected string?
		for n=2:2:length(expects)
			vals = expects{n};
			for m=1:length(vals)
				if strcmp(arg,vals{m})
					val = arg;
					key = expects{n-1};
					break;
				end
			end
		end
		% no, flag?
		if isempty(val)
			for n=1:length(flags)
				if strcmp(key,flags{n})
					val = 1;
					break;
				end
			end
		end
		% no, following argument
		if isempty(val)
			argIndex = argIndex + 1;
			if argIndex > length(argsIn)
				error('expected an additional argument');
			end
			val = argsIn{argIndex};
		end
	else
		key = arg(1:f(1)-1);
		val = arg(f(1)+1:end);
		% interpret
		res = str2num(val);
		if ~isempty(res)
			val = res;
		end
		% interpret
	end
	
	args.(key) = val;
	
	argIndex = argIndex + 1;
	
end



function out = range(in, tailsize)

% displays the minimum and maximum of a vector or matrix

minimum=in;
while(1)
	minimum=min(minimum);
	s=size(minimum);
	if s(1)==1 & s(2)==1 break; end
end

maximum=in;
while(1)
	maximum=max(maximum);
	s=size(maximum);
	if s(1)==1 & s(2)==1 break; end
end

mn=in;
while(1)
	mn=mean(mn);
	s=size(mn);
	if s(1)==1 & s(2)==1 break; end
end

if nargin<2
	tailsize = 0.05;
else
	tailsize = tailsize / 100;
end

s=size(in);
r=reshape(in,prod(s),1);
srt=sort(r);
l=length(srt);
ltail=round(tailsize * l+1);
utail=round((1-tailsize) * l);
rng = (1-2*tailsize)*100;

out = [];
out.mean = mn;
out.min = minimum;
out.max = maximum;
out.ltail = srt(ltail);
out.utail = srt(utail);

