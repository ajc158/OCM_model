%
% nw_demo(name)
%
% nodeweaver demos - currently the argument is
% ignored, and a single LIN demo is generated.
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



function [out, sys, sim] = nw_demo(name)



% BRAHMS demonstration script
% Author: mitch
% Created: 7 Mar 2007
% Coolness: Massive
%
% this script will create a very simple leaky integrator
% network (LIN) using my procedural network scripting
% language, and run it using BRAHMS. the network has three
% populations, takes one input, and has no feedback. try
% adding some by uncommenting the feedback line, and see
% things go just downright crazy wild and out of control.

% demo parameters
num_channels = 50;
t_stop = 1;
fS = 1000;
num_samples = fS * t_stop;
sigma = num_channels / 10;

% add abrg-net tools to path
if ~exist('nw_new')
	error('NodeWeaver not installed');
end

% construct interfaceable input to proposed network using
% provided shortcut function (this input will look to the
% receiving network like another network generating an
% output - this approach needs generalising...!)
%
% all off, but one channel is on constantly...
data = zeros(num_channels, 1);
data(round(num_channels/3),:) = 1;
% 		src = nw_sourceDouble(data, 'src', 'out', [num_channels]);

% construct network (see "help nw_new")
net = nw_new('lin', 'network');

% set up standard parameters (see "help subnw__lin")
pars = [];
pars.tau_membrane = 0.1;
pars.nonlin = 'hard2';
pars.m = 1;
pars.c = 0;
pars.p = 1;
pars.sigma_membrane = 0.0;

% add some populations (see "help nw_addPop")
net = nw_addPop(net, 'A', [num_channels], pars);
net = nw_addPop(net, 'B', [num_channels], pars);
net = nw_addPop(net, 'C', [num_channels], pars);

% add some intrinsic projections (see "help nw_addProj")
net = nw_addProj(net, 'A', 'B', 8, 'gaussian', 'sigma', sigma, 'delay=0.1');
net = nw_addProj(net, 'A', 'C', 20, '!gaussian', 'sigma', sigma*2, 'delay=0.2');

% feedback line
% net = nw_addProj(net, 'C', 'A', 0.1, 'uniform');

% add an input from the source we set up
net = nw_addInput(net, 'src_out', [num_channels]);

% add an extrinsic projection (from this newly added input
% to the first layer of the network)
net = nw_addProj(net, '>src_out', 'A', 1, 'onetoone', 'delay=0.1');

% mark which populations should be output
net = nw_setOutputs(net, 'all');

% build BRAHMS system
sys = [];

% build BRAHMS process to represent network
process = [];
process.class = 'dev/neural/leakyIntegratorNetwork';
process.state = net;
process.sampleRate = fS;
sys.lin = process;

% build BRAHMS process to represent source
process = [];
process.class = 'dev/stdlib/sourceNumeric';
process.state.data = data;
process.state.repeat = true;
process.state.ndims = 1;
process.sampleRate = fS;
sys.src = process;

% connect the two together
link = [];
link.src = 'src>out';
link.dst = 'lin<src_out';
sys.link = link;

% build BRAHMS simulation
sim = [];
sim.simulationEndTime = t_stop;
sim.outputs = true;
sim.threads = false;

% call BRAHMS
sys = sml_convertoldsystem(sys);
out = brahms(sys, sim);

% report
clf
subplot(3,1,1)
image(63*out.lin.network_A)
subplot(3,1,2)
image(63*out.lin.network_B)
subplot(3,1,3)
image(63*out.lin.network_C)
colormap hot



