module esn_top(clk, rst_N, est, W_out);

input clk;      // System clock
input rst_N;    // Global sync reset
output [31:0] est;    // predicted output, from readout
output [8*32 -1 : 0] W_out;  // learned weights, from readout


wire [5:0] DATA_ADDR;   // lookup address for input/output train data
wire [8*16-1:0] XSTATE; // extended system state from reservoir

res_top RESERVOIR (
  .clk(clk),
  .rst_N(rst_N),
  .XSTATE(XSTATE),
  .ADDR_OUT(DATA_ADDR)
);

rdout_top READOUT (
  .clk(clk),
  .ce(1'b1),
  .rst_N(rst_N),
  .XSTATE(XSTATE),
  .addr(DATA_ADDR),
  .est(est),
  .W_out(W_out)
);

endmodule
