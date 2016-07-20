`timescale 1ns/1ps

module pe_generic_tb #(parameter ndata=16, nweight=64, nout=4) ;

reg ce, clk;
reg [1:0] mode;

// Runtime params
// Change depending on what the PE design is
/*wire ndata;
assign ndata = 'd16;
integer nweight = 'd64;
integer nout = 'd4;
integer nweightout = (nweight >> 1);*/

// Data, weight, output registers
reg [('d16*ndata-1):0] D;
reg [('d16*nweight-1):0] W;
wire [('d16*(nweight>>1)-1):0] Q;

// Runtime params
// Change based on what inputs the PE should get
integer val = 16'h0B2A;
integer weight = 16'h2F04;

// DUT INSTANTIATION
pe_generic #(16,ndata,nout) DUT(
  .ce(ce),
  .clk(clk),
  .mode(mode),
  .D(D),
  .W(W),
  .Q(Q)
);

// SIMULATION PARAMETERS
initial begin
  $dumpfile("pe_generic.vcd");
  $dumpvars;
end

// DATA BUSES' INITIAL VALUES
initial begin: INITIALIZE
  // Initialize registers
  integer i;
  for (i = 1 ; i <= ndata; i=i+1) begin
    D[(i*16-1)-:16] = val;
  end
  for (i = 1 ; i <= nweight; i=i+1) begin
    W[(i*16-1)-:16] = weight;
  end
  mode = 2'b01; // Start in block MVM mode
  ce = 1'b0;    // Start in output lockup mode
  clk = 1'b0;
end

// CLOCK GEN
always begin
  #5 clk = !clk;
end

// STIMULUS
always begin
  fork
    #50 ce = 1'b1;     // Enter block MVM mode
    #500 mode = 2'b00; // Switch to weight update mode
  join
end

always begin
  #2000 $finish;
end


endmodule
