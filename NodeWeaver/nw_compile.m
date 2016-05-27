%
% net = nw_compile(net, ...)
%
% This function should be run on a net before it
% is added to a system. It will compile the raw
% array of links generated by adding projections
% into an optimised array for execution.
%
% "target" should be the target engine type,
% either "zero" or "one" to indicate whether the
% engine expects zero-based or one-based indices.
% "zero" is default if unsupplied.
%
% Any links with weight smaller than min_weight
% will not be included.
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
% $Id:: nw_compile.m 53 2008-05-25 13:05:59Z ben#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%

function net = nw_compile(net, varargin)

if net.head.compiled
	warning('network is already compiled in nw_compile() - no action taken');
	return
end

if ~sub_nw_isNetwork(net)
	error('first argument should be a nodeweaver network');
end

% just pass to the appropriate compiler
netfunc = ['sub_nw_node_' net.head.type];
if ~exist(netfunc,'file') error('cannot find this net type'); end
net = feval(netfunc, net, 'compile', varargin{:});

% remove flags
net = rmfield(net,'weavingPars');

% 5 dec 2007 (mitch)
% changed this since i fixed up MatML, this doesn't make any sense anymore!
%
% % in compiled form, we are XML-ready
% x = net.projections;
% net.projections = [];
% if ~isempty(x) % don't want any XML generated if there aren't any
% 	net.projections.projection = x;
% end
% 
% x = net.structure.inputs;
% net.structure.inputs = [];
% net.structure.inputs.set = x;
% 
% x = net.structure.populations;
% net.structure.populations = [];
% net.structure.populations.set = x;
% 
% x = net.structure.outputs;
% net.structure.outputs = [];
% net.structure.outputs.set = x;

if isempty(net.global)
	net.global = struct;
end

% set state
net.head.compiled = true;


