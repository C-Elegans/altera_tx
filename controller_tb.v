//deps: controller.v
`timescale 1ns/1ps
module controller_tb (/*AUTOARG*/) ;
   /*autowire*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		spi_c_data_out;		// From uut of controller.v
   // End of automatics
   /*autoreginput*/
   reg [11:0]		fifo_space_free = 435;	// To uut of controller.v
   reg			clk=0;			// To uut of controller.v
   reg			rst=1;			// To uut of controller.v
   reg [7:0]		spi_c_data_in = 0;		// To uut of controller.v
   reg			spi_c_data_stb = 0;		// To uut of controller.v
   reg			spi_tsx_start= 0;		// To uut of controller.v
   controller uut(/*autoinst*/
		  // Outputs
		  .spi_c_data_out	(spi_c_data_out[7:0]),
		  // Inputs
		  .clk			(clk),
		  .rst			(rst),
		  .spi_c_data_in	(spi_c_data_in[7:0]),
		  .spi_c_data_stb	(spi_c_data_stb),
		  .spi_tsx_start	(spi_tsx_start),
		  .fifo_space_free	(fifo_space_free[11:0]));

   always #5 clk <= ~clk;
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #200 $finish;
   end // initial begin
   initial begin
      #20 rst <= 0;
      @(posedge clk) spi_tsx_start <= 1;
      @(posedge clk) spi_tsx_start <= 0;
      @(posedge clk) spi_c_data_stb <= 1;
      spi_c_data_in <= 8'h1;
      @(posedge clk) spi_c_data_stb <= 0;

      @(posedge clk) spi_c_data_stb <= 1;
      spi_c_data_in <= 8'h2;
      @(posedge clk) spi_c_data_stb <= 0;
      @(posedge clk) spi_c_data_stb <= 1;
      @(posedge clk) spi_c_data_stb <= 0;
      @(posedge clk) spi_c_data_stb <= 1;
      @(posedge clk) spi_c_data_stb <= 0;
   end
   
endmodule // controller_tb
