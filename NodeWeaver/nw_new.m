%
% net = nw_new(type, name, ...)
%
% create a new network with specified type and
% name. additional arguments are passed to the net
% constructor for that type of net.
%
% you will typically call net_new() to construct a
% new network, nw_addInput() zero or more times to
% add input sources, nw_addPop() one or more times
% to add populations, nw_addProj() to connect them
% together and to the inputs, nw_setOutputs() to
% specify what will be presented at the output,
% and finally nw_compile() to compile the finished
% network into a form suitable for execution.
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
% $Id:: nw_new.m 52 2008-05-25 12:46:52Z benjmit#$
% $Rev:: 52                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 13:46:52 +0100 (Sun, 25 May#$
% ________________________________________________
%


function net = nw_new(type, name, varargin)

% empty net
net = [];
net.stateml_write = 'nw_netml_write';

% basic parameters of a net are its type and name:
net.head.what = 'NetML Network';
net.head.authTool = 'NodeWeaver';
net.head.authToolVersion = nw_utils('VersionString');
net.head.type = type;
net.head.name = name;
net.head.compiled = false;
% net.head.precision = 4; % default precision is now set by
% sml_system, to 6 SFs i think

% all networks then may define global parameters, parameters of
% each node, connectivity:
net.global = [];
net.node = [];
net.projections = [];

% inputs, network, and outputs all share a structure format that
% describes them:
net.structure.inputs = struct([1:0]);
net.structure.populations = struct([1:0]);
net.structure.outputs = struct([1:0]);

% flags allow particular network types to mark their features to
% generic code
net.weavingPars.compactDiffuse = 0; % assume compact diffuse unsupported

% call constructor
netfunc = ['sub_nw_node_' net.head.type];
if ~exist(netfunc,'file') error('cannot find this net type'); end
net = feval(netfunc, net, 'construct', varargin{:});

