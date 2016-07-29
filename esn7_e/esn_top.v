module esn_top(clk, ce, rst_N, est, W_out);

input clk;      // System clock
input rst_N;    // Global sync reset
input ce;       // Readout output enable (it still trains even when ce is low...)
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

wire rstdly_N;
rdout_rst_sreg SREGD (
  .clock(clk),
  .shiftin(rst_N),
  .shiftout(rstdly_N)
);

rdout_top READOUT (
  .clk(clk),
  .ce(ce),
  .rst_N(rstdly_N),
  .XSTATE(XSTATE),
  .addr(DATA_ADDR),
  .est(est),
  .W_out(W_out)
);

endmodule
