%
% nw_utils
%
%   Without arguments, reports the status of the
%   NodeWeaver installation (and adds it to path).
%
% ver = nw_utils('Version')
%
%   Returns the version of the installed NodeWeaver,
%   as a vector.
%
% ver = nw_utils('VersionString')
%
%   Returns the version of the installed NodeWeaver,
%   as a string.
%
% 
% ________________________________________________
%
% NodeWeaver is a tool for generating neural-style
% networks of interconnected nodes. Networks are
% specified in terms of populations of spatially
% localised nodes and the projections between them.
% Projections can be specified with respect to the
% spatial location of nodes, allowing biologically
% realistic specifications. Where the populations
% model is insufficiently detailed, finer control
% is available.
%
% The models are built in NetML, which is a StateML
% in the SystemML computation framework. Thus, the
% models produced can be computed by any SystemML
% execution engine (e.g. BRAHMS).
%
% NodeWeaver is extensible, through the addition of
% further node and projection types, so it can be
% modified to specify a new type of network whilst
% keeping the advantage of a generic framework for
% handling neural-style nets.
%
% Run "nw_utils" to add NodeWeaver to your matlab
% path. Then enter "nw" at the prompt and hit TAB
% to see a list of possibilities.
% ________________________________________________
%
% This software is licensed under the GNU GPL. For
% details and terms of use, see this source file.

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
% $Id:: nw_utils.m 53 2008-05-25 13:05:59Z benjm#$
% $Rev:: 53                                      $
% $Author:: benjmitch                            $
% $Date:: 2008-05-25 14:05:59 +0100 (Sun, 25 May#$
% ________________________________________________
%




function out = nw_utils(varargin)

if ~nargin
	
	path = fileparts(which('nw_utils'));
	addpath(path)
	addpath([path filesep 'dist'])
	addpath([path filesep 'extras'])
	addpath([path filesep 'nodes'])
	addpath([path filesep 'subs'])
	disp(['NodeWeaver Version ' nw_utils('VersionString') ' is installed'])
	
else
	
	switch varargin{1}

		case 'VersionString'
			
			v = nw_utils('Version');
			out = [int2str(v(1)) '.' int2str(v(2))];
		
		case {'Version'}

			% extract version from ../version.h
			out = [];
			path = fileparts(which('nw_utils'));
			fid = fopen([path '/version.h'], 'r');
			if fid == -1 error('failed open version.h'); end
			while ~feof(fid)
				line = fgetl(fid);
				f = strfind(line, '$Rev::');
				if ~isempty(f)
					Revision = sscanf(line(f + 6:end), '%i');
					if isempty(Revision)
						% warning('parse of version.h failed (revision not formatted correctly - using zero)');
						Revision = 0;
					end					
					continue;
				end
				f = strfind(line, 'VERSION_NODEWEAVER(');
				if ~isempty(f)
					if ~exist('Revision', 'var')
						fclose(fid);
						error('parse of version.h failed (revision not found)');
					end
					out = [sscanf(line(f + 19:end), '%i') Revision];
					fclose(fid);
					return;
				end
			end
			fclose(fid);
			error('parse of version.h failed (version not found)');
			
		otherwise
			
			error('unrecognised option');
			
	end
end


