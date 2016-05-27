/*
% ________________________________________________
%
%	This file is part of NodeWeaver
%	Copyright (C) 2007 Ben Mitch(inson)
%	URL: http:sourceforge.net/projects/nodeweaver
%
%	This program is free software; you can
%	redistribute it and/or modify it under the terms
%	of the GNU General Public License as published
%	by the Free Software Foundation; either version
%	2 of the License, or (at your option) any later
%	version.
%
%	This program is distributed in the hope that it
%	will be useful, but WITHOUT ANY WARRANTY;
%	without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR
%	PURPOSE.  See the GNU General Public License
%	for more details.
%
%	You should have received a copy of the GNU
%	General Public License along with this program;
%	if not, write to the Free Software Foundation,
%	Inc., 51 Franklin Street, Fifth Floor, Boston,
%	MA  02110-1301, USA.
% ________________________________________________
%
%	Subversion Repository Information
%
%	$Id:: version.h 59 2008-08-07 21:13:02Z benjmi#$
%	$Rev:: 59                                      $
%	$Author:: benjmitch                            $
%	$Date:: 2008-08-07 22:13:02 +0100 (Thu, 07 Aug#$
% ________________________________________________
%
*/



#ifndef INCLUDED_NODEWEAVER_VERSION
#define INCLUDED_NODEWEAVER_VERSION

struct Version
{
	Version(UINT16 release, UINT16 revision)
	{
		this->release = release;
		this->revision = revision;
	}

	UINT16 release;
	UINT16 revision;
}


const Version VERSION_NODEWEAVER(0, __REVISION__)


#endif



