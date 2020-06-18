-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                       S O C K E T S . U T I L S                         --
--                                                                         --
--                                S p e c                                  --
--                                                                         --
--          Copyright (C) 1998-2020 Samuel Tardieu <sam@rfc1149.net>       --
--                 Copyright (C) 1999-2003 Télécom ParisTech               --
--                                                                         --
--   AdaSockets is free software; you can  redistribute it and/or modify   --
--   it  under terms of the GNU  General  Public License as published by   --
--   the Free Software Foundation; either version 2, or (at your option)   --
--   any later version.   AdaSockets is distributed  in the hope that it   --
--   will be useful, but WITHOUT ANY  WARRANTY; without even the implied   --
--   warranty of MERCHANTABILITY   or FITNESS FOR  A PARTICULAR PURPOSE.   --
--   See the GNU General Public  License  for more details.  You  should   --
--   have received a copy of the  GNU General Public License distributed   --
--   with AdaSockets; see   file COPYING.  If  not,  write  to  the Free   --
--   Software  Foundation, 59   Temple Place -   Suite  330,  Boston, MA   --
--   02111-1307, USA.                                                      --
--                                                                         --
--   As a special exception, if  other  files instantiate generics  from   --
--   this unit, or  you link this  unit with other  files to produce  an   --
--   executable,  this  unit does  not  by  itself cause  the  resulting   --
--   executable to be  covered by the  GNU General Public License.  This   --
--   exception does  not  however invalidate any  other reasons  why the   --
--   executable file might be covered by the GNU Public License.           --
--                                                                         --
--   The main repository for this software is located at:                  --
--       http://www.rfc1149.net/devel/adasockets.html                      --
--                                                                         --
--   If you have any question, please use the issues tracker at:           --
--       https://github.com/samueltardieu/adasockets/issues                --
--                                                                         --
-----------------------------------------------------------------------------

with Interfaces.C;

private package Sockets.Utils is

   pragma Elaborate_Body;

   procedure Raise_With_Message (Message    : String;
                                 With_Errno : Boolean := True);
   pragma No_Return (Raise_With_Message);
   --  Raise Socket_Error with an associated error message

   function Port_To_Network (Port : Interfaces.C.unsigned_short)
     return Interfaces.C.unsigned_short;
   pragma Inline (Port_To_Network);

   function Network_To_Port (Port : Interfaces.C.unsigned_short)
     return Interfaces.C.unsigned_short
     renames Port_To_Network;

   function "*" (Left : String; Right : Natural) return String;
   pragma Inline ("*");
   --  Return Left string repeated Right times

   function Is_IP_Address (Something : String)
     return Boolean;
   --  Return True if the name looks like an IP address, False otherwise

end Sockets.Utils;
