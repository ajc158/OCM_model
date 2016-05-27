
% THIS IS NOT A USER FUNCTION
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

function locs = sub_nw_expandLocs(dims, locs)

count = prod(double(dims));
D = length(dims);
if isempty(locs)
	locs = {[0.5*ones(1,D); dims+0.5]};
end

% construct locs
if iscell(locs)
	locs = locs{1};
	if size(locs,1)==1
		locs = [0*locs; locs];
	end
	if size(locs,1)~=2 | size(locs,2)<1
		error('locs is of bad size');
	end
	I = (1:dims(1))';
	for n=2:length(dims)
		J = I;
		I = [];
		M = ones(size(J,1),1);
		for m=1:dims(n)
			I = [I; [J m*M]];
		end
	end
	L = size(locs,2);
	I = I(:,1:L);
	dlocs = diff(locs,1);
	I = (I - 0.5) ./ repmat(dims(1:L),count,1) .* repmat(dlocs,count,1);
	locs = I + repmat(locs(1,:),count,1);
end

if size(locs,1) ~= count
	error('dims does not match locs in size');
end

% convert to float
locs = single(locs);
