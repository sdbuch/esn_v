`timescale 1ns/1ps

module rdout_pe_tb;

reg clk;

// Data, weight, output registers
reg ['d16*'d8-1:0] D;
reg ['d32*'d8 + 'd16*'d8 - 1:0] W;
wire ['d32*'d2-1:0] Q;

// DUT INSTANTIATION
pe_8x2_hybrid #(32, 16, 8, 2) PE8x2H_DUT(
  .ce(1'b1),
  .clk(clk),
  .DATA(D),
  .WEIGHT(W),
  .Q(Q)
);

// SIMULATION PARAMETERS
initial begin
  $dumpfile("pe_8x2_hybridbit.vcd");
  $dumpvars;
end

// DATA BUSES' INITIAL VALUES
initial begin: INITIALIZE
  /*D[(1*16-1)-:16] = 16'b0; // Zero
  D[(2*16-1)-:16] = 16'b1; // Small pos
  D[(3*16-1)-:16] = 16'h8000; // Big neg
  D[(4*16-1)-:16] = 16'h7FFF; // Big pos
  D[(5*16-1)-:16] = 16'hFFFF; // Small neg
  D[(6*16-1)-:16] = 16'h0CF2; // Mid pos
  D[(7*16-1)-:16] = 16'h9F20; // Mid neg
  D[(8*16-1)-:16] = 16'h85F0;

  W[(1*16-1)-:16] = 16'h0000;
  W[(2*16-1)-:16] = 16'b1;
  W[(3*16-1)-:16] = 16'h8000;
  W[(4*16-1)-:16] = 16'h7FFF;
  W[(5*16-1)-:16] = 16'hFFFF;
  W[(6*16-1)-:16] = 16'h0CF2;
  W[(7*16-1)-:16] = 16'h9F20;
  W[(8*16-1)-:16] = 16'h85F0;*/

  // Small norm test values
  D[(1*16-1)-:16] = 16'b0; // Zero
  D[(2*16-1)-:16] = 16'b1; // Small pos
  D[(3*16-1)-:16] = 16'd10;
  D[(4*16-1)-:16] = 16'hFFFF;
  D[(5*16-1)-:16] = 16'hFFFF; // Small neg
  D[(6*16-1)-:16] = 16'hF00E;
  D[(7*16-1)-:16] = 16'h0092;
  D[(8*16-1)-:16] = 16'h0201;

  W[(1*16-1)-:16] = 16'h0;
  W[(2*16-1)-:16] = 16'b1;
  W[(3*16-1)-:16] = 16'd10;
  W[(4*16-1)-:16] = 16'hFFFF;
  W[(5*16-1)-:16] = 16'hFFFF;
  W[(6*16-1)-:16] = 16'hF00E;
  W[(7*16-1)-:16] = 16'h0092;
  W[(8*16-1)-:16] = 16'h0201;
  W[(1*32+8*16-1)-:32] = 32'h0001;
  W[(2*32+8*16-1)-:32] = 32'h539B;
  W[(3*32+8*16-1)-:32] = 32'h8000;
  W[(4*32+8*16-1)-:32] = 32'h7FFF;
  W[(5*32+8*16-1)-:32] = 32'hFFFF;
  W[(6*32+8*16-1)-:32] = 32'h0001;
  W[(7*32+8*16-1)-:32] = 32'h2B9C;
  W[(8*32+8*16-1)-:32] = 32'hA804;
  clk = 1'b0;
end

// CLOCK GEN
always begin
  #1 clk = !clk;
end

endmodule
