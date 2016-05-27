%
% lin_plotOutputFunc(c,m)
%
% see what the LIN network output function looks
% like with c and m as specified, for any of the
% output non-linear models
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

function lin_plotOutputFunc(c,m)

x=-2:0.01:5;

y=(x-c)*m;

nonneg=@(x)(x-x.*double(x<0));
nonpos=@(x)(x-(x-1).*double(x>1));
johnsub=@(x)((x.^2)./(0.25+x.^2));

john=@(x)(double(x>0).*johnsub(x));
hard1=@(x)(nonneg(x));
hard2=@(x)(nonpos(nonneg(x)));

plot(x,hard1(y),'k')
hold on
plot(x,hard2(y),'b')
plot(x,nonneg(tanh(y)),'r')
plot(x,john(y),'g')
hold off
grid

legend('hard1','hard2','soft1','soft2',4)
xlabel('input')
ylabel('output')
v = axis;
axis([v(1:2) -0.2 2])
