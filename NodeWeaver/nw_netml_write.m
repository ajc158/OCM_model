%
% [writer, xml] = nw_netml_write(writer, net)
%
%   NetML writer provided by NodeWeaver to convert
%   a NodeWeaver network into a NetML network. The
%   function also performs the "compile" of the
%   network in advance of the serialization.
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
% $Id:: nw_netml_write.m 53 2008-05-25 13:05:59Z#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%


function [writer, xml] = nw_netml_write(writer, net)

writer.write.attr.DelegatingFormat = 'NetML';
writer.write.attr.DelegatingVersion = '1.0';
writer.write.attr.DelegatingAuthTool = 'NodeWeaver';
writer.write.attr.DelegatingAuthToolVersion = nw_utils('VersionString');

if isfield(net.head, 'precision')
	writer.write.precision = net.head.precision;
end

net = rmfield(net, 'stateml_write');
net = nw_compile(net);
[writer, xml] = sml_matml(writer, net);


