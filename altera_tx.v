`default_nettype none
module altera_tx(/*AUTOARG*/
   // Outputs
   MISO, DAC_OUT,
   // Inputs
   CLOCK_50, MOSI, SCK, SSEL, SW
   );
   input CLOCK_50;
   input MOSI, SCK, SSEL;
   output MISO;
   output [7:0] DAC_OUT;
   input [3:0] 	SW;

   wire [7:0] 	i_mul, q_mul;
   wire [7:0] 	phase;

   wire 	clk, rst, en;

   wire [7:0] 	spi_data_out;
   wire [7:0] 	spi_data_in;
   wire 	spi_data_stb;
   wire 	spi_tsx_start;

   /*AUTOWIRE*/
   wire			fifo_empty;			// From fifo of fifo.v
   wire			fifo_full;			// From fifo of fifo.v
   wire [7:0]		fifo_data;			// From fifo of fifo.v
   wire [11:0]		fifo_space_free;			// From fifo of fifo.v
   wire 		fifo_rd, fifo_wr;
   wire [7:0] 		fifo_data_in;

   wire [7:0]		freq_data;		// From controller of controller.v
   wire			freq_wr_divf;		// From controller of controller.v
   wire			freq_wr_divr;		// From controller of controller.v
   pll pllinst(
	       // Outputs
	       .c0			(clk),
	       .locked			(rst),
	       // Inputs
	       .inclk0			(CLOCK_50));

   iq_mod modulator(
		    // Outputs
		    .dac_data		(DAC_OUT[7:0]),
		    // Inputs
		    .clk		(clk),
		    .rst		(rst),
		    .phase		(phase[7:0]),
		    .i_mul		(i_mul[7:0]),
		    .q_mul		(q_mul[7:0]));
   phase_accum vco(
		   // Outputs
		   .phase		(phase[7:0]),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .en			(en),
		   .data		(freq_data[7:0]),
		   .wr_divr		(freq_wr_divr),
		   .wr_divf		(freq_wr_divf));
   spi spi(
	   // Outputs
	   .MISO			(MISO),
	   .spi_data_out		(spi_data_out[7:0]),
	   .spi_data_stb		(spi_data_stb),
	   .spi_tsx_start(spi_tsx_start),
	   // Inputs
	   .clk				(clk),
	   .rst				(rst),
	   .SCK				(SCK),
	   .MOSI			(MOSI),
	   .SSEL			(SSEL),
	   .spi_data_in			(spi_data_in[7:0]));
   controller controller(
			 // Outputs
			 .spi_c_data_out	(spi_data_in[7:0]),
			 .freq_data		(freq_data[7:0]),
			 .freq_wr_divr		(freq_wr_divr),
			 .freq_wr_divf		(freq_wr_divf),
			 // Inputs
			 .clk			(clk),
			 .rst			(rst),
			 .spi_c_data_in		(spi_data_out[7:0]),
			 .spi_c_data_stb	(spi_data_stb),
			 .spi_tsx_start		(spi_tsx_start),
			 .fifo_space_free	(fifo_space_free[11:0]),
			 /*AUTOINST*/
			 // Outputs
			 .fifo_data_in		(fifo_data_in[7:0]),
			 .fifo_wr		(fifo_wr),
			 // Inputs
			 .fifo_empty		(fifo_empty),
			 .fifo_full		(fifo_full));
   fifo fifo(
	     // Outputs
	     .empty			(fifo_empty),
	     .full			(fifo_full),
	     .q				(fifo_data[7:0]),
	     .usedw			(fifo_space_free[11:0]),
	     // Inputs
	     .clock			(clk),
	     .data			(fifo_data_in[7:0]),
	     .rdreq			(fifo_rd),
	     .sclr			(rst),
	     .wrreq			(fifo_wr));
   sampler sampler(
		   // Outputs
		   .fifo_rd		(fifo_rd),
		   .sample_i		(i_mul[7:0]),
		   .sample_q		(q_mul[7:0]),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .fifo_empty		(fifo_empty),
		   .fifo_data_out	(fifo_data[7:0]));
   
   

endmodule
