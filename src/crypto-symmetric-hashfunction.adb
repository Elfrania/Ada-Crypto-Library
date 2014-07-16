-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
-- 02111-1307, USA.

-- As a special exception, if other files instantiate generics from
-- this unit, or you link this unit with other files to produce an
-- executable, this unit does not by itself cause the resulting
-- executable to be covered by the GNU General Public License. This
-- exception does not however invalidate any other reasons why the
-- executable file might be covered by the GNU Public License.


package body  Crypto.Symmetric.Hashfunction is

   H : Hash_Type;

   ---------------------------------------------------------------------------

   procedure Initialize(This : in out Hash_Context) is
   begin
      Init(This.HS);
      This.B.Length := 0;
      This.B.Data := (others => 0);
   end Initialize;

   ---------------------------------------------------------------------------

   procedure Update(This : in out Hash_Context;
                    Message_Block : in Message_Type) is
   begin
      Round(This          => This.HS,
            Message_Block => Message_Block);
   end Update;

   ---------------------------------------------------------------------------

   function Final_Round(This : in out Hash_Context;
                        Last_Message_Block  : Message_Type;
                        Last_Message_Length : Message_Block_Length_Type)
                        return Hash_Type is
   begin
      return Final_Round(This.HS, Last_Message_Block, Last_Message_Length);
   end Final_Round;

   ---------------------------------------------------------------------------

   procedure Update(This    : in out Hash_Context;
                    Message : in Bytes) is
      N     : Natural;
      L     : Integer := Message'Length;
      Index : Integer := Message'First;
   begin
      while L > 0 loop
         if L <= Integer(Message_Block_Length_Type'Last) - This.B.Length then
            N := L;
         else
            N := Integer(Message_Block_Length_Type'Last) - This.B.Length;
         end if;

         This.B.Data(This.B.Length + 1 .. This.B.Length + N) := Message(Index .. Index + N - 1);

         Index := Index + N;

         This.B.Length := This.B.Length + N;
         L := L - N;

         if This.B.Length = Integer(Message_Block_Length_Type'Last) then
            Round(This.HS, To_Message_Type(This.B.Data));
            This.B.Length := 0;
         end if;

      end loop;
   end Update;

   ---------------------------------------------------------------------------

   function Final_Round(This : in out Hash_Context)
                        return Hash_Type is
   begin
      if This.B.Length < Integer(Message_Block_Length_Type'Last) then
         This.B.Data(This.B.Data'First + This.B.Length .. This.B.Data'Last) := (others => 0);
      end if;

      return Final_Round(This.HS, To_Message_Type(This.B.Data), Message_Block_Length_Type(This.B.Length));
   end Final_Round;

   ---------------------------------------------------------------------------

   function Hash(Message  : Bytes)  return Hash_Type is
   begin
      Hash(Message, H);
      return H;
   end Hash;

    ---------------------------------------------------------------------------

   function Hash  (Message  : String) return Hash_Type is
   begin
      Hash(Message, H);
      return H;
   end Hash;

   ---------------------------------------------------------------------------

   function F_Hash(Filename : String) return Hash_Type is
   begin
      F_Hash(Filename, H);
      return H;
   end F_Hash;

   ---------------------------------------------------------------------------

   function To_Bytes(Hash : Hash_Type) return Bytes is
   begin
      return Generic_To_Bytes(Hash);
   end To_Bytes;


   end Crypto.Symmetric.Hashfunction;
