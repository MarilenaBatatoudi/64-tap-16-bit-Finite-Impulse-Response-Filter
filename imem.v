//rtl code for the imem memory block

module imem (
	input clk,
	input [13:0] addr, 
	input [15:0] data_in,
	input w_en, //write enable signal
	output reg [15:0] data_out
);

	reg [15:0] memory [0:63]; 

	always @(posedge clk) 
	begin
		if(w_en)
			memory[addr] <= data_in;
		data_out <= memory[addr];
	end 
	endmodule
