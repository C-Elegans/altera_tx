//                              -*- Mode: Verilog -*-
// Filename        : sampler.v
// Description     : Pulls I and Q samples from the fifo at a designated sample rate and feeds them to the multipliers.
// Author          : Michael Nolan
// Created On      : Sun Nov 26 10:06:05 2017
// Last Modified By: Michael Nolan
// Last Modified On: Sun Nov 26 10:06:05 2017
// Update Count    : 0
// Status          : Unknown, Use with caution!

module sampler (/*AUTOARG*/
   // Outputs
   fifo_rd, sample_i, sample_q,
   // Inputs
   clk, rst, fifo_empty, fifo_data_out
   ) ;
   input clk;
   input rst;

   // Fifo signals
   input fifo_empty;
   input [7:0] fifo_data_out;
   output   reg fifo_rd;

   // sample output
   output reg [7:0] sample_i;
   output reg [7:0] sample_q;

   parameter CLOCK_RATE = 100_000_000;
   parameter SAMPLE_RATE = 10_000;
   //verilator lint_off WIDTH
   parameter [15:0] COUNT = (CLOCK_RATE/SAMPLE_RATE - 1);
   //verilator lint_on WIDTH

   reg [15:0] 	    counter;
   reg 		    counter_stb;

   always @(posedge clk) begin
      if(rst == 1) begin
	 counter <= COUNT;
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 counter_stb <= 1'h0;
	 // End of automatics
      end
      // Fires off counter_stb 10k times per second to tell the state
      // machine to update the samples
      counter_stb <= 0;
      if(counter == 0)begin
	 counter <= COUNT;
	 counter_stb <= 1;
      end
      
      else
	counter <= counter - 1;
   end
   // States:
   // 4'b0001 (IDLE) - waits for a strobe from the above counter
   // 4'b0010 (I_SAMPLE) - reads a sample from the fifo and outputs it to sample_i
   // 4'b0100 (PAUSE) - gives the fifo time to assert its empty flag
   // 4'b1000 (Q_SAMPLE) - reads a sample from the fifo and outputs it to sample_q
   localparam 			// auto enum state_t
     S_IDLE = 0,
     S_I_SAMPLE = 1,
     S_PAUSE = 2,
     S_Q_SAMPLE = 3;
   reg [3:0] //auto enum state_t
	     state;
     
   always @(posedge clk) begin
      if(rst) begin
	 state <= 1<<S_IDLE;
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 fifo_rd <= 1'h0;
	 sample_i <= 8'h0;
	 sample_q <= 8'h0;
	 // End of automatics
      end
      else begin 
	 // reset the read pointer
	 fifo_rd <= 0;
	 case(1)
	   state[S_IDLE]: begin
	      if(counter_stb) begin
		 state <= 1<<S_I_SAMPLE;
	      end
	   end
	   state[S_I_SAMPLE]: begin
	      if(!fifo_empty) begin
		 // The current fifo does not register the output so
		 // read it on the same cycle the fifo_rd is set
		 sample_i <= fifo_data_out;
		 fifo_rd <= 1;
	      end
	      // If the fifo is empty, set the sample to 0
	      else begin
		 sample_i <= 0;
	      end // else: !if(!fifo_empty)
	      state <= 1<<S_PAUSE;
	   end // case: state[S_I_SAMPLE]
	   state[S_PAUSE]:begin
	      // Pause to allow the fifo to set its empty flag
	      state <= 1<<S_Q_SAMPLE;
	   end
	   
	   state[S_Q_SAMPLE]: begin
	      if(!fifo_empty) begin
		 sample_q <= fifo_data_out;
		 fifo_rd <= 1;
	      end
	      else
		sample_q <= 0;
	      state <= 1<<S_IDLE;
	   end // case: state[S_Q_SAMPLE]
	   default:
	     state <= 1<<S_IDLE;
	 endcase // case (1)
	 
      end // else: !if(rst)
      

   end


   /*AUTOASCIIENUM("state", "state_ascii")*/
   // Beginning of automatic ASCII enum decoding
   reg [79:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	(4'b1<<S_IDLE):     state_ascii = "s_idle    ";
	(4'b1<<S_I_SAMPLE): state_ascii = "s_i_sample";
	(4'b1<<S_PAUSE):    state_ascii = "s_pause   ";
	(4'b1<<S_Q_SAMPLE): state_ascii = "s_q_sample";
	default:            state_ascii = "%Error    ";
      endcase
   end
   // End of automatics
   
   
`ifdef FORMAL
   always @(posedge clk) begin
      if($initstate) begin
	 assume(rst == 1);
	 assume(counter == COUNT);
	 assume(state == 1<<S_IDLE);
	 assume(counter_stb == 0);
	 assume(fifo_rd == 0);
      end
      else begin
	 assume(rst == 0);
	 // Prove that the counter doesnt over/underflow
	 assert (counter <= COUNT);
	 // Check that the state machine works
	 if($past(counter_stb))
	   assert(state[S_I_SAMPLE] == 1);
	 if($past(state[S_I_SAMPLE]))
	   assert(state[S_PAUSE]);
	 if($past(state[S_PAUSE]))
	   assert(state[S_Q_SAMPLE]);
	 if($past(state[S_Q_SAMPLE]))
	   assert(state[S_IDLE]);
	 // assert that the state is onehot
	 assert(state[0] + state[1] + state[2] + state[3] == 1);

	 // Assume that the fifo doesn't go empty unless a read is
	 // requested, proven in fifo.v
	 if(!$past(fifo_empty) && !$past(fifo_rd))
	   assume(!fifo_empty);

	 // Assert that fifo_rd is high for only one cycle at a time
	 if($past(fifo_rd))
	   assert(!fifo_rd);
	 // Prove that sampler.v cannot underflow the fifo 
	 assert(!(fifo_empty && fifo_rd));
      end 
   end // always @ (posedge clk)
   
      
`endif
   
 
endmodule // sampler
