`default_nettype none

module cla #(
    parameter WIDTH = 64,
    parameter BLOCK_WIDTH = 4
) (
    input logic [WIDTH-1:0] a, 
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

  logic [(WIDTH/BLOCK_WIDTH):0] carry;

  assign carry[0] = c_in;
  assign c_out = carry[(WIDTH/BLOCK_WIDTH)];

  genvar i;

  generate 
    for (i = 0; i < (WIDTH/BLOCK_WIDTH); i++) begin: clu_block
        clu #(
            .BLOCK_WIDTH(BLOCK_WIDTH)
            ) cl (
            .a(a[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]), 
            .b(b[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]),
            .c_in(carry[i]),
            .sum(sum[BLOCK_WIDTH*i+(BLOCK_WIDTH-1):BLOCK_WIDTH*i]),
            .c_out(carry[i+1])
            );
    end
  endgenerate

endmodule

module clu #(
    parameter BLOCK_WIDTH = 4
) (
    input logic [BLOCK_WIDTH-1:0] a,
    input logic [BLOCK_WIDTH-1:0] b,
    input logic c_in,
    output logic [BLOCK_WIDTH-1:0] sum,
    output logic c_out
);

  logic p0, p1, p2, p3, g0, g1, g2, g3;

  assign p0 = a[0] ^ b[0];
  assign g0 = a[0] & b[0];
  assign p1 = a[1] ^ b[1];
  assign g1 = a[1] & b[1];
  assign p2 = a[2] ^ b[2];
  assign g2 = a[2] & b[2];
  assign p3 = a[3] ^ b[3];
  assign g3 = a[3] & b[3];

  logic c_out_0, c_out_1, c_out_2, c_out_3;

  assign c_out_0 = (g0 | (p0 & c_in));
  assign c_out_1 = (g1 | (p1 & g0) | (p0 & p1 &c_in));
  assign c_out_2 = (g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & c_in));
  assign c_out_3 = (g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & c_in));

  assign sum[0] = p0 ^ c_in;
  assign sum[1] = p1 ^ c_out_0;
  assign sum[2] = p2 ^ c_out_1;
  assign sum[3] = p3 ^ c_out_2;
  assign c_out = c_out_3;

endmodule
