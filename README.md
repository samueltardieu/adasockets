README file for adasockets.

AdaSockets is a medium binding (it is not a thin binding because it uses Ada
types and not a thick binding because you have the same subprogram names as
in C) for using BSD-style sockets in Ada.

Since the original release, I have been adding multicast and fixed some
bugs. However, it is likely that others remain.

To use AdaSockets with gnatmake once installed, type:

% gnatmake `adasockets-config` ...

The `adasockets-config` part will add the correct options to gnatmake command
line.

AdaSockets is free software; you can redistribute it and/or modify it
under terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later
version.  AdaSockets is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.  You should have received a
copy of the GNU General Public License distributed with AdaSockets;
see file COPYING.  If not, write to the Free Software Foundation, 59
Temple Place - Suite 330, Boston, MA 02111-1307, USA.

As a special exception, if other files instantiate generics from this
unit, or you link this unit with other files to produce an executable,
this unit does not by itself cause the resulting executable to be
covered by the GNU General Public License.  This exception does not
however invalidate any other reasons why the executable file might be
covered by the GNU Public License.

The main repository for this software is located at:
    http://www.rfc1149.net/devel/adasockets

Please report any issues or address any question to the issues tracker
on GitHub, located at:
    https://github.com/samueltardieu/adasockets/issues
                                                                   
The author, Samuel Tardieu <sam@rfc1149.net>