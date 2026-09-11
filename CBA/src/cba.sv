`default_nettype none

module cba #(
    parameter WIDTH = 64,
    parameter BLOCK_WIDTH = 4
) (
    input logic [WIDTH-1:0] a, 
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

   wire [(WIDTH/BLOCK_WIDTH):0] carry;
   assign carry[0] = c_in;
   assign c_out = carry[WIDTH/BLOCK_WIDTH];

   genvar i; 

   generate 
    for (i = 0; i < (WIDTH/BLOCK_WIDTH); i++) begin: cbu_block
        cbu #(
            .BLOCK_WIDTH(BLOCK_WIDTH)
            ) addk (
            .a(a[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]),
            .b(b[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]),
            .c_in(carry[i]),
            .sum(sum[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]), 
            .c_out(carry[i+1])
            );
    end
   endgenerate

endmodule

module cbu #(
    parameter BLOCK_WIDTH = 4
) (
    input logic [BLOCK_WIDTH-1:0] a, 
    input logic [BLOCK_WIDTH-1:0] b,
    input logic c_in,
    output logic [BLOCK_WIDTH-1:0] sum,
    output logic c_out
);
   
   wire prop_0, prop_1, prop_2, prop_3, prop_cbu;
   assign prop_0 = a[0] ^ b[0];
   assign prop_1 = a[1] ^ b[1];
   assign prop_2 = a[2] ^ b[2];
   assign prop_3 = a[3] ^ b[3];
   assign prop_cbu = (prop_0 & prop_1 & prop_2 & prop_3);

   wire [BLOCK_WIDTH:0] carry;
   assign carry[0] = c_in;
   assign c_out = prop_cbu ? c_in : carry[BLOCK_WIDTH];

   genvar i; 

   generate 
    for (i = 0; i < BLOCK_WIDTH; i++) begin: rca_block
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
