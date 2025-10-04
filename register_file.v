module Register_file(
    input clk, 
    input reset, 
    input write_en, 
    input [31:0] write_data, 
    input [4:0] read_addr1, read_addr2, write_addr,
    output [31:0] read_data1, read_data2
);

    reg [31:0] array [31:0];
    integer i;

    // Reset and write logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for(i = 0; i < 32; i = i + 1)
                array[i] <= 32'b0;
        end else if (write_en) begin
            array[write_addr] <= write_data;
        end
    end

    // Continuous assignment for reads (combinational)
    assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 : array[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : array[read_addr2];

endmodule
