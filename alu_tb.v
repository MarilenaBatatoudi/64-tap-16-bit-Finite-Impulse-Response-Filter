`timescale 1ns/1ps

module alu_tb();

	reg clk;
	reg signed [15:0] a;
	reg signed [15:0] b;
	reg signed [31:0] acc;
	reg [1:0] op_code;
	wire signed [31:0] out;

	alu alu (
		.clk(clk),
		.coeff(a),
		.data(b),
		.prev_acc(acc),
		.op_code(op_code),
		.result(out)
	);

	//declaring variables
	reg signed [15:0] rand_a;
	reg signed [15:0] rand_b;
	reg signed [31:0] rand_acc;
	reg [1:0] rand_op;
	integer i;

	//initializing the clock
	initial clk = 0;
	always #5 clk = ~clk; //setting a 10ns period

	initial
	begin
		a = 0;
		b = 0;
		acc = 0;
		op_code = 2'b00;

		//waveform visualization
		$dumpfile("alu_tb.vcd");
		$dumpvars(0, alu_tb);

		$display("Conducting testbench with random fixed point inputs");

		for(i = 1; i < 31; i = i+1)
		begin
			//make sure that changes occur at the rising clk edge
			@(posedge clk);
			rand_a = $random % (2**15); //normalizing the randomly generated number
			rand_b = $random % (2**15); //normalizing 
			rand_acc = $random % (2**31); //normalizing it to the 32-bit signed range

			//normalize the 2-bit range for the opcode
			case ($random % 3)
				2'b00:
					rand_op = 2'b00; //reset
				2'b01:
					rand_op = 2'b01; //multiplication
				2'b10:
					rand_op = 2'b10; //multiply and accumulate
				default:
					rand_op = 2'b00; 
			endcase

			a <= rand_a;
			b <= rand_b;
			acc <= rand_acc;
			op_code <= rand_op;

			//ensure that 2 clock cycles pass for the inputs to
			//settle
			repeat (2) @(posedge clk);

			case(rand_op)
				2'b00:
					$display("Run %2d: Data = %d, Coefficient = %d, Accumulator = %d, Operation: Reset => Output = %d", i, rand_a, rand_b, rand_acc, out);

				2'b01:
					$display("Run %2d: Data = %d, Coefficient = %d, Accumulator = %d, Operation: Multiplication => Output = %d", i, rand_a, rand_b, rand_acc, out);
				2'b10:
					$display("Run %2d: Data = %d, Coefficient = %d, Accumulator = %d, Operation: Multiply and Accumulate => Output = %d", i, rand_a, rand_b, rand_acc, out);
				default:
					$display("Run %2d: Data = %d, Coefficient = %d, Accumulator = %d, Operation: Reset => Output = %d", i, rand_a, rand_b, rand_acc, out);
			endcase

		end

		$display("Done.");

		$finish;
	end
	endmodule
