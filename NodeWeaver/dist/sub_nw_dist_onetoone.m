
% THIS IS NOT A USER FUNCTION
% see sub_nw_addProj
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

function [W,srci,dsti] = netdist(src,dst,args)

if length(src.dims)~=length(dst.dims) | any(src.dims~=dst.dims)
	error('layers must have identical dims for onetoone projection');
end
if args.invert
	% to allow invert, we have to this representation
	srci = repmat((1:src.count)',1,dst.count);
	dsti = repmat((1:dst.count),src.count,1);
	W = 1 - eye(src.count);
else			
	% if not inverting, we can use a smaller representation,
	% allowing much larger networks to use this type
	srci = (1:src.count)';
	dsti = (1:dst.count)';
	W = ones(size(srci));
end

