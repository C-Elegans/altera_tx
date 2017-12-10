module iq_mod (/*AUTOARG*/
   // Outputs
   dac_data,
   // Inputs
   clk, rst, phase, i_mul, q_mul
   ) ;
   input clk;
   input rst;
   input [7:0] phase;
   input [7:0] i_mul;
   input [7:0] q_mul;
   output reg [7:0] dac_data;

   wire [7:0] 	data_i;
   wire [7:0] 	data_q;
   wire [15:0] 	res_i;
   wire [15:0] 	res_q;
   

   sin_table tab(
		 // Outputs
		 .data_i		(data_i[7:0] ),
		 .data_q		(data_q[7:0]),
		 // Inputs
		 .clk			(clk),
		 .addr			(phase[7:0]));
   mult m1(
	   // Outputs
	   .out				(res_i[15:0]),
	   // Inputs
	   .clk				(clk),
	   .areset			(rst),
	   .dataa			(data_i[7:0]),
	   .datab			(i_mul[7:0]));
   mult m2(
	   // Outputs
	   .out				(res_q[15:0]),
	   // Inputs
	   .clk				(clk),
	   .areset			(rst),
	   .dataa			(data_q[7:0]),
	   .datab			(q_mul[7:0]));

   always @(posedge clk) begin
      // Combine i and q samples, convert to unsigned centered around 128
      dac_data <= (res_q[15:8] + res_i[15:8]) ^ 128;
   end

   
   
endmodule // iq_mod
