module PC(
    input clk,
    input reset,
    input write_en,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            read_data <= 32'b0;
        else if (write_en)
            read_data <= write_data;
    end

endmodule
