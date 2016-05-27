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

#define USAGE_STRING "Usage: S = mex_sepsq(X,Y)"

#include <mex.h>
#include <math.h>

void usage()
{
	printf("%s\n", USAGE_STRING);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	//
	//	Compute ||x-y||^2 for each pairing x,y of X,Y.
	//
	//	X and Y should be matrices of column vectors, hence D x M and D x N
	//

	if (nrhs != 2) { usage(); mexErrMsgTxt("Requires two input arguments"); }
	if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1])) { usage(); mexErrMsgTxt("Input arguments must be double type"); }

	//
	//	Get Sizes
	//
	
	int D = mxGetM(prhs[0]);
	int M = mxGetN(prhs[0]);
	int N = mxGetN(prhs[1]);
	if (D != mxGetM(prhs[1])) { usage(); mexErrMsgTxt("Input arguments must have same number of rows"); }

	//
	//	Construct output matrix
	//

	plhs[0] = mxCreateDoubleMatrix(M,N,mxREAL);

	//
	//	Do Job
	//

	double temp, accum;
	double *X = mxGetPr(prhs[0]);
	double *Y = mxGetPr(prhs[1]);
	double *S = mxGetPr(plhs[0]);

	for (int m=0; m<M; m++)
	{
		for (int n=0; n<N; n++)
		{
			accum = 0.0;
			for (int d=0; d<D; d++)
			{
				temp = X[d + m * D] - Y[d + n * D];
				accum += temp * temp;
			}
			S[m + n * M] = accum;
		}
	}

}
