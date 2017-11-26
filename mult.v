//                              -*- Mode: Verilog -*-
// Filename        : mult.v
// Description     : 8x8 multiplier
// Author          : Michael Nolan
// Created On      : Fri Nov 24 18:31:19 2017
// Last Modified By: Michael Nolan
// Last Modified On: Fri Nov 24 18:31:19 2017
// Update Count    : 0
// Status          : Unknown, Use with caution!

module mult (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, areset, dataa, datab
   ) ;
   input clk;
   input areset;
   input signed [7:0] dataa;
   input signed [7:0] datab;
   output signed [15:0] out;

   reg signed [7:0] 	 a_reg;
   reg signed [7:0] 	 b_reg;
   reg signed [15:0] 	 o_reg;
   assign out = o_reg;

   always @(posedge clk or posedge areset)
   begin
      if(areset == 1) begin
	 a_reg <= 8'b0;
	 b_reg <= 8'b0;
	 o_reg <= 16'b0;
      end
      else begin
	 a_reg <= dataa;
	 b_reg <= datab;
	 o_reg <= a_reg * b_reg;
      end // else: !if(areset == 1)
   end
   
endmodule // mult
