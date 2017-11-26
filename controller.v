//                              -*- Mode: Verilog -*-
// Filename        : controller.v
// Description     : Recieves and sends packets over SPI and controls the frequency synthesizer and sends samples to the iq fifo
// Author          : Michael Nolan
// Created On      : Sat Nov 25 13:21:41 2017
// Last Modified By: Michael Nolan
// Last Modified On: Sat Nov 25 13:21:41 2017
// Update Count    : 0
// Status          : Unknown, Use with caution!
`timescale 1ns/1ps

`ifdef FORMAL
 `define assert(__x__) assert(__x__)
`else
 `define assert(__x__)
`endif

module controller (/*AUTOARG*/
   // Outputs
   spi_c_data_out, freq_data, freq_wr_divr, freq_wr_divf,
   fifo_data_in, fifo_wr,
   // Inputs
   clk, rst, spi_c_data_in, spi_c_data_stb, spi_tsx_start,
   fifo_space_free, fifo_empty, fifo_full
   ) ;
   input clk, rst;
   input [7:0] spi_c_data_in;
   output reg [7:0] spi_c_data_out;
   input 	    spi_c_data_stb;
   input 	    spi_tsx_start;
   input [11:0]     fifo_space_free;

   output reg [7:0]     freq_data;
   output reg 		freq_wr_divr;
   output reg 		freq_wr_divf;

   input 		fifo_empty;
   input 		fifo_full;
   output reg [7:0] 	fifo_data_in;
   output reg		fifo_wr;

   localparam [4:0] //auto enum cntrl_state
     C_IDLE		= 5'b00000,
     C_PCKT_TYPE	= 5'b00001,
     C_NBYTES		= 5'b00010,
     C_DATA		= 5'b00011,

     P_GET_SPACE	= 5'b01000,
     P_GET_SPACE_2	= 5'b01001,

     P_SET_DIVR		= 5'b10000,
     P_SET_DIVF		= 5'b10001,

     P_FIFO_DATA	= 5'b11000;


   reg [4:0] //auto enum cntrl_state
	     state;

   reg [7:0] packet_type;
   reg [7:0] msg_bytes;

   always @(posedge clk) begin
      freq_wr_divr <= 0;
      freq_wr_divf <= 0;
      fifo_wr <= 0; 
      if(rst) begin
	 state <= C_IDLE;
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 fifo_data_in <= 8'h0;
	 fifo_wr <= 1'h0;
	 freq_data <= 8'h0;
	 freq_wr_divf <= 1'h0;
	 freq_wr_divr <= 1'h0;
	 msg_bytes <= 8'h0;
	 packet_type <= 8'h0;
	 spi_c_data_out <= 8'h0;
	 // End of automatics
      end
      else

	case(state)
	  C_IDLE: begin
	     if(spi_tsx_start) begin
		state <= C_PCKT_TYPE;
		spi_c_data_out <= 8'hA5;
	     end
	  end // case: state...
	  C_PCKT_TYPE: begin
	     if(spi_c_data_stb) begin
		state <= C_NBYTES;
		packet_type <= spi_c_data_in;
	     end
	  end // case: C_PCKT_TYPE
	  C_NBYTES:
	    if(spi_c_data_stb) begin
	       msg_bytes <= spi_c_data_in;
	       if(packet_type > 8'b11)
		 state <= C_IDLE;
	       else
		 state <= {packet_type[1:0] , 3'b0};
	    end // if (spi_c_data_stb)

	  P_GET_SPACE: begin
	     spi_c_data_out <= {4'b0, fifo_space_free[11:8]};
	     if(spi_c_data_stb)
	       state <= P_GET_SPACE_2;
	  end
	  P_GET_SPACE_2: begin
	     spi_c_data_out <= fifo_space_free[7:0];
	     state <= C_IDLE;
	  end

	  P_SET_DIVR: begin
	     if(spi_c_data_stb) begin
		state <= P_SET_DIVF;
		freq_data <= spi_c_data_in;
		freq_wr_divr <= 1;
	     end
	  end
	  P_SET_DIVF: begin
	     if(spi_c_data_stb) begin
		state <= C_IDLE;
		freq_data <= spi_c_data_in;
		freq_wr_divf <= 1;
	     end
	  end

	  P_FIFO_DATA: begin
	     if(spi_c_data_stb) begin
		fifo_data_in <= spi_c_data_in;
		fifo_wr <= 1;
		spi_c_data_out <= fifo_space_free[7:0];
		
		msg_bytes <= msg_bytes - 1;

		
	     end
	     if(msg_bytes == 0||fifo_full == 1) begin
		state <= C_IDLE;
	     end
	  end // case: P_FIFO_DATA
	  
	  
	  

	  default: begin
	     state <= C_IDLE;
	     `assert(0);
	  end
	endcase // case state
      
   end // always @ (posedge clk)
   
      

   /*AUTOASCIIENUM("state", "state_ascii")*/
   // Beginning of automatic ASCII enum decoding
   reg [103:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	C_IDLE:        state_ascii = "c_idle       ";
	C_PCKT_TYPE:   state_ascii = "c_pckt_type  ";
	C_NBYTES:      state_ascii = "c_nbytes     ";
	C_DATA:        state_ascii = "c_data       ";
	P_GET_SPACE:   state_ascii = "p_get_space  ";
	P_GET_SPACE_2: state_ascii = "p_get_space_2";
	P_SET_DIVR:    state_ascii = "p_set_divr   ";
	P_SET_DIVF:    state_ascii = "p_set_divf   ";
	P_FIFO_DATA:   state_ascii = "p_fifo_data  ";
	default:       state_ascii = "%Error       ";
      endcase
   end
   // End of automatics
`ifdef FORMAL
   initial assume(rst == 1);
   initial assume(fifo_wr == 0);
   initial assume(freq_wr_divf == 0);
   initial assume(freq_wr_divr == 0);

      
	
   always @(posedge clk) begin
      if($initstate) begin
	 assume($past(fifo_full) == 0);
	 assume($past(state) == C_IDLE);
      end
      else begin
	 assert(!($past(fifo_full) && fifo_wr));
      end // else: !if($initstate)
      if($past(fifo_full) == 0 && !fifo_wr)
	assume(fifo_full == 0);
      if($past(spi_c_data_stb))
	assume(spi_c_data_stb == 0);

      if($past(state) != P_SET_DIVF) begin
	 assert(freq_wr_divf == 0);
      end
      
      if($past(state) != P_SET_DIVR) begin
	 assert(freq_wr_divr == 0);
      end
      if($past(state) == C_NBYTES && $past(packet_type) > 3 && $past(spi_c_data_stb))
	assert(state == C_IDLE);
      
					    
      
   end
   

`endif
   
   
endmodule // controller
