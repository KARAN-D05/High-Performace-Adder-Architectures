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

   localparam HALF_WIDTH = WIDTH/8;

   wire [HALF_WIDTH-1:0] sum_0, sum_1_c1, sum_1_c0, sum_2_c1, sum_2_c0, sum_3_c0, sum_3_c1, sum_4_c0, sum_4_c1, sum_5_c0, sum_5_c1, sum_6_c0, sum_6_c1, sum_7_c0, sum_7_c1, sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7;

   wire c_out_0, c_out_1_c1, c_out_1_c0, c_out_2_c1, c_out_2_c0, c_out_3_c1, c_out_3_c0, c_out_4_c1, c_out_4_c0, c_out_5_c1, c_out_5_c0, c_out_6_c1, c_out_6_c0, c_out_7_c1, c_out_7_c0, c_out_1, c_out_2, c_out_3, c_out_4, c_out_5, c_out_6, c_out_7;

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca1 (
    .a(a[HALF_WIDTH-1:0]),
    .b(b[HALF_WIDTH-1:0]),
    .c_in(c_in),
    .sum(sum_0),
    .c_out(c_out_0)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca2 (
    .a(a[(WIDTH/4)-1:HALF_WIDTH]),
    .b(b[(WIDTH/4)-1:HALF_WIDTH]),
    .c_in(1'b1),
    .sum(sum_1_c1),
    .c_out(c_out_1_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca3 (
    .a(a[(WIDTH/4)-1:HALF_WIDTH]),
    .b(b[(WIDTH/4)-1:HALF_WIDTH]),
    .c_in(1'b0),
    .sum(sum_1_c0),
    .c_out(c_out_1_c0)
   );

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca4 (
    .a(a[(WIDTH/4 + HALF_WIDTH)-1:(WIDTH/4)]),
    .b(b[(WIDTH/4 + HALF_WIDTH)-1:(WIDTH/4)]),
    .c_in(1'b1),
    .sum(sum_2_c1),
    .c_out(c_out_2_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca5 (
    .a(a[(WIDTH/4 + HALF_WIDTH)-1:(WIDTH/4)]),
    .b(b[(WIDTH/4 + HALF_WIDTH)-1:(WIDTH/4)]),
    .c_in(1'b0),
    .sum(sum_2_c0),
    .c_out(c_out_2_c0)
   ); 

      rca # (
    .WIDTH(HALF_WIDTH)
   ) rca6 (
    .a(a[(WIDTH/2)-1:(WIDTH/4 + HALF_WIDTH)]),
    .b(b[(WIDTH/2)-1:(WIDTH/4 + HALF_WIDTH)]),
    .c_in(1'b1),
    .sum(sum_3_c1),
    .c_out(c_out_3_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca7 (
    .a(a[(WIDTH/2)-1:(WIDTH/4 + HALF_WIDTH)]),
    .b(b[(WIDTH/2)-1:(WIDTH/4 + HALF_WIDTH)]),
    .c_in(1'b0),
    .sum(sum_3_c0),
    .c_out(c_out_3_c0)
   );

      rca # (
    .WIDTH(HALF_WIDTH)
   ) rca8 (
    .a(a[(WIDTH/2 + HALF_WIDTH)-1:(WIDTH/2)]),
    .b(b[(WIDTH/2 + HALF_WIDTH)-1:(WIDTH/2)]),
    .c_in(1'b1),
    .sum(sum_4_c1),
    .c_out(c_out_4_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca9 (
    .a(a[(WIDTH/2 + HALF_WIDTH)-1:(WIDTH/2)]),
    .b(b[(WIDTH/2 + HALF_WIDTH)-1:(WIDTH/2)]),
    .c_in(1'b0),
    .sum(sum_4_c0),
    .c_out(c_out_4_c0)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca10 (
    .a(a[(WIDTH/2 + 2*HALF_WIDTH)-1:(WIDTH/2 + HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 2*HALF_WIDTH)-1:(WIDTH/2 + HALF_WIDTH)]),
    .c_in(1'b1),
    .sum(sum_5_c1),
    .c_out(c_out_5_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca11 (
    .a(a[(WIDTH/2 + 2*HALF_WIDTH)-1:(WIDTH/2 + HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 2*HALF_WIDTH)-1:(WIDTH/2 + HALF_WIDTH)]),
    .c_in(1'b0),
    .sum(sum_5_c0),
    .c_out(c_out_5_c0)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca12 (
    .a(a[(WIDTH/2 + 3*HALF_WIDTH)-1:(WIDTH/2 + 2*HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 3*HALF_WIDTH)-1:(WIDTH/2 + 2*HALF_WIDTH)]),
    .c_in(1'b1),
    .sum(sum_6_c1),
    .c_out(c_out_6_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca13 (
    .a(a[(WIDTH/2 + 3*HALF_WIDTH)-1:(WIDTH/2 + 2*HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 3*HALF_WIDTH)-1:(WIDTH/2 + 2*HALF_WIDTH)]),
    .c_in(1'b0),
    .sum(sum_6_c0),
    .c_out(c_out_6_c0)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca14 (
    .a(a[(WIDTH/2 + 4*HALF_WIDTH)-1:(WIDTH/2 + 3*HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 4*HALF_WIDTH)-1:(WIDTH/2 + 3*HALF_WIDTH)]),
    .c_in(1'b1),
    .sum(sum_7_c1),
    .c_out(c_out_7_c1)
   ); 

   rca # (
    .WIDTH(HALF_WIDTH)
   ) rca15 (
    .a(a[(WIDTH/2 + 4*HALF_WIDTH)-1:(WIDTH/2 + 3*HALF_WIDTH)]),
    .b(b[(WIDTH/2 + 4*HALF_WIDTH)-1:(WIDTH/2 + 3*HALF_WIDTH)]),
    .c_in(1'b0),
    .sum(sum_7_c0),
    .c_out(c_out_7_c0)
   );

   assign sum_1 = c_out_0 ? sum_1_c1 : sum_1_c0;
   assign c_out_1 = c_out_0 ? c_out_1_c1 : c_out_1_c0;
   assign sum_2 = c_out_1 ? sum_2_c1 : sum_2_c0;
   assign c_out_2 = c_out_1 ? c_out_2_c1 : c_out_2_c0;
   assign sum_3 = c_out_2 ? sum_3_c1 : sum_3_c0;
   assign c_out_3 = c_out_2 ? c_out_3_c1 : c_out_3_c0;
   assign sum_4 = c_out_3 ? sum_4_c1 : sum_4_c0;
   assign c_out_4 = c_out_3 ? c_out_4_c1 : c_out_4_c0;
   assign sum_5 = c_out_4 ? sum_5_c1 : sum_5_c0;
   assign c_out_5 = c_out_4 ? c_out_5_c1 : c_out_5_c0;
   assign sum_6 = c_out_5 ? sum_6_c1 : sum_6_c0;
   assign c_out_6 = c_out_5 ? c_out_6_c1 : c_out_6_c0;
   assign sum_7 = c_out_6 ? sum_7_c1 : sum_7_c0;
   assign c_out_7 = c_out_6 ? c_out_7_c1 : c_out_7_c0;
   assign c_out = c_out_7;

   assign sum = {sum_7, sum_6, sum_5, sum_4, sum_3, sum_2, sum_1, sum_0};

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
