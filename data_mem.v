module data_memory_unit(
    input clock,
    input write_enable,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

// Memory array declaration
  reg [31:0] storage_array [0:63];  //declares an array of 64 memory location each 32 bits wide

// Write operation to ensure correct word addressing for 32-bit load/store
always @(posedge clock) 
  begin
    if (write_enable)   // this perform memory write on the positive edge of the clock
    begin
      storage_array[address[31:2]] <= write_data;  //bottom 2 bits of the address [1:0] are ignored
    end
  end

// This block performs combinational memory read (asynchronous).
always @(*)
  begin
    read_data = storage_array[address[31:2]];
  end

endmodule
