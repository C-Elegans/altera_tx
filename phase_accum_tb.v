//deps: phase_accum.v, sin_table.v
`timescale 1ns/1ps
module phase_accum_tb (/*AUTOARG*/) ;
   /*autowire*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		data_i;			// From tab of sin_table.v
   wire [7:0]		data_q;			// From tab of sin_table.v
   wire [7:0]		phase;			// From uut of phase_accum.v
   // End of automatics
   wire [7:0]		addr;			// To tab of sin_table.v
   assign addr = phase;
   /*autoreginput*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   // End of automatics
   reg			clk = 0;			// To uut of phase_accum.v
   reg [7:0]		data = 0;			// To uut of phase_accum.v
   reg			en = 0;			// To uut of phase_accum.v
   reg			rst = 1;			// To uut of phase_accum.v
   reg			wr_divf = 0;		// To uut of phase_accum.v
   reg			wr_divr = 0;		// To uut of phase_accum.v

   phase_accum uut(/*autoinst*/
		   // Outputs
		   .phase		(phase[7:0]),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .en			(en),
		   .data		(data[7:0]),
		   .wr_divr		(wr_divr),
		   .wr_divf		(wr_divf));
   sin_table tab(/*autoinst*/
		 // Outputs
		 .data_i		(data_i[7:0]),
		 .data_q		(data_q[7:0]),
		 // Inputs
		 .clk			(clk),
		 .addr			(addr[7:0]));
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #1000 $finish;
   end
   always #5 clk <= ~clk;

   initial begin
      #20 rst <= 0;
      data <= 20;
      wr_divr <= 1;
      @(posedge clk) wr_divr <= 0;
      data <= 63;
      wr_divf <= 1;
      @(posedge clk) wr_divf <= 0;
      @(posedge clk) en <= 1;
   end // initial begin
   
      
endmodule // phase_accum_tb
