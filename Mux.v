module Mux2x1 (
  input  [31:0] in1,
  input  [31:0] in2,
    input sel,
    output reg [31:0] out   // must be reg since assigned in always block
);

    always @(*) begin
      if (sel == 1'b0)     //using if else statement 
            out = in1;   
        else 
            out = in2;
    end

endmodule
