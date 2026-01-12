module cmem (
        input clk,
        input [5:0] addr, //address is 6 bits for 64 taps
        input w_en, //write enable signal
        input [15:0] data_in, //input data
        output reg [15:0] data_out //output coefficient
);

        reg [15:0] sram [0:63]; //memory for the 64 coefficients

        always @(posedge clk) 
        begin
                if(w_en)
		begin
                        sram[addr] <= data_in; //write to memory
			data_out <= data_in;
		end
                else
		begin
                        data_out <= sram[addr];
		end
        end
        endmodule
