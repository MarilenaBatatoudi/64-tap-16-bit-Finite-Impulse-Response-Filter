`timescale 1ns / 1ps

module imem_tb();
	reg clk; 
	reg [5:0] addr; //6-bit address for the 64 coefficients
	reg w_en;
	reg [15:0] data_in;
	wire [15:0] data_out;

	imem imem_instance (
		.clk(clk),
		.addr(addr),
		.w_en(w_en),
		.data_in(data_in),
		.data_out(data_out)
	);

	integer i;

	initial 
	begin
		clk = 0;
		forever #5 clk =~ clk; //setting the clock period to 10ns
	end

	initial 
	begin
		w_en = 0;
		addr = 0;
		data_in = 0;

		$dumpfile("imem_tb.vcd");
		$dumpvars(0, imem_tb);

		$display("IMEM Write Test");
		for (i = 0; i <= 63; i = i + 1) 
		begin
			@(posedge clk);
			w_en = 1;
			addr = i[5:0];
			data_in = i + 16'h1000;
		end

		$display("IMEM Read Test");
		w_en = 0;
		for (i = 0; i <= 63; i = i + 1) 
		begin
			@(posedge clk);
			addr = i[5:0];
			@(posedge clk);
			$display("IMEM Address %d: %h (expected: %h)", addr, data_out, i + 16'h1000);
		end

		$display("Done");
		$finish;
	end
	endmodule
