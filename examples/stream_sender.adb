-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                       S T R E A M _ S E N D E R                         --
--                                                                         --
--                                B o d y                                  --
--                                                                         --
--          Copyright (C) 1998-2007 Samuel Tardieu <sam@rfc1149.net>       --
--               Copyright (C) 1999-2003 ENST http://www.enst.fr/          --
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
--       http://www.rfc1149.net/devel/adasockets                           --
--                                                                         --
--   If you have any question, please send a mail to the AdaSockets list   --
--       adasockets@lists.rfc1149.net                                      --
--                                                                         --
-----------------------------------------------------------------------------

with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Exceptions;    use Ada.Exceptions;
with Ada.Text_IO;       use Ada.Text_IO;
with Sockets.Stream_IO; use Sockets, Sockets.Stream_IO;

procedure Stream_Sender is

   --  Usage: stream_sender remotehost remoteport
   --  Example: stream_sender localhost 5000

   Outgoing_Socket : Socket_FD;
   Stream          : aliased Socket_Stream_Type;
   Line            : String (1 .. 200);
   Last            : Natural;

begin
   if Argument_Count /= 2 then
      Raise_Exception
        (Constraint_Error'Identity,
         "Usage: " & Command_Name & " remotehost remoteport");
   end if;

   Socket (Outgoing_Socket, PF_INET, SOCK_STREAM);
   Connect (Outgoing_Socket, Argument (1), Positive'Value (Argument (2)));
   Initialize (Stream, Outgoing_Socket);

   loop
      Put ("Type a string> ");
      Flush;
      Get_Line (Line, Last);
      String'Output (Stream'Access, Line (Line'First .. Last));
   end loop;

exception
   when End_Error => null;
end Stream_Sender;
