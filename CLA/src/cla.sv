`default_nettype none

module cla #(
    parameter WIDTH = 64,
    parameter BLOCK_WIDTH = 32
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out
);

    logic [(WIDTH/BLOCK_WIDTH):0] carry;

    assign carry[0] = c_in;
    assign c_out = carry[WIDTH/BLOCK_WIDTH];

    genvar i;

    generate
        for (i = 0; i < (WIDTH/BLOCK_WIDTH); i++) begin : clu_block

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
    parameter BLOCK_WIDTH = 32
) (
    input  logic [BLOCK_WIDTH-1:0] a,
    input  logic [BLOCK_WIDTH-1:0] b,
    input  logic c_in,
    output logic [BLOCK_WIDTH-1:0] sum,
    output logic c_out
);

    logic [BLOCK_WIDTH-1:0] p;
    logic [BLOCK_WIDTH-1:0] g;
    logic [BLOCK_WIDTH:0] carry;

    logic [BLOCK_WIDTH-1:0] carry_terms [0:BLOCK_WIDTH-1];

    assign carry[0] = c_in;

    genvar i, j;

    generate
        for (i = 0; i < BLOCK_WIDTH; i = i + 1) begin : pg_gen
            assign p[i] = a[i] ^ b[i];
            assign g[i] = a[i] & b[i];

            for (j = 0; j < BLOCK_WIDTH; j = j + 1) begin : term_gen
                if (j < i) begin : valid_term
                    assign carry_terms[i][j] = (&p[i:j+1]) & g[j];
                end
                else begin : invalid_term
                    assign carry_terms[i][j] = 1'b0;
                end
            end

            assign carry[i+1] = g[i] | (|carry_terms[i]) | ((&p[i:0]) & c_in);
            assign sum[i] = p[i] ^ carry[i];
        end

    endgenerate

    assign c_out = carry[BLOCK_WIDTH];

endmodule
