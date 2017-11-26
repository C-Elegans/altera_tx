//                              -*- Mode: Verilog -*-
// Filename        : spi.v
// Description     : SPI slave
// Author          : Michael Nolan
// Created On      : Fri Nov 24 19:45:29 2017
// Last Modified By: Michael Nolan
// Last Modified On: Fri Nov 24 19:45:29 2017
// Update Count    : 0
// Status          : Unknown, Use with caution!

module spi (/*AUTOARG*/
   // Outputs
   MISO, spi_data_out, spi_data_stb, spi_tsx_start,
   // Inputs
   clk, rst, SCK, MOSI, SSEL, spi_data_in
   ) ;
   input clk;
   input rst;

   input SCK, MOSI, SSEL;
   output MISO;

   output reg [7:0] spi_data_out;
   output 	spi_data_stb;
   input [7:0] 	spi_data_in;
   output  	spi_tsx_start;

   // Synchronizing the inputs
   reg [2:0] 	SCK_sync;
   reg [2:0] 	SSEL_sync;
   reg [1:0] 	MOSI_sync;
   always @(posedge clk) begin
      SCK_sync <= {SCK_sync[1:0], SCK};
      SSEL_sync <= {SSEL_sync[1:0], SSEL};
      MOSI_sync <= {MOSI_sync[0], MOSI};
   end

   wire SCK_rising = SCK_sync[2:1] == 2'b01;
   wire SCK_falling = SCK_sync[2:1] == 2'b10;
   wire SSEL_rising = SSEL_sync[2:1] == 2'b01;
   wire SSEL_falling = SSEL_sync[2:1] == 2'b10;
   wire SSEL_active = ~SSEL_sync[1];
   wire MOSI_data = MOSI_sync[1];
   assign spi_tsx_start = SSEL_falling;

   reg [2:0] bits;
   reg 	     byte_received;
   reg [7:0] byte_data_received;
   always @(posedge clk) begin
      if(rst) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 bits <= 3'h0;
	 byte_data_received <= 8'h0;
	 byte_received <= 1'h0;
	 // End of automatics
      end
      
      else if(~SSEL_active)
	bits <= 3'b0;
      else begin
	 if(SCK_rising) begin
	    bits <= bits + 3'b1;
	    byte_data_received <= {byte_data_received[6:0], MOSI_data};
	    if(bits==3'b111)
	      spi_data_out <= {byte_data_received[6:0], MOSI_data};
	 end
      end // else: !if(~SSEL_active)

      byte_received <= SSEL_active && SCK_rising && (bits==3'b111);
   end
   
   assign spi_data_stb = byte_received;



   reg [7:0] byte_data_sent;
   always @(posedge clk) begin
      if(rst) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 byte_data_sent <= 8'h0;
	 // End of automatics
      end
      
      else if(SSEL_active) begin
	 if(SSEL_falling)
	   byte_data_sent <= spi_data_in;
	 if(SCK_falling)
	   if(bits==3'b000)
	     byte_data_sent <= spi_data_in;
	   else
	     byte_data_sent <= {byte_data_sent[6:0], 1'b0};
      end // if (SSEL_active)
   end // always @ (posedge clk)

   assign MISO = byte_data_sent[7];

`ifdef FORMAL

   always @(posedge clk) begin
      if($initstate) begin 
	 assume(spi_data_stb == 0);
	 assume($past(spi_data_stb) == 0);
      end
      
      // Assert that spi_data_stb cannot be high for more than 1 out
      // of 3 cycles. Needed for assumptions in controller.v
      if($past(spi_data_stb,2)) begin
	 assert(!$past(spi_data_stb));
	 assert(!spi_data_stb);
      end
	   

   end
   
`endif
   
   
endmodule // spi
