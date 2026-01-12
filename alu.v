module alu (
	input clk,
	input signed [15:0] coeff,
	input signed [15:0] data,
	input [1:0] op_code,
	input [31:0] prev_acc, //accumulator input from the previous recursive discrete convolution
	output reg signed [31:0] result
);

	always @(posedge clk)
	begin
		case(op_code)
			2'b00:
				result <= 0;
			2'b01:
				result <= coeff*data;
			2'b10:
				result <= prev_acc + coeff*data;
			default:
				result <= 0;
		endcase
	end
	endmodule
