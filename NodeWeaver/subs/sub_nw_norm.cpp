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
%	$Id::                                          $
%	$Rev::                                         $
%	$Author::                                      $
%	$Date::                                        $
% ________________________________________________
%
*/

#include <mex.h>
#include <math.h>
#include <vector>
using namespace std;

#define MAXIND prhs[0]
#define IND prhs[1]
#define W prhs[2]

#define WOUT plhs[0]

typedef unsigned int UINT32;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	UINT32 maxind = *mxGetPr(MAXIND);

	UINT32 Nind = mxGetM(IND);
	UINT32* ind = (UINT32*)mxGetData(IND);

	double* w = mxGetPr(W);
	UINT32 Nw = mxGetM(W);

	WOUT = mxDuplicateArray(W);
	double* wout = mxGetPr(WOUT);

	vector<double> sum(maxind + 1); // zeroth not used

	for (UINT32 i=0; i<Nw; i++)
	{
		sum[ind[i]] += w[i];
	}

	for (UINT32 i=0; i<Nw; i++)
	{
		wout[i] = w[i] / sum[ind[i]];
	}

}
