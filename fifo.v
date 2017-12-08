//                              -*- Mode: Verilog -*-
// Filename        : fifo.v
// Description     : Single clocked fifo
// Author          : Michael Nolan
// Created On      : Wed Nov 29 11:07:42 2017
// Last Modified By: Michael Nolan
// Last Modified On: Wed Nov 29 11:07:42 2017
// Update Count    : 0
// Status          : Unknown, Use with caution!
`ifdef FIFO
 `define ASSUME assert
 // `define ASSUME assume
`else
 `define ASSUME assume
`endif

module fifo (/*AUTOARG*/
   // Outputs
   fifo_data, fifo_space_free, full, empty,
   // Inputs
   clk, rst, fifo_data_in, rdreq, wrreq
   ) ;
   // Fifo is 2^LG_FIFO_DEPTH words deep
`ifdef FORMAL
   parameter LG_FIFO_DEPTH = 4;
`else
   parameter LG_FIFO_DEPTH = 12;
`endif
   input clk;
   input rst;

   // Data input
   input [7:0] fifo_data_in;
   // Read and write requests
   input       rdreq;
   input       wrreq;

   // Data output
   output [7:0] fifo_data;
   // Number of words free
   output [LG_FIFO_DEPTH:0] fifo_space_free;
   // Full and empty flags
   output 	 full;
   output 	 empty;

   // Read and write pointers
   reg [LG_FIFO_DEPTH:0] rdptr;
   reg [LG_FIFO_DEPTH:0] wrptr;

   // The fifo memory
   reg [7:0] 		 mem[0:(1<<LG_FIFO_DEPTH)-1];

   // Full flag
   // Full is asserted when the fifo pointers are the same in all but
   // the top bits, meaning one has overflowed when the other has not 
   assign full = rdptr[LG_FIFO_DEPTH-1:0] == wrptr[LG_FIFO_DEPTH-1:0] &&
		 rdptr[LG_FIFO_DEPTH] != wrptr[LG_FIFO_DEPTH];
   // Empty is just the opposite, it's set when both pointers are equal
   assign empty = rdptr == wrptr;

   // Fifo output
   assign fifo_data = mem[rdptr[LG_FIFO_DEPTH-1:0]];

   assign fifo_space_free = {!rdptr[LG_FIFO_DEPTH],rdptr[LG_FIFO_DEPTH-1:0]}-wrptr;

   wire [LG_FIFO_DEPTH+1:0] temp = wrptr + 1 & 31;
   // Read process
   always @(posedge clk) begin
      if(rst == 1) begin
	 rdptr <= 0;
      end
      if(rdreq) begin
	 rdptr <= rdptr + 1;
      end
      
      
   end
   // Write process
   always @(posedge clk) begin
      if(rst == 1) begin
	 wrptr <= 0;
      end
      if(wrreq) begin
	 mem[wrptr[LG_FIFO_DEPTH-1:0]] <= fifo_data_in;
	 wrptr <= wrptr + 1;
      end
      
   end // always @ (posedge clk)
   

`ifdef FORMAL
   // Next state for read and write pointers
   reg [LG_FIFO_DEPTH:0] temp_wrptr;
   reg [LG_FIFO_DEPTH:0] temp_rdptr;
   always @(posedge clk) begin
       temp_wrptr = wrptr + 1;
       temp_rdptr = rdptr + 1;
   end

   always @(posedge clk) begin
      // Set up initial state
      if($initstate) begin
	 assume(rst == 1);
	 `ASSUME(rdreq == 0);
	 `ASSUME(wrreq == 0);
	 assume(wrptr == 0);
	 assume(rdptr == 0);
	 assume(empty == 0);
	 assume($past(empty) == 0);
      end
      
      else begin
	 assume(rst == 0);
	 // Assert that the fifo doesnt become empty if there is no read request
	 if($past(empty) == 0 && !$past(rdreq))
	   assert(empty == 0);
	 // Assume that there are no reads when the fifo is
	 // empty. These become asserts when FIFO is defined (used for
	 // multi module proving)
	 `ASSUME  (!(empty && rdreq));
	 `ASSUME  (!(full && wrreq));

	 // Assert that the read pointer never leads the write
	 // pointer. Needed for induction proof
	 assert(fifo_space_free <= 1<<LG_FIFO_DEPTH);

	 // Assert that the fifo shows the correct space on startup
	 if($past(rst))
	    assert(fifo_space_free == 1<< LG_FIFO_DEPTH);

	 // Assert that the fifo behaves correctly on write
	 if ($past(wrreq) && !$past(rdreq)) begin
	    // assert that the memory is written correctly
	    assert(mem[$past(wrptr[LG_FIFO_DEPTH-1:0])] == $past(fifo_data_in));
	    // assert that the pointer is updated correctly
	    assert(wrptr == temp_wrptr);
	    // Assert that the space free decreases
	    assert(fifo_space_free == $past(fifo_space_free)-1);
	 end

	 if($past(rdreq) && !$past(wrreq)) begin
	    // Assert that the memory gets read from correctly
	    assert($past(fifo_data) == mem[$past(rdptr[LG_FIFO_DEPTH-1:0])]);
	    // Assert that the pointer is updated
	    assert(rdptr == temp_rdptr);
	    // Assert that the space free increases
	    assert(fifo_space_free == $past(fifo_space_free)+1);
	 end
	 
	 
      end // else: !if($initstate)
      
   end // always @ (posedge clk)

`endif //  `ifdef FORMAL
   


endmodule // fifo
