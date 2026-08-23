`default_nettype none

module csa #(
    parameter WIDTH = 64
) (
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

   localparam HALF_WIDTH = WIDTH/2;

   wire [HALF_WIDTH-1:0] sum_low, sum_high_c1, sum_high_c0, sum_high;
   wire c_out_low, c_out_high_c1, c_out_high_c0;

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca1 (
    .a(a[HALF_WIDTH-1:0]),
    .b(b[HALF_WIDTH-1:0]),
    .c_in(c_in),
    .sum(sum_low),
    .c_out(c_out_low)
   ); 
   
   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca2 (
    .a(a[WIDTH-1:HALF_WIDTH]),
    .b(b[WIDTH-1:HALF_WIDTH]),
    .c_in(1'b1),
    .sum(sum_high_c1),
    .c_out(c_out_high_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca3 (
    .a(a[WIDTH-1:HALF_WIDTH]),
    .b(b[WIDTH-1:HALF_WIDTH]),
    .c_in(1'b0),
    .sum(sum_high_c0),
    .c_out(c_out_high_c0)
   ); 

   assign sum_high = c_out_low ? sum_high_c1 : sum_high_c0;
   assign sum = {sum_high, sum_low};
   assign c_out = c_out_low ? c_out_high_c1 : c_out_high_c0;

endmodule

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
