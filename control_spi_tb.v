module control_spi_tb (/*AUTOARG*/
   // Outputs
   MISO, spi_data_stb, freq_data, freq_wr_divr, freq_wr_divf,
   fifo_data_in, fifo_wr,
   // Inputs
   clk, rst, MOSI, SCK, SSEL, fifo_space_free, fifo_empty, fifo_full
   ) ;
   output MISO;
   input  clk, rst;
   wire [7:0]		spi_c_data_out;		// From c of controller.v
   wire [7:0]		spi_data_out;		// From spi of spi.v
   wire			spi_data_stb;		// From spi of spi.v
   wire			spi_tsx_start;		// From spi of spi.v
   wire [7:0] 		spi_c_data_in;
   wire [7:0] 		spi_data_in;
   wire 		spi_c_data_stb = spi_data_stb;
			
   assign spi_c_data_in = spi_data_out;
   assign spi_data_in = spi_c_data_out;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		MOSI;			// To spi of spi.v
   input		SCK;			// To spi of spi.v
   input		SSEL;			// To spi of spi.v
   input [11:0]		fifo_space_free;	// To c of controller.v
   input 		fifo_empty;
   input 		fifo_full;

   output		spi_data_stb;		// From spi of spi.v
   output [7:0] 	freq_data;
   output 		freq_wr_divr;
   output 		freq_wr_divf;
   
   /*autowire*/
   output [7:0]		fifo_data_in;		// From c of controller.v
   output 		fifo_wr;		// From c of controller.v


   spi spi(/*autoinst*/
	   // Outputs
	   .MISO			(MISO),
	   .spi_data_out		(spi_data_out[7:0]),
	   .spi_data_stb		(spi_data_stb),
	   .spi_tsx_start		(spi_tsx_start),
	   // Inputs
	   .clk				(clk),
	   .rst				(rst),
	   .SCK				(SCK),
	   .MOSI			(MOSI),
	   .SSEL			(SSEL),
	   .spi_data_in			(spi_data_in[7:0]));

   controller c(/*autoinst*/
		// Outputs
		.spi_c_data_out		(spi_c_data_out[7:0]),
		.freq_data		(freq_data[7:0]),
		.freq_wr_divr		(freq_wr_divr),
		.freq_wr_divf		(freq_wr_divf),
		.fifo_data_in		(fifo_data_in[7:0]),
		.fifo_wr		(fifo_wr),
		// Inputs
		.clk			(clk),
		.rst			(rst),
		.spi_c_data_in		(spi_c_data_in[7:0]),
		.spi_c_data_stb		(spi_c_data_stb),
		.spi_tsx_start		(spi_tsx_start),
		.fifo_space_free	(fifo_space_free[11:0]),
		.fifo_empty		(fifo_empty),
		.fifo_full		(fifo_full));
endmodule // control_spi_tb
