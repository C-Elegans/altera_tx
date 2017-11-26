module phase_accum (/*AUTOARG*/
   // Outputs
   phase,
   // Inputs
   clk, rst, en, data, wr_divr, wr_divf
   ) ;
   input clk;
   input rst;
   input en;
   input [7:0] data;
   input       wr_divr;
   input       wr_divf;

   output reg [7:0] phase;

   reg [7:0] 	accum_r;
   reg [7:0] 	accum_f;
   reg [7:0] 	inc_r;
   reg [7:0] 	inc_f;
   reg 		carry;

   always @(posedge clk) begin
      if(rst) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 accum_f <= 8'h0;
	 accum_r <= 8'h0;
	 carry <= 1'h0;
	 // End of automatics
      end
      else if(en) begin
	 {carry, accum_f} <= accum_f + inc_f; 
	 accum_r <= accum_r + inc_r + carry;
      end
   end
   always @(posedge clk) begin
      if(rst) begin
	 /*autoreset*/
	 // Beginning of autoreset for uninitialized flops
	 inc_f <= 8'h0;
	 inc_r <= 8'h0;
	 phase <= 8'h0;
	 // End of automatics
      end
      else begin
	 if(wr_divf)
	   inc_f <= data;
	 if(wr_divr)
	   inc_r <= data;

      end // else: !if(rst)
      phase <= accum_r + 63;
   end // always @ (posedge clk)
   
   
endmodule // phase_accum
