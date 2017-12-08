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

module controller (/*AUTOARG*/
   // Outputs
   spi_c_data_out, freq_data, freq_wr_divr, freq_wr_divf,
   fifo_data_in, fifo_wr,
   // Inputs
   clk, rst, spi_c_data_in, spi_c_data_stb, spi_tsx_start,
   fifo_space_free, fifo_empty, fifo_full
   ) ;
   input clk, rst;
   // Data to and from the spi module
   input [7:0]      spi_c_data_in;
   output reg [7:0] spi_c_data_out;
   input 	    spi_c_data_stb;
   input 	    spi_tsx_start;
   input [12:0]     fifo_space_free;

   // Control signals for the frequency counter
   output reg [7:0]     freq_data;
   output reg 		freq_wr_divr;
   output reg 		freq_wr_divf;

   // Signals for writing to the fifo
   input 		fifo_empty;
   input 		fifo_full;
   output reg [7:0] 	fifo_data_in;
   output reg		fifo_wr;

   localparam [4:0] //auto enum cntrl_state
     C_IDLE		= 5'b00000,
     C_PCKT_TYPE	= 5'b00001,
     C_NBYTES		= 5'b00010,

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
	  // Idle state, waits for some data from the SPI module. 
	  C_IDLE: begin
	     if(spi_tsx_start) begin
		state <= C_PCKT_TYPE;
		spi_c_data_out <= 8'hA5;
	     end
	  end // case: state...
	  
	  // Receives the byte signifying the type of packet. Right
	  // now there are only 3 types:
	  // 2'b01: request for the number of items in the fifo
	  // 2'b10: Sets DIVR and DIVF of the frequency counter
	  // 2'b11: Writes nbytes to the fifo
	  C_PCKT_TYPE: begin
	     if(spi_c_data_stb) begin
		state <= C_NBYTES;
		packet_type <= spi_c_data_in;
	     end
	  end // case: C_PCKT_TYPE

	  // Gets the number of bytes of payload. Only really
	  // important with data for the fifo
	  C_NBYTES:
	    if(spi_c_data_stb) begin
	       msg_bytes <= spi_c_data_in;
	       if(packet_type > 8'b11)
		 state <= C_IDLE;
	       else
		 state <= {packet_type[1:0] , 3'b0};
	    end // if (spi_c_data_stb)

	  // Sends the most significant bits of the space free in the fifo
	  P_GET_SPACE: begin
	     spi_c_data_out <= {3'b0, fifo_space_free[12:8]};
	     if(spi_c_data_stb)
	       state <= P_GET_SPACE_2;
	  end // case: P_GET_SPACE
	  // Sends the least significant bits of the remaining space
	  // in the fifo
	  P_GET_SPACE_2: begin
	     spi_c_data_out <= fifo_space_free[7:0];
	     state <= C_IDLE;
	  end

	  // Sets the DIVR parameter in the frequency counter. wr_divr
	  // is reset at the beginning of the always block so does not
	  // need to be reset here
	  P_SET_DIVR: begin
	     if(spi_c_data_stb) begin
		state <= P_SET_DIVF;
		freq_data <= spi_c_data_in;
		freq_wr_divr <= 1;
	     end
	  end
	  // Same thing for divf
	  P_SET_DIVF: begin
	     if(spi_c_data_stb) begin
		state <= C_IDLE;
		freq_data <= spi_c_data_in;
		freq_wr_divf <= 1;
	     end
	  end

	  // Writes bytes to the fifo until either the fifo is full or
	  // msg_bytes == 0
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
      // Set up the initial (reset) state
      if($initstate) begin
	 assume($past(fifo_full) == 0);
	 assume($past(state) == C_IDLE);
	 assume(state == C_IDLE);
      end
      else begin
	 
	 assume(rst == 0);
	 // Prove that the fifo cannot overflow
	 assert(!($past(fifo_full) && fifo_wr));

      end // else: !if($initstate)


      // Assume that the fifo will not raise fifo_full if there was
      // not a write in the previous cycle. Proven in fifo.v
      if($past(fifo_full) == 0 && !$past(fifo_wr)) // 
	assume(fifo_full == 0);

      // Assume that spi_c_data_stb cannot be high for more than 1 out
      // of every 3 cycles. Proven in spi.v
      if($past(spi_c_data_stb,2)) begin
	 assume($past(spi_c_data_stb) == 0);
	 assume(spi_c_data_stb == 0);
      end
      
      // Assert that wr_divf doesnt get set in any state other than SET_DIVF
      if($past(state) != P_SET_DIVF) begin
	 assert(freq_wr_divf == 0);
      end
      // Same thing with SET_DIVR
      if($past(state) != P_SET_DIVR) begin
	 assert(freq_wr_divr == 0);
      end

      // Assert that given an invalid state byte we move back to idle
      if($past(state) == C_NBYTES && 
	 $past(packet_type) > 3 && 
	 $past(spi_c_data_stb))
	assert(state == C_IDLE);

      
      case($past(state))
	// Make sure the next state is either idle or packet type
	C_IDLE:
	  assert((state == C_IDLE )|| (state == C_PCKT_TYPE));
	// make sure the next state is either the same or nbytes
	// make sure packet_type gets set to the incoming byte
	C_PCKT_TYPE: begin
	   assert(state == C_PCKT_TYPE || state == C_NBYTES);
	   if(!$stable(state))
	     assert(packet_type == $past(spi_c_data_in));
	end

	// Make sure the next state is set to that specified in the packet
	// Make sure msg_bytes gets set to the incoming data
	C_NBYTES: begin
	   assert(state == C_IDLE || state == C_NBYTES || state == {$past(packet_type[1:0]),3'b0});
	   if(!$stable(state))
	     assert(msg_bytes == $past(spi_c_data_in));
	   end
	// Same thing, make sure the state transitions are valid
	P_GET_SPACE:
	  assert(state == P_GET_SPACE || state == P_GET_SPACE_2);
	P_GET_SPACE_2:
	  assert(state == P_GET_SPACE_2 || state == C_IDLE);

	P_SET_DIVR:
	  assert(state == P_SET_DIVR || state == P_SET_DIVF);
	P_SET_DIVF:
	  assert(state == P_SET_DIVF || state == C_IDLE);
	P_FIFO_DATA:
	  assert(state == P_FIFO_DATA || state == C_IDLE);
	default:
	  assert(0);
	  
      endcase // case ($past(state))

      // Assert that wr_divr and wr_divf get reset after being set
      if($past(freq_wr_divr) == 1)
	assert(freq_wr_divr == 0);
      if($past(freq_wr_divf) == 1)
	assert(freq_wr_divf == 0);
      
					    
      
   end
   

`endif
   
   
endmodule // controller
