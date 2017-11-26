//deps: spi.v
module spi_tb (/*AUTOARG*/) ;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			MISO;			// From uut of spi.v
   wire [7:0]		spi_data_out;		// From uut of spi.v
   wire			spi_data_stb;		// From uut of spi.v
   // End of automatics
   /*AUTOREGINPUT*/ 
   reg			MOSI = 0;			// To uut of spi.v
   reg			SCK = 0;			// To uut of spi.v
   reg			SSEL = 1;			// To uut of spi.v
   reg			clk = 1;			// To uut of spi.v
   reg			rst = 1;			// To uut of spi.v
   reg [7:0]		spi_data_in = 8'ha8;		// To uut of spi.v
   reg 			spi_en = 0;

   spi uut(/*AUTOINST*/
	   // Outputs
	   .MISO			(MISO),
	   .spi_data_out		(spi_data_out[7:0]),
	   .spi_data_stb		(spi_data_stb),
	   // Inputs
	   .clk				(clk),
	   .rst				(rst),
	   .SCK				(SCK),
	   .MOSI			(MOSI),
	   .SSEL			(SSEL),
	   .spi_data_in			(spi_data_in[7:0]));

   always #5 clk <= ~clk;
   initial #20 rst <= 0;
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #600 $finish;
   end
   always #30 if(spi_en) SCK <= ~SCK;

   initial begin
      #50 SSEL <= 0;
      #20 spi_en <= 1;
      #470 SSEL <= 1;
      spi_en <= 0;
   end
   initial begin
      @(negedge SSEL)
	  MOSI <= 0;
      #70 MOSI <= 1;
      #60 MOSI <= 0;
      #60 MOSI <= 0;
      #60 MOSI <= 1;
      #60 MOSI <= 0;
      #60 MOSI <= 0;
      #60 MOSI <= 1;
      end


endmodule // spi_tb
