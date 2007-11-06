-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                             S O C K E T S                               --
--                                                                         --
--                                S p e c                                  --
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

with Ada.Streams;
with GNAT.Sockets;
with Interfaces.C;

package Sockets is

   type Socket_FD is tagged private;
   --  A socket

   subtype Socket_Domain is GNAT.Sockets.Family_Type;
   function PF_INET return Socket_Domain renames GNAT.Sockets.Family_Inet;
   function AF_INET return Socket_Domain renames GNAT.Sockets.Family_Inet;
   --  PF_INET: Internet sockets
   --  AF_INET: This entry is bogus and should never be used, but it is
   --  kept here for some time for compatibility reasons.
   --  Those two entries are kept for compatibility

   subtype Socket_Type is GNAT.Sockets.Mode_Type;
   function SOCK_STREAM return Socket_Type renames GNAT.Sockets.Socket_Stream;
   function SOCK_DGRAM return Socket_Type renames GNAT.Sockets.Socket_Datagram;
   --  Those two entries are kept for compatibility

   procedure Socket
     (Sock   : out Socket_FD;
      Domain : in Socket_Domain := PF_INET;
      Typ    : in Socket_Type   := SOCK_STREAM);
   --  Create a socket of the given mode

   Connection_Refused : exception;
   Socket_Error       : exception;

   procedure Connect
     (Socket : in Socket_FD;
      Host   : in String;
      Port   : in Positive);
   --  Connect a socket on a given host/port. Raise Connection_Refused if
   --  the connection has not been accepted by the other end, or
   --  Socket_Error (with a more precise exception message) for another error.

   procedure Bind
     (Socket : in Socket_FD;
      Port   : in Natural;
      Host   : in String := "");
   --  Bind a socket on a given port. Using 0 for the port will tell the
   --  OS to allocate a non-privileged free port. The port can be later
   --  retrieved using Get_Sock_Port on the bound socket.
   --  If Host is not the empty string, it is used to designate the interface
   --  to bind on.
   --  Socket_Error can be raised if the system refuses to bind the port.

   procedure Listen
     (Socket     : in Socket_FD;
      Queue_Size : in Positive := 5);
   --  Create a socket's listen queue

   type Socket_Level is (SOL_SOCKET, IPPROTO_IP);

   type Socket_Option is (SO_REUSEADDR, IP_MULTICAST_TTL,
                          IP_ADD_MEMBERSHIP, IP_DROP_MEMBERSHIP,
                          IP_MULTICAST_LOOP, SO_SNDBUF, SO_RCVBUF);

   procedure Getsockopt
     (Socket  : in  Socket_FD'Class;
      Level   : in  Socket_Level := SOL_SOCKET;
      Optname : in  Socket_Option;
      Optval  : out Integer);
   --  Get a socket option

   procedure Setsockopt
     (Socket  : in Socket_FD'Class;
      Level   : in Socket_Level := SOL_SOCKET;
      Optname : in Socket_Option;
      Optval  : in Integer);
   --  Set a socket option

   generic
      Level   : Socket_Level;
      Optname : Socket_Option;
      type Opt_Type is private;
   procedure Customized_Setsockopt (Socket : in Socket_FD'Class;
                                    Optval : in Opt_Type);
   --  Low level control on setsockopt

   procedure Accept_Socket (Socket     : in Socket_FD;
                            New_Socket : out Socket_FD);
   --  Accept a connection on a socket

   Connection_Closed : exception;

   procedure Send (Socket : in Socket_FD;
                   Data   : in Ada.Streams.Stream_Element_Array);
   --  Send data on a socket. Raise Connection_Closed if the socket
   --  has been closed.

   function Receive (Socket : Socket_FD;
                     Max    : Ada.Streams.Stream_Element_Count := 4096)
     return Ada.Streams.Stream_Element_Array;
   --  Receive data from a socket. May raise Connection_Closed

   procedure Receive (Socket : in Socket_FD'Class;
                      Data   : out Ada.Streams.Stream_Element_Array);
   --  Get data from a socket. Raise Connection_Closed if the socket has
   --  been closed before the end of the array.

   procedure Receive_Some
     (Socket : in Socket_FD'Class;
      Data   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset);
   --  Get some data from a socket. The index of the last element will
   --  be placed in Last.

   subtype Shutdown_Type is GNAT.Sockets.Shutmode_Type;
   function Receive return Shutdown_Type renames GNAT.Sockets.Shut_Read;
   function Send return Shutdown_Type renames GNAT.Sockets.Shut_Write;
   function Both return Shutdown_Type renames GNAT.Sockets.Shut_Read_Write;
   --  Those three entries are kept for compatibility

   procedure Shutdown (Socket : in out Socket_FD;
                       How    : in Shutdown_Type := Both);
   --  Close a previously opened socket

   function Get_FD (Socket : in Socket_FD)
     return Interfaces.C.int;
   pragma Inline (Get_FD);
   --  Get a socket's FD field

   ---------------------------------
   -- String-oriented subprograms --
   ---------------------------------

   procedure Put (Socket : in Socket_FD'Class;
                  Str    : in String);
   --  Send a string on the socket

   procedure New_Line (Socket : in Socket_FD'Class;
                       Count  : in Natural := 1);
   --  Send CR/LF sequences on the socket

   procedure Put_Line (Socket : in Socket_FD'Class;
                       Str    : in String);
   --  Send a string + CR/LF on the socket

   function Get (Socket : Socket_FD'Class) return String;
   --  Get a string from the socket

   function Get_Char (Socket : Socket_FD'Class) return Character;
   --  Get one character from the socket

   procedure Get_Line (Socket : Socket_FD'Class;
                       Str    : out String;
                       Last   : out Natural);
   --  Get a full line from the socket. CR is ignored and LF is considered
   --  as an end-of-line marker.

   function Get_Line (Socket     : Socket_FD'Class;
                      Max_Length : Positive := 2048)
      return String;
   --  Function form for the former procedure

   procedure Set_Buffer (Socket : in out Socket_FD'Class;
                         Length : in Positive := 1500);
   --  Put socket in buffered mode. If the socket is already buffered,
   --  the content of the previous buffer will be lost. The buffered mode
   --  only affects read operation, through Get, Get_Char and Get_Line. Other
   --  reception subprograms will not function properly if buffered mode
   --  is used at the same time. The size of the buffer has to be greater
   --  than the biggest possible packet, otherwise data loss may occur.

   procedure Unset_Buffer (Socket : in out Socket_FD'Class);
   --  Put socket in unbuffered mode. If the socket was unbuffered already,
   --  no error will be raised. If it was buffered and the buffer was not
   --  empty, its content will be lost.

private

   use type Ada.Streams.Stream_Element_Count;

   type Buffer_Type
     (Length : Ada.Streams.Stream_Element_Count := 1500)
   is record
      Content : Ada.Streams.Stream_Element_Array (0 .. Length);
      --  One byte will stay unused, but this does not have any consequence
      First   : Ada.Streams.Stream_Element_Offset :=
        Ada.Streams.Stream_Element_Offset'Last;
      Last    : Ada.Streams.Stream_Element_Offset := 0;
   end record;

   type Buffer_Access is access Buffer_Type;

   type Shutdown_Array is array (Receive .. Send) of Boolean;

   type Socket_FD is tagged record
      FD       : GNAT.Sockets.Socket_Type;
      Shutdown : Shutdown_Array;
      Buffer   : Buffer_Access;
   end record;

end Sockets;
