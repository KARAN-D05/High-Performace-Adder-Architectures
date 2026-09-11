// 64-Bit Carry-Bypass Adder
`default_nettype none

module cba #(
    parameter WIDTH = 64
) (
    input logic [WIDTH-1:0] a, 
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

   wire [(WIDTH/4):0] carry;
   assign carry[0] = c_in;
   assign c_out = carry[WIDTH/4];

   genvar i; 

   generate 
    for (i = 0; i < (WIDTH/4); i++) begin: cbu_block
        cbu addk (.a(a[4*i+3:4*i]), .b(b[4*i+3:4*i]), .c_in(carry[i]), .sum(sum[4*i+3:4*i]), .c_out(carry[i+1]));
    end
   endgenerate

endmodule

module cbu #(
    parameter WIDTH = 4
) (
    input logic [WIDTH-1:0] a, 
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);
   
   wire prop_0, prop_1, prop_2, prop_3, prop_cbu;
   assign prop_0 = a[0] ^ b[0];
   assign prop_1 = a[1] ^ b[1];
   assign prop_2 = a[2] ^ b[2];
   assign prop_3 = a[3] ^ b[3];
   assign prop_cbu = (prop_0 & prop_1 & prop_2 & prop_3);

   wire [WIDTH:0] carry;
   assign carry[0] = c_in;
   assign c_out = prop_cbu ? c_in : carry[WIDTH];

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
