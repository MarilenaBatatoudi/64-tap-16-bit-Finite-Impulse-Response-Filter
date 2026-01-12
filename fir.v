module fir (
    input wire clk1,           // Input sampling clock
    input wire clk2,           // Core processing clock
    input wire rstn,           // Reset signal (active low)
    input wire valid_in,       // Validity signal for input data
    input wire [13:0] addr,    // Address for input memory
    input wire [15:0] data_in, // Input data (16-bit fixed-point)
    input wire w_en,           // Write enable for `imem`
    output reg valid_out,      // Validity signal for output data
    output reg [15:0] dout     // Filtered output (16-bit fixed-point)
);

    wire [15:0] imem_out;
    wire [15:0] fifo_out;
    wire [15:0] cmem_out;
    wire signed [31:0] alu_out;
    reg signed [31:0] accumulator;
    reg [5:0] tap_count;       // Counter for the filter taps (64 taps total)

    imem imem_inst (
        .clk(clk1),
        .addr(addr),
        .data_in(data_in),
        .w_en(w_en),
        .data_out(imem_out)
    );

    fifo fifo_inst (
        .clk1(clk1),
        .clk2(clk2),
        .reset(~rstn),
        .w_en(valid_in),
        .r_en(valid_out),
        .data_in(imem_out),    // Use output of `imem` as input to FIFO
        .data_out(fifo_out),
        .full(),
        .empty()
    );

    cmem cmem_inst (
        .clk(clk2),
        .addr(tap_count),
        .w_en(1'b0),           
	.data_in(16'b0),
        .data_out(cmem_out)
    );

    alu alu_inst (
        .clk(clk2),
        .coeff(cmem_out),
        .data(fifo_out),
        .op_code((tap_count == 0) ? 2'b01 : 2'b10), 
        .prev_acc(accumulator),
        .result(alu_out)
    );

   
    always @(posedge clk2 or negedge rstn) 
    begin
        if (!rstn) 
	begin
            tap_count <= 0;
            accumulator <= 0;
            dout <= 0;
            valid_out <= 0;
        end 
	else if (valid_in) 
	begin
            if (tap_count < 63) 
	    begin
                tap_count <= tap_count + 1;
                accumulator <= alu_out; // Accumulate the result
            end 
	    else 
	    begin
                tap_count <= 0;
                dout <= alu_out[31:16]; 
                valid_out <= 1;
                accumulator <= 0;      
            end
        end
    end
endmodule
