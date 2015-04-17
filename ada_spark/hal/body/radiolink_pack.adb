with Ada.Unchecked_Conversion;

package body Radiolink_Pack is

   procedure Radiolink_Init is
   begin
      if Is_Init then
         return;
      end if;
      --  TODO: Set the right channel parameter
      Radiolink_Set_Channel (0);

   end Radiolink_Init;

   procedure Radiolink_Set_Data_Rate (Data_Rate : T_Uint8) is
      Sl_Packet : Syslink_Packet;
   begin
      Sl_Packet.Slp_Type := SYSLINK_RADIO_DATARATE;
      Sl_Packet.Length := 1;
      Sl_Packet.Data (1) := Data_Rate;
      Syslink_Send_Packet (Sl_Packet);
   end Radiolink_Set_Data_Rate;

   procedure Radiolink_Set_Channel (Channel : T_Uint8) is
      Sl_Packet : Syslink_Packet;
   begin
      Sl_Packet.Slp_Type := SYSLINK_RADIO_CHANNEL;
      Sl_Packet.Length := 1;
      Sl_Packet.Data (1) := Channel;
      Syslink_Send_Packet (Sl_Packet);
   end Radiolink_Set_Channel;

   procedure Radiolink_Receive_Packet
     (Packet : out Crtp_Packet;
      Has_Suceed : out Boolean) is
   begin
      Rx_Queue.Dequeue_Item (Packet, Has_Suceed);
   end Radiolink_Receive_Packet;

   function Radiolink_Send_Packet (Packet : Crtp_Packet) return Boolean is
      Sl_Packet : Syslink_Packet;
      Has_Suceed : Boolean;
      function Crtp_Raw_To_Syslink_Data is new Ada.Unchecked_Conversion
        (Crtp_Raw, Syslink_Data);
   begin
      Sl_Packet.Length := Packet.Size + 1;
      Sl_Packet.Slp_Type := SYSLINK_RADIO_RAW;
      Sl_Packet.Data := Crtp_Raw_To_Syslink_Data (Packet.Raw);

      --  Try to enqueue the Syslink packet
      Tx_Queue.Enqueue_Item (Sl_Packet, Has_Suceed);
      return Has_Suceed;
   end Radiolink_Send_Packet;

   procedure Radiolink_Syslink_Dispatch (Rx_Sl_Packet : Syslink_Packet) is
      Tx_Sl_Packet : Syslink_Packet;
      Rx_Crtp_Packet : Crtp_Packet;
      Has_Succeed     : Boolean;
   begin
      if Rx_Sl_Packet.Slp_Type = SYSLINK_RADIO_RAW then
         Rx_Crtp_Packet.Size := Rx_Sl_Packet.Length - 1;
         Rx_Crtp_Packet.Header := Rx_Sl_Packet.Data (1);
         Rx_Crtp_Packet.Data_2 :=
           Crtp_Data (Rx_Sl_Packet.Data (2 .. Rx_Sl_Packet.Data'Length));

         --  Enqueue the received packet
         Rx_Queue.Enqueue_Item (Rx_Crtp_Packet, Has_Succeed);
         -- TODO: led blink

         -- If a radio packet is received, one can be sent
         Tx_Queue.Dequeue_Item (Tx_Sl_Packet, Has_Succeed);
         if Has_Succeed then
            -- TODO: led blink
            Syslink_Send_Packet (Tx_Sl_Packet);
         end if;
      elsif Rx_Sl_Packet.Slp_Type = SYSLINK_RADIO_RSSI then
         --  Extract RSSI sample sent from Radio
         RSSI := Rx_Sl_Packet.Data (1);
      end if ;
   end Radiolink_Syslink_Dispatch;

end Radiolink_Pack;