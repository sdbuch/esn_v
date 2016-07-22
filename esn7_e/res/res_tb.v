`timescale 1ns/1ps

module res_tb ;

reg clk;
reg rst_N;
wire [16*8-1:0] xstate;

res_top DUT(
  .clk(clk),
  .rst_N(rst_N),
  .xstate(xstate)
);

// SIMULATION PARAMETERS
initial begin
  $dumpfile("res_tb.vcd");
  $dumpvars;
end

// Var inits
initial begin
  clk = 1'b0;
  rst_N = 1'b0;
  #8 rst_N = 1'b1;
end

// CLOCK GEN
always begin
  #1 clk = !clk;
end

always begin
  #2000 $finish;
end

endmodule
