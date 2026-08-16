# 64-Bit RCA

`default_nettype none

module rca # (
    parameter WIDTH = 64
) (
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

   wire [WIDTH:0] carry;
   assign carry[0] = c_in;
   assign c_out = carry[WIDTH];

   genvar i; 

   generate 
    for (i = 0; i < WIDTH; i++) begin: rca_block
        fa addk (.a(a[i]), .b(b[i]), .c_in(carry[i]), .sum(sum[i]), .c_out(carry[i+1]));
    end
   endgenerate

endmodule

module fa (
    input logic a,
    input logic b, 
    input logic c_in,
    output logic sum,
    output logic c_out
);

  assign {c_out, sum} = a + b + c_in;

endmodule
