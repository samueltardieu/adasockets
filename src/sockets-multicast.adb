-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                   S O C K E T S . M U L T I C A S T                     --
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

with Ada.Exceptions;         use Ada.Exceptions;
with Sockets;
pragma Elaborate_All (Sockets);
pragma Warnings (Off);
with GNAT.Sockets.Constants;
pragma Warnings (On);
with Sockets.Utils;          use Sockets.Utils;

package body Sockets.Multicast is

   use Ada.Streams, GNAT.Sockets;

   function Create_Multicast_Socket
     (Group      : String;
      Port       : Positive;
      Local_Port : Natural;
      TTL        : Positive := 16;
      Self_Loop  : Boolean  := True;
      Local_If   : String   := "0.0.0.0")
     return Multicast_Socket_FD;

   -----------------------------
   -- Create_Multicast_Socket --
   -----------------------------

   function Create_Multicast_Socket
     (Group      : String;
      Port       : Positive;
      Local_Port : Natural;
      TTL        : Positive := 16;
      Self_Loop  : Boolean  := True;
      Local_If   : String   := "0.0.0.0")
     return Multicast_Socket_FD
   is
      Result      : Multicast_Socket_FD;

      function Address_Of (Host : String) return Inet_Addr_Type;
      --  Return IP address of Host which may be a host name or
      --  an address in dotted form.

      ----------------
      -- Address_Of --
      ----------------

      function Address_Of (Host : String) return Inet_Addr_Type is
      begin
         if Is_IP_Address (Host) then
            return Inet_Addr (Host);
         else
            return Addresses (Get_Host_By_Name (Host), 1);
         end if;
      end Address_Of;

   begin
      Socket (Socket_FD (Result), Family_Inet, Socket_Datagram);
      Result.Target.Addr := Address_Of (Group);
      Result.Target.Port := Port_Type (Port);
      Set_Socket_Option
        (Result.FD, GNAT.Sockets.Socket_Level, (Reuse_Address, True));
      Bind (Result, Local_Port);
      Set_Socket_Option
        (Result.FD,
         IP_Protocol_For_IP_Level,
         (Add_Membership, Result.Target.Addr, Address_Of (Local_If)));
      Set_Socket_Option
        (Result.FD, IP_Protocol_For_IP_Level, (Multicast_TTL, TTL));
      Set_Socket_Option
        (Result.FD, IP_Protocol_For_IP_Level, (Multicast_Loop, Self_Loop));
      return Result;
   end Create_Multicast_Socket;

   -----------------------------
   -- Create_Multicast_Socket --
   -----------------------------

   function Create_Multicast_Socket
     (Group     : String;
      Port      : Positive;
      TTL       : Positive := 16;
      Self_Loop : Boolean  := True;
      Local_If  : String   := "0.0.0.0")
     return Multicast_Socket_FD
   is
   begin
      return Create_Multicast_Socket
                (Group      => Group,
                 Port       => Port,
                 Local_Port => Port,
                 TTL        => TTL,
                 Self_Loop  => Self_Loop,
                 Local_If   => Local_If);
   end Create_Multicast_Socket;

   -----------------------------
   -- Create_Multicast_Socket --
   -----------------------------

   function Create_Multicast_Socket
     (Group      : String;
      Port       : Positive;
      Local_Port : Natural;
      TTL        : Positive := 16;
      Local_If   : String   := "0.0.0.0")
     return Multicast_Socket_FD
   is
   begin
      return Create_Multicast_Socket
                (Group      => Group,
                 Port       => Port,
                 Local_Port => Local_Port,
                 TTL        => TTL,
                 Self_Loop  => False,
                 Local_If   => Local_If);
   end Create_Multicast_Socket;

   ----------
   -- Send --
   ----------

   procedure Send (Socket : in Multicast_Socket_FD;
                   Data   : in Stream_Element_Array)
   is
   begin
      Send (Socket, Data, Socket.Target);
   end Send;

   ------------
   -- Socket --
   ------------

   procedure Socket
     (Sock   : out Multicast_Socket_FD;
      Domain : in Socket_Domain := PF_INET;
      Typ    : in Socket_Type   := SOCK_STREAM)
   is
   begin
      Raise_Exception (Program_Error'Identity,
                       "Use Create_Multicast_Socket instead");
   end Socket;

end Sockets.Multicast;
