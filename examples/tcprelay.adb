-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                            T C P R E L A Y                              --
--                                                                         --
--                                B o d y                                  --
--                                                                         --
--          Copyright (C) 1998-2018 Samuel Tardieu <sam@rfc1149.net>       --
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

procedure TCPRelay is

   --  Usage: tcprelay localport remotehost remoteport
   --  Example: tcprelay 5000 localhost 25,
   --  then telnet localhost 5000

   task type Relay is
      entry Start (From, To : Socket_FD);
   end Relay;

   -----------
   -- Relay --
   -----------

   task body Relay
   is
      From_FD, To_FD : Socket_FD;
   begin
      select
         accept Start (From, To : Socket_FD) do
            From_FD := From;
            To_FD   := To;
         end Start;
      or
         terminate;
      end select;

      loop
         Send (To_FD, Receive (From_FD));
      end loop;
   exception
      when Connection_Closed =>
         Put_Line ("Connection closed");
         Shutdown (From_FD, Receive);
         Shutdown (To_FD, Send);
   end Relay;

   Accepting_Socket,
   Incoming_Socket,
   Outgoing_Socket   : Socket_FD;

   type Relay_Access is access Relay;
   Dummy : Relay_Access;

begin
   if Argument_Count /= 3 then
      Raise_Exception
        (Constraint_Error'Identity,
         "Usage: " & Command_Name & " localport remotehost remoteport");
   end if;
   Socket (Accepting_Socket, PF_INET, SOCK_STREAM);
   Setsockopt (Accepting_Socket, SOL_SOCKET, SO_REUSEADDR, 1);
   Bind (Accepting_Socket, Positive'Value (Argument (1)));
   Listen (Accepting_Socket);
   loop
      Put_Line ("Waiting for new connection");
      Accept_Socket (Accepting_Socket, Incoming_Socket);
      Put_Line ("New connection acknowledged");
      Socket (Outgoing_Socket, PF_INET, SOCK_STREAM);
      Put_Line ("Connecting to remote host");
      Connect (Outgoing_Socket, Argument (2), Positive'Value (Argument (3)));
      Put_Line ("Connection established");
      Dummy := new Relay;
      Dummy.Start (Incoming_Socket, Outgoing_Socket);
      Dummy := new Relay;
      Dummy.Start (Outgoing_Socket, Incoming_Socket);
   end loop;
end TCPRelay;
