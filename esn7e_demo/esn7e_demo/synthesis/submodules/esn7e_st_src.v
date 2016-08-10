module esn7e_st_src(clk, reset, data_valid, data_out);

input clk;
input reset;
output data_valid;
output [31:0] data_out;

wire [31:0] yhatbus;
wire [15:0] inputbus;
wire [8*32 -1 : 0] DANGLINGBUS_WOUT;

// Instantiate ESN
esn_top ESN0 (
  .clk(clk),
  .ce(1'b1),
  .rst_N(reset),
  .est(yhatbus),
  .W_out(DANGLINGBUS_WOUT),
  .RDOUT_DATA_VALID(data_valid),
  .U(inputbus)
);

// Pack predicted output and corresponding esn input into a 48 bit word
// Recall that input is Q3.12 and yhat is Q10.21
assign data_out = {inputbus, yhatbus};

endmodule
