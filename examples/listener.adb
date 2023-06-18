-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                            L I S T E N E R                              --
--                                                                         --
--                                B o d y                                  --
--                                                                         --
--          Copyright (C) 1998-2023 Samuel Tardieu <sam@rfc1149.net>       --
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

with Ada.Command_Line; use Ada.Command_Line;
with Ada.Exceptions;   use Ada.Exceptions;
with Ada.Text_IO;      use Ada.Text_IO;
with Sockets;          use Sockets;

procedure Listener is

   --  Usage: listener port
   --  Example: listener 5000
   --  then telnet localhost 5000

   task type Echo is
      entry Start (FD : Socket_FD);
   end Echo;

   function Rev (S : String) return String;
   --  Reverse a string

   ----------
   -- Echo --
   ----------

   task body Echo is
      Sock : Socket_FD;
   begin
      select
         accept Start (FD : Socket_FD) do
            Sock := FD;
         end Start;
      or
         terminate;
      end select;

      loop
         Put_Line (Sock, Rev (Get_Line (Sock)));
      end loop;

   exception
      when Connection_Closed =>
         Put_Line ("Connection closed");
         Shutdown (Sock, Both);
   end Echo;

   Accepting_Socket : Socket_FD;
   Incoming_Socket  : Socket_FD;

   type Echo_Access is access Echo;
   Dummy : Echo_Access;

   ---------
   -- Rev --
   ---------

   function Rev (S : String) return String is
      Result : String (1 .. S'Length);
      Index  : Natural := 0;
   begin
      for I in reverse S'Range loop
         Index := Index + 1;
         Result (Index) := S (I);
      end loop;
      return Result;
   end Rev;

begin
   if Argument_Count /= 1 then
      Raise_Exception (Constraint_Error'Identity,
                       "Usage: " & Command_Name & " port");
   end if;
   Socket (Accepting_Socket, PF_INET, SOCK_STREAM);
   Setsockopt (Accepting_Socket, SOL_SOCKET, SO_REUSEADDR, 1);
   Bind (Accepting_Socket, Positive'Value (Argument (1)));
   Listen (Accepting_Socket);
   loop
      Put_Line ("Waiting for new connection");
      Accept_Socket (Accepting_Socket, Incoming_Socket);
      Put_Line ("New connection acknowledged");

      --  This step is optional, especially for TCP sockets
      Set_Buffer (Incoming_Socket, 4096);
      Put_Line ("New socket buffered");

      Dummy := new Echo;
      Dummy.Start (Incoming_Socket);
   end loop;
end Listener;
