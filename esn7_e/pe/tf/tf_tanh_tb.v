`timescale 1ns/1ps

module tf_tanh_tb #(parameter wordlen=38, nin=4) ;

reg clk;

// Runtime params
// Change depending on what the PE design is
/*wire ndata;
assign ndata = 'd16;
integer nweight = 'd64;
integer nout = 'd4;
integer nweightout = (nweight >> 1);*/

// Data, weight, output registers
reg [(wordlen*nin-1):0] D;
wire ['d16*nin-1:0] Q;

// DUT INSTANTIATION
tf_tanh #(wordlen, nin) DUT(
  .clk(clk),
  .IBUS(D),
  .OBUS(Q)
);

// SIMULATION PARAMETERS
initial begin
  $dumpfile("tf_tanh.vcd");
  $dumpvars;
end

// DATA BUSES' INITIAL VALUES
initial begin: INITIALIZE
  // Initialize registers
  integer i;
  for (i = 1 ; i <= nin; i=i+1) begin
    D[(i*wordlen-1)-:wordlen] = {(wordlen){1'b0}};
  end
  clk = 1'b0;
end

// CLOCK GEN
always begin
  #1 clk = !clk;
end

always @(posedge clk) begin: DATA
  integer i;
  for (i = 1 ; i <= nin; i=i+1) begin
    D[(i*wordlen-1)-:wordlen] = D[(i*wordlen-1)-:wordlen]+('d1 << 22);
  end
end

endmodule
