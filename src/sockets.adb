-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                             S O C K E T S                               --
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

with Ada.Characters.Latin_1;     use Ada.Characters.Latin_1;
with Ada.Unchecked_Deallocation;
pragma Warnings (Off);
with GNAT.Sockets.Constants;
pragma Warnings (On);
with Sockets.Link;
pragma Warnings (Off, Sockets.Link);
with Sockets.Naming;             use Sockets.Naming;
with Sockets.Thin;               use Sockets.Thin;
with Sockets.Types;              use Sockets.Types;
with Sockets.Utils;              use Sockets.Utils;

package body Sockets is

   use Ada.Streams, Interfaces.C, GNAT.Sockets;

   package Constants renames GNAT.Sockets.Constants;

   Socket_Domain_Match : constant array (Socket_Domain) of Family_Type :=
     (PF_INET => Family_Inet,
      AF_INET => Family_Inet);  --  They hold the same value

   Socket_Type_Match : constant array (Socket_Type) of Mode_Type :=
     (SOCK_STREAM => Socket_Stream,
      SOCK_DGRAM  => Socket_Datagram);

   Shutdown_Type_Match : constant array (Shutdown_Type) of Shutmode_Type :=
     (Receive => Shut_Read,
      Send    => Shut_Write,
      Both    => Shut_Read_Write);

   Socket_Level_Match : constant array (Socket_Level) of int :=
     (SOL_SOCKET => Constants.SOL_SOCKET,
      IPPROTO_IP => Constants.IPPROTO_IP);

   Socket_Option_Match : constant array (Socket_Option) of int :=
     (SO_REUSEADDR       => Constants.SO_REUSEADDR,
      IP_MULTICAST_TTL   => Constants.IP_MULTICAST_TTL,
      IP_ADD_MEMBERSHIP  => Constants.IP_ADD_MEMBERSHIP,
      IP_DROP_MEMBERSHIP => Constants.IP_DROP_MEMBERSHIP,
      IP_MULTICAST_LOOP  => Constants.IP_MULTICAST_LOOP,
      SO_SNDBUF          => Constants.SO_SNDBUF,
      SO_RCVBUF          => Constants.SO_RCVBUF);

   Socket_Option_Size  : constant array (Socket_Option) of Natural :=
     (SO_REUSEADDR       => 4,
      IP_MULTICAST_TTL   => 1,
      IP_ADD_MEMBERSHIP  => 8,
      IP_DROP_MEMBERSHIP => 8,
      IP_MULTICAST_LOOP  => 1,
      SO_SNDBUF          => 4,
      SO_RCVBUF          => 4);

   CRLF : constant String := CR & LF;

   procedure Refill (Socket : in Socket_FD'Class);
   --  Refill the socket when in buffered mode by receiving one packet
   --  and putting it in the buffer.

   function To_String (S : Stream_Element_Array) return String;

   function Empty_Buffer (Socket : Socket_FD'Class) return Boolean;
   --  Return True if buffered socket has an empty buffer

   -------------------
   -- Accept_Socket --
   -------------------

   procedure Accept_Socket (Socket     : in Socket_FD;
                            New_Socket : out Socket_FD)
   is
      New_FD   : GNAT.Sockets.Socket_Type;
      New_Addr : Sock_Addr_Type;
   begin
      Accept_Socket (Socket.FD, New_FD, New_Addr);
      New_Socket :=
        (FD       => New_FD,
         Shutdown => (others => False),
         Buffer   => null);
   end Accept_Socket;

   ----------
   -- Bind --
   ----------

   procedure Bind
     (Socket : in Socket_FD;
      Port   : in Natural;
      Host   : in String := "")
   is
      Address : Sock_Addr_Type;
   begin
      if Host = "" then
         Address.Addr := Any_Inet_Addr;
      else
         Address.Addr := Addresses (Get_Host_By_Name (Host), 1);
      end if;
      Address.Port := Port_Type (Port);
      Bind_Socket (Socket.FD, Address);
   end Bind;

   -------------
   -- Connect --
   -------------

   procedure Connect
     (Socket : in Socket_FD;
      Host   : in String;
      Port   : in Positive)
   is
      Address : Sock_Addr_Type;
   begin
      Address.Addr := Addresses (Get_Host_By_Name (Host), 1);
      Address.Port := Port_Type (Port);
      Connect_Socket (Socket.FD, Address);
   end Connect;

   ---------------------------
   -- Customized_Setsockopt --
   ---------------------------

   procedure Customized_Setsockopt (Socket : in Socket_FD'Class;
                                    Optval : in Opt_Type)
   is
   begin
      pragma Assert (Optval'Size / 8 = Socket_Option_Size (Optname));
      if C_Setsockopt (Get_FD (Socket),
                       Socket_Level_Match (Level),
                       Socket_Option_Match (Optname),
                       Optval'Address, Optval'Size / 8) = Failure
      then
         Raise_With_Message ("Setsockopt failed");
      end if;
   end Customized_Setsockopt;

   ------------------
   -- Empty_Buffer --
   ------------------

   function Empty_Buffer (Socket : Socket_FD'Class) return Boolean is
   begin
      return Socket.Buffer.First > Socket.Buffer.Last;
   end Empty_Buffer;

   ---------
   -- Get --
   ---------

   function Get (Socket : Socket_FD'Class) return String
   is
   begin
      if Socket.Buffer /= null and then not Empty_Buffer (Socket) then
         declare
            S : constant String :=
              To_String (Socket.Buffer.Content
                         (Socket.Buffer.First .. Socket.Buffer.Last));
         begin
            Socket.Buffer.First := Socket.Buffer.Last + 1;
            return S;
         end;
      else
         return To_String (Receive (Socket));
      end if;
   end Get;

   --------------
   -- Get_Char --
   --------------

   function Get_Char (Socket : Socket_FD'Class) return Character is
      C : Stream_Element_Array (0 .. 0);
   begin
      if Socket.Buffer = null then
         --  Unbuffered mode

         Receive (Socket, C);
      else
         --  Buffered mode

         if Empty_Buffer (Socket) then
            Refill (Socket);
         end if;

         C (0) := Socket.Buffer.Content (Socket.Buffer.First);
         Socket.Buffer.First := Socket.Buffer.First + 1;

      end if;

      return Character'Val (C (0));
   end Get_Char;

   ------------
   -- Get FD --
   ------------

   function Get_FD (Socket : in Socket_FD)
     return Interfaces.C.int
   is
   begin
      return Interfaces.C.int (To_C (Socket.FD));
   end Get_FD;

   --------------
   -- Get_Line --
   --------------

   procedure Get_Line
     (Socket : Socket_FD'Class;
      Str    : out String;
      Last   : out Natural)
   is
      Index  : Positive := Str'First;
      Char   : Character;
   begin
      loop
         Char := Get_Char (Socket);
         if Char = LF then
            Last := Index - 1;
            return;
         elsif Char /= CR then
            Str (Index) := Char;
            Index := Index + 1;
            if Index > Str'Last then
               Last := Str'Last;
               return;
            end if;
         end if;
      end loop;
   end Get_Line;

   --------------
   -- Get_Line --
   --------------

   function Get_Line
     (Socket : Socket_FD'Class;  Max_Length : Positive := 2048)
     return String
   is
      Result : String (1 .. Max_Length);
      Last   : Natural;
   begin
      Get_Line (Socket, Result, Last);
      return Result (1 .. Last);
   end Get_Line;

   ----------------
   -- Getsockopt --
   ----------------

   procedure Getsockopt
     (Socket  : in  Socket_FD'Class;
      Level   : in  Socket_Level := SOL_SOCKET;
      Optname : in  Socket_Option;
      Optval  : out Integer)
   is
      Len : aliased int;
   begin
      case Socket_Option_Size (Optname) is

         when 1 =>
            declare
               C_Char_Optval : aliased char;
            begin
               pragma Assert (C_Char_Optval'Size = 8);
               Len := 1;
               if C_Getsockopt (Get_FD (Socket),
                                Socket_Level_Match (Level),
                                Socket_Option_Match (Optname),
                                C_Char_Optval'Address, Len'Access) = Failure
               then
                  Raise_With_Message ("Getsockopt failed");
               end if;
               Optval := char'Pos (C_Char_Optval);
            end;

         when 4 =>
            declare
               C_Int_Optval : aliased int;
            begin
               pragma Assert (C_Int_Optval'Size = 32);
               Len := 4;
               if C_Getsockopt (Get_FD (Socket),
                                Socket_Level_Match (Level),
                                Socket_Option_Match (Optname),
                                C_Int_Optval'Address, Len'Access) = Failure
               then
                  Raise_With_Message ("Getsockopt failed");
               end if;
               Optval := Integer (C_Int_Optval);

            end;

         when others =>
            Raise_With_Message ("Getsockopt called with wrong arguments",
                                False);

      end case;
   end Getsockopt;

   ------------
   -- Listen --
   ------------

   procedure Listen
     (Socket     : in Socket_FD;
      Queue_Size : in Positive := 5)
   is
   begin
      Listen_Socket (Socket.FD, Queue_Size);
   end Listen;

   --------------
   -- New_Line --
   --------------

   procedure New_Line (Socket : in Socket_FD'Class;
                       Count  : in Natural := 1)
   is
   begin
      Put (Socket, CRLF * Count);
   end New_Line;

   ---------
   -- Put --
   ---------

   procedure Put (Socket : in Socket_FD'Class;
                  Str    : in String)
   is
      Stream : Stream_Element_Array (Stream_Element_Offset (Str'First) ..
                                     Stream_Element_Offset (Str'Last));
   begin
      for I in Str'Range loop
         Stream (Stream_Element_Offset (I)) :=
           Stream_Element'Val (Character'Pos (Str (I)));
      end loop;
      Send (Socket, Stream);
   end Put;

   --------------
   -- Put_Line --
   --------------

   procedure Put_Line (Socket : in Socket_FD'Class; Str : in String)
   is
   begin
      Put (Socket, Str & CRLF);
   end Put_Line;

   -------------
   -- Receive --
   -------------

   function Receive (Socket : Socket_FD; Max : Stream_Element_Count := 4096)
     return Stream_Element_Array
   is
      Buffer  : Stream_Element_Array (1 .. Max);
      Last    : Stream_Element_Offset;
   begin
      if Socket.Shutdown (Receive) then
         raise Connection_Closed;
      end if;
      Receive_Socket (Socket.FD, Buffer, Last);
      return Buffer (1 .. Last);
   end Receive;

   -------------
   -- Receive --
   -------------

   procedure Receive (Socket : in Socket_FD'Class;
                      Data   : out Stream_Element_Array)
   is
      Last     : Stream_Element_Offset := Data'First - 1;
      Old_Last : Stream_Element_Offset;
   begin
      while Last < Data'Last loop
         Old_Last := Last;
         Receive_Socket (Socket.FD, Data (Last + 1 .. Data'Last), Last);
         if Last = Old_Last then
            raise Connection_Closed;
         end if;
      end loop;
   end Receive;

   ------------------
   -- Receive_Some --
   ------------------

   procedure Receive_Some (Socket : in Socket_FD'Class;
                           Data   : out Stream_Element_Array;
                           Last   : out Stream_Element_Offset)
   is
   begin
      Receive_Socket (Socket.FD, Data, Last);
      if Last = Data'First - 1 then
         raise Connection_Closed;
      end if;
   end Receive_Some;

   ------------
   -- Refill --
   ------------

   procedure Refill
     (Socket : in Socket_FD'Class)
   is
   begin
      pragma Assert (Socket.Buffer /= null);
      Receive_Some (Socket, Socket.Buffer.Content, Socket.Buffer.Last);
      Socket.Buffer.First := 0;
   end Refill;

   ----------
   -- Send --
   ----------

   procedure Send (Socket : in Socket_FD;
                   Data   : in Stream_Element_Array)
   is
      Last     : Stream_Element_Offset := Data'First - 1;
      Old_Last : Stream_Element_Offset;
   begin
      while Last /= Data'Last loop
         Old_Last := Last;
         Send_Socket (Socket.FD, Data (Last + 1 .. Data'Last), Last);
         if Last = Old_Last then
            raise Connection_Closed;
         end if;
      end loop;
   end Send;

   ----------------
   -- Set_Buffer --
   ----------------

   procedure Set_Buffer
     (Socket : in out Socket_FD'Class;
      Length : in Positive := 1500)
   is
   begin
      Unset_Buffer (Socket);
      Socket.Buffer := new Buffer_Type (Stream_Element_Count (Length));
   end Set_Buffer;

   ----------------
   -- Setsockopt --
   ----------------

   procedure Setsockopt
     (Socket  : in Socket_FD'Class;
      Level   : in Socket_Level := Sol_Socket;
      Optname : in Socket_Option;
      Optval  : in Integer)
   is
   begin
      case Socket_Option_Size (Optname) is

         when 1 =>
            declare
               C_Char_Optval : aliased char := char'Val (Optval);
            begin
               pragma Assert (C_Char_Optval'Size = 8);
               if C_Setsockopt (Get_FD (Socket), Socket_Level_Match (Level),
                                Socket_Option_Match (Optname),
                                C_Char_Optval'Address, 1) = Failure
               then
                  Raise_With_Message ("Setsockopt failed");
               end if;
            end;

         when 4 =>
            declare
               C_Int_Optval : aliased int := int (Optval);
            begin
               pragma Assert (C_Int_Optval'Size = 32);
               if C_Setsockopt (Get_FD (Socket), Socket_Level_Match (Level),
                                Socket_Option_Match (Optname),
                                C_Int_Optval'Address, 4) = Failure
               then
                  Raise_With_Message ("Setsockopt failed");
               end if;
            end;

         when others =>
            Raise_With_Message ("Setsockopt called with wrong arguments",
                                False);

      end case;
   end Setsockopt;

   --------------
   -- Shutdown --
   --------------

   procedure Shutdown (Socket : in out Socket_FD;
                       How    : in Shutdown_Type := Both)
   is
   begin
      if How /= Both then
         Socket.Shutdown (How) := True;
      else
         Socket.Shutdown := (others => True);
      end if;
      Shutdown_Socket (Socket.FD, Shutdown_Type_Match (How));
      if Socket.Shutdown (Receive) and then Socket.Shutdown (Send) then
         Unset_Buffer (Socket);
         Close_Socket (Socket.FD);
      end if;
   end Shutdown;

   ------------
   -- Socket --
   ------------

   procedure Socket
     (Sock   : out Socket_FD;
      Domain : in Socket_Domain := PF_INET;
      Typ    : in Socket_Type   := SOCK_STREAM)
   is
   begin
      Create_Socket (Sock.FD,
                     Socket_Domain_Match (Domain),
                     Socket_Type_Match (Typ));
      Sock.Shutdown := (others => False);
      Sock.Buffer   := null;
   end Socket;

   ---------------
   -- To_String --
   ---------------

   function To_String (S : Stream_Element_Array) return String is
      Result : String (1 .. S'Length);
   begin
      for I in Result'Range loop
         Result (I) :=
           Character'Val (Stream_Element'Pos
                          (S (Stream_Element_Offset (I) + S'First - 1)));
      end loop;
      return Result;
   end To_String;

   ------------------
   -- Unset_Buffer --
   ------------------

   procedure Unset_Buffer (Socket : in out Socket_FD'Class) is
      procedure Free is
         new Ada.Unchecked_Deallocation (Buffer_Type, Buffer_Access);
   begin
      Free (Socket.Buffer);
   end Unset_Buffer;

end Sockets;
