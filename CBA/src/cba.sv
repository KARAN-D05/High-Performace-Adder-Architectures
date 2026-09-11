`default_nettype none

module cba #(
    parameter WIDTH = 64,
    parameter BLOCK_WIDTH = 32
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
    parameter BLOCK_WIDTH = 32
) (
    input logic [BLOCK_WIDTH-1:0] a, 
    input logic [BLOCK_WIDTH-1:0] b,
    input logic c_in,
    output logic [BLOCK_WIDTH-1:0] sum,
    output logic c_out
);
   
   wire prop_0, prop_1, prop_2, prop_3,
     prop_4, prop_5, prop_6, prop_7,
     prop_8, prop_9, prop_10, prop_11,
     prop_12, prop_13, prop_14, prop_15,
     prop_16, prop_17, prop_18, prop_19,
     prop_20, prop_21, prop_22, prop_23,
     prop_24, prop_25, prop_26, prop_27,
     prop_28, prop_29, prop_30, prop_31,
     prop_cbu;

assign prop_0  = a[0]  ^ b[0];
assign prop_1  = a[1]  ^ b[1];
assign prop_2  = a[2]  ^ b[2];
assign prop_3  = a[3]  ^ b[3];
assign prop_4  = a[4]  ^ b[4];
assign prop_5  = a[5]  ^ b[5];
assign prop_6  = a[6]  ^ b[6];
assign prop_7  = a[7]  ^ b[7];
assign prop_8  = a[8]  ^ b[8];
assign prop_9  = a[9]  ^ b[9];
assign prop_10 = a[10] ^ b[10];
assign prop_11 = a[11] ^ b[11];
assign prop_12 = a[12] ^ b[12];
assign prop_13 = a[13] ^ b[13];
assign prop_14 = a[14] ^ b[14];
assign prop_15 = a[15] ^ b[15];
assign prop_16 = a[16] ^ b[16];
assign prop_17 = a[17] ^ b[17];
assign prop_18 = a[18] ^ b[18];
assign prop_19 = a[19] ^ b[19];
assign prop_20 = a[20] ^ b[20];
assign prop_21 = a[21] ^ b[21];
assign prop_22 = a[22] ^ b[22];
assign prop_23 = a[23] ^ b[23];
assign prop_24 = a[24] ^ b[24];
assign prop_25 = a[25] ^ b[25];
assign prop_26 = a[26] ^ b[26];
assign prop_27 = a[27] ^ b[27];
assign prop_28 = a[28] ^ b[28];
assign prop_29 = a[29] ^ b[29];
assign prop_30 = a[30] ^ b[30];
assign prop_31 = a[31] ^ b[31];

assign prop_cbu = prop_0  & prop_1  & prop_2  & prop_3  &
                  prop_4  & prop_5  & prop_6  & prop_7  &
                  prop_8  & prop_9  & prop_10 & prop_11 &
                  prop_12 & prop_13 & prop_14 & prop_15 &
                  prop_16 & prop_17 & prop_18 & prop_19 &
                  prop_20 & prop_21 & prop_22 & prop_23 &
                  prop_24 & prop_25 & prop_26 & prop_27 &
                  prop_28 & prop_29 & prop_30 & prop_31;

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
