`timescale 1ns/1ps

module pe_8x4x16_tb;

reg clk;

// Runtime params
// Change depending on what the PE design is
/*wire ndata;
assign ndata = 'd16;
integer nweight = 'd64;
integer nout = 'd4;
integer nweightout = (nweight >> 1);*/

// Data, weight, output registers
reg ['d16*'d8-1:0] D;
reg ['d16*'d8*'d4-1:0] W;
wire ['d16*'d4-1:0] Q;

integer val = 16'h7B2A;
integer weight = 16'h8F04;

// DUT INSTANTIATION
pe_8x4_16bit #(16, 8, 4) DUT (
  .ce(1'b1),
  .clk(clk),
  .DATA(D),
  .WEIGHT(W),
  .Q(Q)
);

// SIMULATION PARAMETERS
initial begin
  $dumpfile("pe_8x4_16bit.vcd");
  $dumpvars;
end

// DATA BUSES' INITIAL VALUES
initial begin: INITIALIZE
  // Initialize registers
  integer i;
  for (i = 1 ; i <= 'd8; i=i+1) begin
    D[(i*16-1)-:16] = val;
  end
  for (i = 1 ; i <= 'd32; i=i+1) begin
    W[(i*16-1)-:16] = weight;
  end
  clk = 1'b0;
end

// CLOCK GEN
always begin
  #1 clk = !clk;
end

endmodule
