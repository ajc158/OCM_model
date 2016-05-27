
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

% generate cache name
if false & iscell(src.locs) & iscell(dst.locs)
	cache = [getenv('temp') filesep 'distnw_gaussian'];
	cache = [cache '_' int2str(src.count)];
	for n=1:length(src.dims) cache = [cache '-' int2str(src.dims(n))]; end
	srclocs = src.locs{1};
	for n=1:prod(size(srclocs)) cache = [cache '.' int2str(srclocs(n))]; end
	cache = [cache '_' int2str(dst.count)];
	for n=1:length(dst.dims) cache = [cache '-' int2str(src.dims(n))]; end
	dstlocs = dst.locs{1};
	for n=1:prod(size(dstlocs)) cache = [cache '.' int2str(dstlocs(n))]; end
	cache = [cache '#' int2str(args.invert) '-' num2str(args.minw) '-' num2str(args.sigma)];
	cache = [cache '.cache'];
else
	cache = '';
end

% is cached?
if exist(cache,'file')
	disp('loading cache')
	load(cache,'-mat')
	return
end

% do it
src.locs = sub_nw_expandLocs(double(src.dims), src.locs);
dst.locs = sub_nw_expandLocs(double(dst.dims), dst.locs);

if ~isfield(args,'sigma') error('this distribution requires a parameter "sigma"'); end
nd = min(size(src.locs,2),size(dst.locs,2));
src.locs = src.locs(:,1:nd);
dst.locs = dst.locs(:,1:nd);
if prod(size(args.sigma))==1
	args.sigma = repmat(args.sigma,1,nd);
end
if any(size(args.sigma)~=[1 nd]) error('sigma is wrong size'); end
for n=1:nd
	if args.sigma(n) == 0 args.sigma(n) = eps * 1e2; end
	src.locs(:,n) = src.locs(:,n) / args.sigma(n);
	dst.locs(:,n) = dst.locs(:,n) / args.sigma(n);
end

% do it in blocks so as not to overflow memory
srci = [];
dsti = [];
W = [];
block = 1000;
for srcst=1:block:src.count
	for dstst=1:block:dst.count
		srced = srcst + block - 1;
		dsted = dstst + block - 1;
		if srced > src.count srced = src.count; end
		if dsted > dst.count dsted = dst.count; end
		srccount = srced - srcst + 1;
		dstcount = dsted - dstst + 1;
		srciblock = repmat((srcst:srced)',1,dstcount);
		dstiblock = repmat((dstst:dsted),srccount,1);
		SSblock = sub_nw_sepsq(double(src.locs(srcst:srced,:)'),double(dst.locs(dstst:dsted,:)'));
		Wblock = exp(-SSblock);
		if args.invert Wblock = 1-Wblock; end
		r = find(Wblock >= args.minw);
		W = [W; Wblock(r)];
		srci = [srci; srciblock(r)];
		dsti = [dsti; dstiblock(r)];
	end
end

% store to cache
if ~isempty(cache)
	save(cache,'W','srci','dsti','-v6')
end



