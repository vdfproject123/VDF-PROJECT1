module PC_Nextlogic(
    input sel,
    input [31:0] curr_addr,
    input [31:0] offset,
    output [31:0] next_addr
);

    wire [31:0] addr_inc, addr_branch;

    assign addr_inc = curr_addr + 4;
    assign addr_branch = curr_addr + offset;

    assign next_addr = (sel) ? addr_branch : addr_inc;

endmodule
