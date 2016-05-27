
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

if isfield(args,'compactDiffuse') & args.compactDiffuse
	srci = (1:src.count)';
	dsti = (1:dst.count)';
	W = 1;
else
	srci = repmat((1:src.count)',1,dst.count);
	dsti = repmat((1:dst.count),src.count,1);
	W = ones(src.count,dst.count);
end
if args.invert error('cannot invert this distribution'); end
