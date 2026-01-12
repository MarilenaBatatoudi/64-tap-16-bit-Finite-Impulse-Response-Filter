module fifo (
    input wire clk1,
    input wire clk2,
    input wire reset,
    input wire w_en,
    input wire r_en,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    output wire full,
    output wire empty
);

    localparam DEPTH = 1; //setting the depth to 1 as indicated in EdDiscussion
    localparam ADDR = 1;

    reg [15:0] mem [0:DEPTH-1];
    reg [ADDR-1:0] w_pt; //write pointer
    reg [ADDR-1:0] r_pt; //read pointer
    reg valid;
    wire nvalid;

    assign full = valid && (w_pt == r_pt);
    assign empty = ~valid;

    assign nvalid = (w_en && !full) ? 1 : 
                    (r_en && !empty) ? 0 : valid;

    always @(posedge clk1 or posedge reset)
    begin
        if(reset)
        begin
            w_pt <= 0;
            valid <= 0; 
        end
        else
        begin
            if (w_en && !full)
                mem[w_pt] <= data_in;

            valid <= nvalid; // Update valid
        end
    end

    always @(posedge clk2 or posedge reset)
    begin
        if(reset)
        begin
            r_pt <= 0;
            data_out <= 0;
        end
        else if(r_en && !empty)
        begin
            data_out <= mem[r_pt];
        end
    end
    
endmodule
