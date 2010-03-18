-----------------------------------------------------------------------------
--                                                                         --
--                         ADASOCKETS COMPONENTS                           --
--                                                                         --
--                      S O C K E T S . N A M I N G                        --
--                                                                         --
--                                B o d y                                  --
--                                                                         --
--          Copyright (C) 1998-2010 Samuel Tardieu <sam@rfc1149.net>       --
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

with Ada.Unchecked_Deallocation;
with Sockets.Utils;              use Sockets.Utils;

package body Sockets.Naming is

   use GNAT.Sockets;

   function Is_IP_Address (Something : String) return Boolean
     renames Sockets.Utils.Is_IP_Address;

   procedure Free is
      new Ada.Unchecked_Deallocation (String, String_Access);

   function To_Address (Addr : Inet_Addr_Type) return Address;

   function To_Host_Entry (H : Host_Entry_Type) return Host_Entry;

   ----------------
   -- Address_Of --
   ----------------

   function Address_Of (Something : String) return Address
   is
   begin
      if Is_IP_Address (Something) then
         return Value (Something);
      else
         return To_Address (Addresses (Get_Host_By_Name (Something), 1));
      end if;
   end Address_Of;

   ------------
   -- Adjust --
   ------------

   procedure Adjust (Object : in out Host_Entry)
   is
      Aliases : String_Array renames Object.Aliases;
   begin
      Object.Name := new String'(Object.Name.all);
      for I in Aliases'Range loop
         Aliases (I) := new String'(Aliases (I) .all);
      end loop;
   end Adjust;

   -----------------
   -- Any_Address --
   -----------------

   function Any_Address return Address
   is
   begin
      return To_Address (Any_Inet_Addr);
   end Any_Address;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Object : in out Host_Entry)
   is
      Aliases : String_Array renames Object.Aliases;
   begin
      Free (Object.Name);
      for I in Aliases'Range loop
         Free (Aliases (I));
      end loop;
   end Finalize;

   -------------------
   -- Get_Peer_Addr --
   -------------------

   function Get_Peer_Addr (Socket : Socket_FD) return Address is
   begin
      return To_Address (Get_Peer_Name (Socket.FD) .Addr);
   end Get_Peer_Addr;

   -------------------
   -- Get_Peer_Port --
   -------------------

   function Get_Peer_Port (Socket : Socket_FD) return Positive is
   begin
      return Positive (Get_Peer_Name (Socket.FD) .Port);
   end Get_Peer_Port;

   -------------------
   -- Get_Sock_Addr --
   -------------------

   function Get_Sock_Addr (Socket : Socket_FD) return Address is
   begin
      return To_Address (Get_Socket_Name (Socket.FD) .Addr);
   end Get_Sock_Addr;

   -------------------
   -- Get_Sock_Port --
   -------------------

   function Get_Sock_Port (Socket : Socket_FD) return Positive is
   begin
      return Positive (Get_Socket_Name (Socket.FD) .Port);
   end Get_Sock_Port;

   -----------
   -- Image --
   -----------

   function Image (Add : Address) return String
   is

      function Image (A : Address_Component) return String;
      --  Return the string corresponding to its argument without
      --  the leading space.

      -----------
      -- Image --
      -----------

      function Image (A : Address_Component)
        return String
      is
         Im : constant String := Address_Component'Image (A);
      begin
         return Im (Im'First + 1 .. Im'Last);
      end Image;

   begin
      return Image (Add.H1) & "." & Image (Add.H2) & "." &
        Image (Add.H3) & "." & Image (Add.H4);
   end Image;

   -------------
   -- Info_Of --
   -------------

   function Info_Of (Name : String) return Host_Entry
   is
   begin
      return To_Host_Entry (Get_Host_By_Name (Name));
   end Info_Of;

   -------------
   -- Info_Of --
   -------------

   function Info_Of (Addr : Address) return Host_Entry
   is
   begin
      return To_Host_Entry (Get_Host_By_Address (Inet_Addr (Image (Addr))));
   end Info_Of;

   ------------------------
   -- Info_Of_Name_Or_IP --
   ------------------------

   function Info_Of_Name_Or_IP (Something : String)
     return Host_Entry
   is
   begin
      if Is_IP_Address (Something) then
         return Info_Of (Value (Something));
      else
         return Info_Of (Something);
      end if;
   end Info_Of_Name_Or_IP;

   -------------
   -- Name_Of --
   -------------

   function Name_Of (Something : String) return String is
   begin
      return Info_Of_Name_Or_IP (Something) .Name.all;
   end Name_Of;

   ----------------
   -- To_Address --
   ----------------

   function To_Address (Addr : Inet_Addr_Type) return Address is
   begin
      return Value (Image (Addr));
   end To_Address;

   -------------------
   -- To_Host_Entry --
   -------------------

   function To_Host_Entry (H : Host_Entry_Type) return Host_Entry
   is
      R : Host_Entry (Aliases_Length (H), Addresses_Length (H));
   begin
      R.Name := new String'(Official_Name (H));
      for I in 1 .. R.N_Aliases loop
         R.Aliases (I) := new String'(Aliases (H, I));
      end loop;
      for I in 1 .. R.N_Addresses loop
         R.Addresses (I) := To_Address (Addresses (H, I));
      end loop;
      return R;
   end To_Host_Entry;

   -----------
   -- Value --
   -----------

   function Value (Add : String) return Address is

      Norm : constant String := Image (Inet_Addr (Add));
      --  Normalized address (for example, 127.1 will be transformed
      --  into 127.0.0.1).

      Dot  : Natural := Add'First - 1;
      --  Position of the last dot encountered or Add'First - 1

      function First_Numeric_String (S : String) return String;
      --  Return the first numeric string in S

      function Next_Number return Natural;
      --  Return the next numerical value after Dot and position Dot

      --------------------------
      -- First_Numeric_String --
      --------------------------

      function First_Numeric_String (S : String) return String is
      begin
         for I in S'Range loop
            if S (I) not in '0' .. '9' then
               return S (S'First .. I - 1);
            end if;
         end loop;
         return S;
      end First_Numeric_String;

      -----------------
      -- Next_Number --
      -----------------

      function Next_Number return Natural is
         SS : constant String :=
           First_Numeric_String (Norm (Dot + 1 .. Norm'Last));
      begin
         Dot := SS'Last + 1;
         return Integer'Value (SS);
      end Next_Number;

      A : Address;

   begin
      A.H1 := Next_Number;
      A.H2 := Next_Number;
      A.H3 := Next_Number;
      A.H4 := Next_Number;
      return A;
   end Value;

end Sockets.Naming;
