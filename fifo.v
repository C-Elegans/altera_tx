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
`else
 `define ASSUME assume
`endif

module fifo (/*AUTOARG*/
   // Outputs
   fifo_data, fifo_space_free, full, empty,
   // Inputs
   clk, rst, fifo_data_in, rdreq, wrreq
   ) ;
   parameter LG_FIFO_DEPTH = 12;
   input clk;
   input rst;

   input [7:0] fifo_data_in;
   input       rdreq;
   input       wrreq;

   output [7:0] fifo_data;
   output [LG_FIFO_DEPTH:0] fifo_space_free;
   output 	 full;
   output 	 empty;

   reg [LG_FIFO_DEPTH:0] rdptr;
   reg [LG_FIFO_DEPTH:0] wrptr;
   reg [7:0] 		 mem[0:(1<<LG_FIFO_DEPTH)-1];
   assign full = rdptr[LG_FIFO_DEPTH-1:0] == wrptr[LG_FIFO_DEPTH-1:0] &&
		 rdptr[LG_FIFO_DEPTH] != wrptr[LG_FIFO_DEPTH];
   assign empty = rdptr == wrptr;

   assign fifo_data = mem[rdptr[LG_FIFO_DEPTH-1:0]];
   assign fifo_space_free = {!rdptr[LG_FIFO_DEPTH],rdptr[LG_FIFO_DEPTH-1:0]}-wrptr;

   // Read process
   always @(posedge clk) begin
      if(rst == 1) begin
	 rdptr <= 0;
      end
      if(rdreq) begin
	 rdptr <= rdptr + 1;
      end
      
      
   end
   
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
   `ASSUME property (!(empty && rdreq));
   `ASSUME property (!(full && wrreq));
   always @(posedge clk) begin
      if($initstate) begin
	 assume(rst == 1);
	 `ASSUME(rdreq == 0);
	 `ASSUME(wrreq == 0);
      end
      
      else begin
	 if($past(rst))
	    assert(fifo_space_free == 1<< LG_FIFO_DEPTH);
	 assume(rst == 0);
	 if ($past(wrreq) && !$past(rdreq)) begin
	    assert(mem[$past(wrptr[LG_FIFO_DEPTH-1:0])] == $past(fifo_data_in));
	    assert(wrptr == ($past(wrptr) + 1) & (1<<LG_FIFO_DEPTH)-1 );
	    assert(fifo_space_free == $past(fifo_space_free)-1);
	 end
	 if($past(rdreq) && !$past(wrreq)) begin
	    assert($past(fifo_data) == mem[$past(rdptr[LG_FIFO_DEPTH-1:0])]);
	    assert(rdptr == $past(rdptr) + 1);
	    assert(fifo_space_free == $past(fifo_space_free)+1);
	 end
	 
	 
      end // else: !if($initstate)
      
   end // always @ (posedge clk)

`endif //  `ifdef FORMAL
   


endmodule // fifo
