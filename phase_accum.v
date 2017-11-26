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
      phase <= accum_r;
   end // always @ (posedge clk)

`ifdef FORMAL
   assume property(!(wr_divf && wr_divr));
   
   always @(posedge clk) begin
      if($initstate) begin
	 assume($past(accum_f) == 0);
	 assume(accum_f == 0);
	 assume(rst == 1);
	 assume($past(wr_divf) == 0);
	 assume($past(data) == 0);
	 assume(data == 0);
	 assume(wr_divf == 0);
	 assume($past(wr_divr) == 0);
	 assume(wr_divr == 0);
	 assume(carry == 0);
	 assume(accum_r == 0);
	 assume(inc_r == 0);
      end
      else begin
	 assume(rst == 0);
	 assume(en == 1);
	 if(accum_f < $past(accum_f))
	   assert(carry);
	 if($past(wr_divf))
	   assert(inc_f == $past(data));
	 if($past(wr_divr))
	   assert(inc_r == $past(data));
	 if($past(carry))
	   assert(accum_r == (($past(accum_r) + $past(inc_r) + 1) & 8'hff));

      end // else: !if($initstate)
      

   end
   

   
`endif
   

endmodule // phase_accum
