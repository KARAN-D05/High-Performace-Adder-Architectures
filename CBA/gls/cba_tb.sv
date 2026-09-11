`timescale 1ns/1ns

module testbench;

   logic [63:0] a;
   logic [63:0] b;
   logic c_in;
   logic [63:0] sum;
   logic c_out;

   cba #(
    ) dut (
    .a(a),
    .b(b),
    .c_in(c_in),
    .sum(sum),
    .c_out(c_out)
   );

   initial begin

   $monitor("time = %0t | a = %h | b = %h | c_in = %h | sum = %h | c_out = %h ", $time, a, b, c_in, sum, c_out);

   $dumpfile("Sim.vcd");
   $dumpvars(0, testbench);

   a = 64'b0;
   b = 64'b0;
   c_in = 1'b1;
   #5;

   a = 64'hF0F0_F0F0_F0F0_F0F0;
   b = 64'h0F0F_0F0F_0F0F_0F0F;
   c_in = 1'b0;
   #5;

   a = 64'hFFFF_FFFF_FFFF_FFFF;
   b = 64'h0000_0000_0000_0001;
   c_in = 1'b0;
   #5;

   a = 64'h0000_0000_0000_00B8;
   b = 64'h0000_0000_0000_0017;
   c_in = 1'b1;
   #5;

   a = 64'hFFFF_FFFF_FFFF_FFFF;
   b = 64'hFFFF_FFFF_FFFF_FFFF;
   c_in = 1'b1;
   #5;

   $display("Simulation Complete!");
   $finish;

   end
endmodule
