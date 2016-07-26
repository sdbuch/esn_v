module res_top(clk, rst_N, XSTATE, ADDR_OUT);

input clk;
input rst_N;

output [8*16 -1 : 0] XSTATE;
output [5:0] ADDR_OUT;

wire [1:0] slowcount;
slow_Ctr DIVCNT(
  .clock(clk),
  .sclr(!rst_N),
  .q(slowcount)
);
wire [5:0] addr;
addr_ctr ACTR (
  .clock(clk),
  .clk_en(&slowcount),
  .sclr(!rst_N),
  .q(addr)
);

// declare memories
// Sinusoid input data
wire [15:0] U;
input_ROM DMEM (
  .address(addr),
  .clock(clk),
  .q(U)
);

// Weight input data
/*
wire [7*16-1:0] W0BUS;
W0_reg W0REG (
  .result(W0BUS)
);
wire [7*16-1:0] W1BUS;
W1_reg W1REG (
  .result(W1BUS)
);
wire [7*16-1:0] W2BUS;
W2_reg W2REG (
  .result(W2BUS)
);
wire [7*16-1:0] W3BUS;
W3_reg W3REG (
  .result(W3BUS)
);
wire [7*16-1:0] W4BUS;
W4_reg W4REG (
  .result(W4BUS)
);
wire [7*16-1:0] W5BUS;
W5_reg W5REG (
  .result(W5BUS)
);
wire [7*16-1:0] W6BUS;
W6_reg W6REG (
  .result(W6BUS)
);
wire [7*16-1:0] WINBUS;
WIN_reg WINREG (
  .result(WINBUS)
);
*/
reg [7*16-1:0] W0BUS = 112'hF391E3D6E99A1619095918DA004E;
reg [7*16-1:0] W1BUS = 112'hDA62DC9AFA6FE187F1A411E117DC;
reg [7*16-1:0] W2BUS = 112'h050EE5830F02D8C725FEFF56F611;
reg [7*16-1:0] W3BUS = 112'hEBEFDF94043CF1C5235E2983FBDA;
reg [7*16-1:0] W4BUS = 112'hDF57F05C09AE1C281F22FDE2DF69;
reg [7*16-1:0] W5BUS = 112'h11B927FE203CF521EA692BEE16F2;
reg [7*16-1:0] W6BUS = 112'hFEC002DAF56929F4ECF6FF2A05CA;
reg [7*16-1:0] WINBUS = 112'h260D4C4EB86F5B9F679CCAC239D3; 

// Route data and inputs
// A set of 16*8 contiguous bits from the start of the weight bus consists of
// the weights used to process one output neuron. Within each of these four
// sets, the 16 most significant bits contain the weights that go to the
// multiplier that has its output padded with zeros. This means that on the
// length 8*16 input bus, the 16 most significant bits need to belong to the
// data word corresponding to the input--so the 16 weight bus MSBs within each
// block of 8*16 bits need to be the W_in weights
wire [16*8*4-1:0] WBUS_PE0;
assign WBUS_PE0[8*16*4-1 -: 8*16] = {WINBUS[16*4-1 -: 16], W3BUS};
assign WBUS_PE0[8*16*3-1 -: 8*16] = {WINBUS[16*3-1 -: 16], W2BUS};
assign WBUS_PE0[8*16*2-1 -: 8*16] = {WINBUS[16*2-1 -: 16], W1BUS};
assign WBUS_PE0[8*16*1-1 -: 8*16] = {WINBUS[16*1-1 -: 16], W0BUS};
wire [16*8*4-1:0] WBUS_PE1;
assign WBUS_PE1[8*16*4-1 -: 8*16] = 128'b0;
assign WBUS_PE1[8*16*3-1 -: 8*16] = {WINBUS[16*7-1 -: 16], W6BUS};
assign WBUS_PE1[8*16*2-1 -: 8*16] = {WINBUS[16*6-1 -: 16], W5BUS};
assign WBUS_PE1[8*16*1-1 -: 8*16] = {WINBUS[16*5-1 -: 16], W4BUS};

// Feedback output data bus
wire [8*16-1:0] state;
wire [16*7-1:0] STATEBUS_FB;
wire [16*7-1:0] STATEBUS_DELAY;
assign STATEBUS_FB = STATEBUS_DELAY;
// Processors
pe_8x4_16bit #(16,8,4) PE0 (
  .ce(1'b1),
  .clk(clk),
  .DATA({U, STATEBUS_FB}),
  .WEIGHT(WBUS_PE0),
  .Q(state[16*4-1 -: 16*4])
);

pe_8x4_16bit #(16,8,4) PE1 (
  .ce(1'b1),
  .clk(clk),
  .DATA({U, STATEBUS_FB}),
  .WEIGHT(WBUS_PE1),
  .Q(state[16*8-1 -: 16*4])
);

// Feedback delay elements
genvar n,k;
generate
for (n = 1; n <= 7; n=n+1) begin: STATE_FB_DELAYS
  for(k = 1; k <= 16; k=k+1) begin: BUS_FB_DELAYS
    dff FBREG (
      .d(state[n*16-k]),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(STATEBUS_DELAY[n*16-k])
    );
  end
end
endgenerate

// Network output generation
// Input feedforward to XSTATE
// Pass through four flipflops so the network output changes in phase with the
// state updates
generate
for(k = 1; k <= 16; k=k+1) begin: INPUT_FF_DELAYS
  wire U_FF_TMP1;
  wire U_FF_TMP2;
  wire U_FF_TMP3;
  dff U_FFREG1 (
    .d(U[16-k]),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(U_FF_TMP1)
  );

  dff U_FFREG2 (
    .d(U_FF_TMP1),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(U_FF_TMP2)
  );

  dff U_FFREG3 (
    .d(U_FF_TMP2),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(U_FF_TMP3)
  );

  dff U_FFREG4 (
    .d(U_FF_TMP3),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(XSTATE[8*16-k])
  );
end

// Forward the address outputs with 6 cycles of delay (2 for U addr latency, 4
// for the processing pipeline latency)
for(k = 1; k <= 6; k=k+1) begin: ADDR_DELAYS
  wire ADDR_FF_TMP1;
  wire ADDR_FF_TMP2;
  wire ADDR_FF_TMP3;
  wire ADDR_FF_TMP4;
  wire ADDR_FF_TMP5;

  dff ADDR_FFREG1 (
    .d(addr[6-k]),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_FF_TMP1)
  );

  dff ADDR_FFREG2 (
    .d(ADDR_FF_TMP1),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_FF_TMP2)
  );

  dff ADDR_FFREG3 (
    .d(ADDR_FF_TMP2),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_FF_TMP3)
  );

  dff ADDR_FFREG4 (
    .d(ADDR_FF_TMP3),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_FF_TMP4)
  );

  dff ADDR_FFREG5 (
    .d(ADDR_FF_TMP4),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_FF_TMP5)
  );
  dff ADDR_FFREG6 (
    .d(ADDR_FF_TMP5),
    .clk(clk),
    .clrn(rst_N),
    .prn(1'b1),
    .q(ADDR_OUT[6-k])
  );
end

// Forward state outputs after a delay of 1 cycle
for (n = 1; n <= 7; n=n+1) begin: STATE_OUT_DELAYS
  for(k = 1; k <= 16; k=k+1) begin: INPUT_FF_DELAYS
    dff STATE_OREG (
      .d(state[n*16-k]),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(XSTATE[n*16-k])
    );
  end
end

endgenerate


endmodule
