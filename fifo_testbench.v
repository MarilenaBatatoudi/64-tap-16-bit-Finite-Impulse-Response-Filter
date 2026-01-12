`timescale 1ns / 1ps

module fifo_tb();

    localparam CLK1_P = 100_000; // Clock period for clk1, write clock (10 kHz)
    localparam CLK2_P = 100;     // Clock period for clk2, read clock (10 MHz)

    reg clk1, clk2, reset;
    reg w_en, r_en;
    reg [15:0] data_in;
    wire [15:0] data_out;
    wire full, empty;

    integer i;

    // Instantiating a FIFO instance
    fifo fifo_instance (
        .clk1(clk1),
        .clk2(clk2),
        .reset(reset),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Generating clk1
    initial 
    begin
        clk1 = 0;
        forever #(CLK1_P / 2) clk1 = ~clk1;
    end

    // Generating clk2
    initial 
    begin
        clk2 = 0;
        forever #(CLK2_P / 2) clk2 = ~clk2;
    end

    initial 
    begin
        reset = 1;
        w_en = 0;
        r_en = 0;
        data_in = 0;
        i = 0;

        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        // Reset FIFO
        #100 reset = 0;

        // Nested loops to test the functionality of both clocks
        for (i = 0; i < 10; i = i + 1) 
	begin
            @(posedge clk1);
            w_en = 1;
            data_in = $random; //random 16-bit data
            $display("Writing: %h at time %t", data_in, $time);
            @(posedge clk1);
            w_en = 0;

            // Inner loop: Read from FIFO during the write period
            repeat(100) 
    	    begin
                @(posedge clk2);
                r_en = 1;
                @(posedge clk2);
                if (!empty) 
		begin
                    $display("Reading: %h at time %t", data_out, $time);
                end
                r_en = 0;
            end
        end

        //further reset testing
        #200;
        reset = 1;
        #100;
        reset = 0;

        // Finish simulation
        #1000;
        $finish;
    end

endmodule
