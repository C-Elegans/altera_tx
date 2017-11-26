module sin_table (/*AUTOARG*/
   // Outputs
   data_i, data_q,
   // Inputs
   clk, addr
   ) ;
   input clk;
   input [7:0] addr;
   output reg [7:0] data_i;
   output reg [7:0] data_q;

   reg [7:0] 	    lookup_table [0:255];
   //reg [7:0] 	    lookup_table_2 [0:255];
   initial begin
      $readmemh("sins.hex", lookup_table);
      //$readmemh("sins.hex", lookup_table_2);
   end

   always @(posedge clk) begin
	 data_i <= lookup_table[addr];
	 data_q <= lookup_table[(addr-64) & 255];
   end

   
endmodule // sin_table
