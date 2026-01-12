`timescale 1ns/1ps

module fir_tb;

    reg clk1;                  // Input sampling clock (10 kHz)
    reg clk2;                  // Core processing clock (10 MHz)
    reg rstn;                  // Reset signal
    reg valid_in;              // Validity signal for input data
    reg [15:0] data_in;        // Input data
    reg [13:0] addr;           // Address for input memory
    reg w_en;                  // Write enable for imem
    wire valid_out;            // Output validity signal
    wire [15:0] dout;          // Filtered output

    fir fir_inst (
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .valid_in(valid_in),
        .data_in(data_in),
        .addr(addr),
        .w_en(w_en),
        .valid_out(valid_out),
        .dout(dout)
    );
	

    integer i;
    // Clock generation
    initial
    begin
        clk1 = 0;
        forever #50000 clk1 = ~clk1; // 10 kHz clock (period = 100 µs)
    end

    initial
    begin
        clk2 = 0;
        forever #50 clk2 = ~clk2; // 10 MHz clock (period = 100 ns)
    end

    initial
    begin

        rstn = 0;
        valid_in = 0;
        data_in = 16'b0;
        addr = 14'b0;
        w_en = 0;

        $dumpfile("fir_tb.vcd");
        $dumpvars(0, fir_tb);

        // Apply reset
        #200 rstn = 1;

        // Load coefficients into cmem using imem
        for (i = 0; i < 64; i = i + 1) 
	begin
            @(posedge clk1);
            w_en = 1;
            addr = i;
            data_in = $random % 65536; // Random 16-bit coefficient
        end
        @(posedge clk1);
        w_en = 0;

        // Apply input samples to FIR filter
        for (i = 0; i < 100; i = i + 1)
       	begin
            @(posedge clk1);
            valid_in = 1;
            data_in = $random % 65536; // Random 16-bit input sample
        end
        @(posedge clk1);
        valid_in = 0;

        while (!valid_out) @(posedge clk2); // Wait for first valid output
        for (i = 0; i < 100; i = i + 1)
       	begin
            @(posedge clk2);
            if (valid_out)
	    begin
                $display("Output[%0d]: %h", i, dout);
            end
        end

        $finish;
    end

endmodule
