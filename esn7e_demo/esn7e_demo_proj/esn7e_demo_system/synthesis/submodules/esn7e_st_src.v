module esn7e_st_src(clk, reset_n, data_valid, data_out);

input clk;
input reset_n;
output data_valid;
output [31:0] data_out;

wire [31:0] yhatbus;
wire [15:0] inputbus;
wire [8*32 -1 : 0] DANGLINGBUS_WOUT;

// Instantiate ESN
esn_top ESN0 (
  .clk(clk),
  .ce(1'b1),
  .rst_N(reset_n),
  .est(yhatbus),
  .W_out(DANGLINGBUS_WOUT),
  .RDOUT_DATA_VALID(data_valid),
  .U(inputbus)
);

// Pack predicted output and corresponding esn input into a 32 bit word
// Recall that input is Q3.12 and yhat is Q10.21
wire [15:0] yhatbus_16b;
assign yhatbus_16b = ( (&yhatbus[31-:6] || ~|yhatbus[31-:6]) ? ({yhatbus[31],
yhatbus[31-6 -: 16]}) : ({1'b0, {(15){1'b1}}} ^ {(16){yhatbus[32-1]}}));

// Now pack the data into 14 bit vectors so it can be sent to host as ASCII
//assign data_out = {1'b0, inputbus[15:9], 1'b0, inputbus[8:2], 1'b0,
//yhatbus_16b[15:9], 1'b0, yhatbus_16b[8:2]};
// no ascii encoding mode:
assign data_out = {inputbus, yhatbus_16b};

endmodule
