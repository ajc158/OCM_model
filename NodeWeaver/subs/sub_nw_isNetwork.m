% NOT A USER FUNCTION

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

function is = func(net)

is = false;

if ~isstruct(net) return; end
if ~isfield(net, 'head') return; end
if ~isfield(net.head, 'what') return; end
if ~strcmp(net.head.what, 'NetML Network'); return; end

if net.head.compiled
	error('you cannot operate further on a compiled network');
end

is = true;
