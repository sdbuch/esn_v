`timescale 1ns/100ps
module esn_top_tb;

reg clk;
reg ce; // Chip enable for readout only
reg rst_N;
wire [31:0] est;
wire [8*32-1 : 0] W_out;

esn_top ESN7e (
  .clk(clk),
  .ce(ce),
  .rst_N(rst_N),
  .est(est),
  .W_out(W_out)
);

initial begin
  $dumpfile("esn_top_tb.vcd");
  $dumpvars(1);
end

// Var inits
initial begin: INITS
  clk = 1'b0;
  ce = 1'b1;
  rst_N = 1'b1;     // initialize the system
  #4 rst_N = 1'b0;
  #22 rst_N = 1'b1;
end

// clock gen
always begin: CLOCK
  #1 clk = !clk;
end

// conclude
//always begin: ENDSIM
//  #10000 $finish;
//end



endmodule
