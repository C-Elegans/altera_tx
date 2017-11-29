module fpll (/*AUTOARG*/
   // Outputs
   rst, clk,
   // Inputs
   clkin
   ) ;
   input clkin;
   output rst;
   output clk;
   `ifdef ALTERA
   pll pllinst(
	       // Outputs
	       .c0			(clk),
	       .locked			(rst),
	       // Inputs
	       .inclk0			(clkin));
   `else // !`ifdef ALTERA
   reg 	  rst_init = 1;
   always @(posedge clk)
     rst_init <= 0;
   assign clk = clkin;
   `endif // !`ifdef ALTERA
   
endmodule // fpll
