module rdout_top(clk, ce, rst_N, XSTATE, addr, est, W_out, data_valid);

input clk;
input rst_N;
input ce;                // include a ce signal to turn off when done train
input [8*16-1:0] XSTATE; // The input feedforward should be on the MSBs
input [5:0] addr;        // Forwarded input address counter value

output reg [31:0] est;   // predicted output at current time
output reg [32*8 - 1 : 0] W_out; // learned output weights at current time
output data_valid;

// Strategy:
//  xstate is available from res after 4 cycles, so we need to complete readout
//   processing within 4 cycles too (actually, with some pipeline design we
//   could avert this constraint. This would be important if we are doing long
//   computations like those of minibatch gradient descent in the readout)
//  Delete the output register on pe_8x2_hybrid for 2 cycles delay input->output
//  Delay xstate input to last processing block by 2 cycles to match delay
//  Register the last proc block's Wout feedback so that it feeds back to the
//   first proc block after exactly 4 cycles. Add a two cycle delay path from
//   here (or from output...) to the inputs of the second proc block to match
//   first block proc delay

// Input processor
wire [32*8 - 1 : 0] WOUT_FBBUS; // Connect the other end at end of module
wire [32*2 -1 : 0] OBUS_PE8X2;
pe_8x2_hybrid #(32, 16, 8, 2) PE8X2 (
  .ce(1'b1),
  .clk(clk),
  .DATA(XSTATE),
  .WEIGHT({WOUT_FBBUS, XSTATE}),
  .Q(OBUS_PE8X2)
);

// Scaled error generator
// the addr input needs to be exactly in phase with the xstate input
wire [32-1 : 0] YTRUEBUS;
true_output_ROM YROM (
  .address(addr),
  .clock(clk),
  .q(YTRUEBUS)
);

// Sign extend and add
// Saturate the output just in case...
wire [36-1 : 0] ERRBUS;
add36x36signed_sub ERRSUB (
  .dataa({{(4){YTRUEBUS[31]}}, YTRUEBUS}),
  .datab({{(4){OBUS_PE8X2[32*2-1]}}, OBUS_PE8X2[32*2 -1 -: 32]}),
  .result(ERRBUS)
);
wire [32-1 : 0] ERRBUS_SAT;
assign ERRBUS_SAT = (
  &ERRBUS[36-1 -: 5] || ~|ERRBUS[36-1 -: 5] ?
  {ERRBUS[36-1], ERRBUS[36-5-1 : 0]} :
  ({1'b0, {(31){1'b1}}} ^ {(32){ERRBUS[36-1]}})
);

// Scale the error by the step size
wire [48-1:0] ERRSCALED; // Raw product is Q18.45, but we can truncate to Q18.26
wire [32-1 : 0] ERRSCALED_SAT; // Saturate to Q10.21
mul32x32to48 ERRMUL (
  //.dataa(OBUS_PE8X2[32*2-32-1 -: 32]),
  .dataa(32'h00004000),
  .datab(ERRBUS_SAT),
  .result(ERRSCALED)
);
assign ERRSCALED_SAT  = (
  &ERRSCALED[48-1 -: 13] || ~|ERRSCALED[48-1 -: 13] ?
  {ERRSCALED[48-1], ERRSCALED[48-13-1 -: 31]} :
  ({1'b0, {(31){1'b1}}} ^ {(32){ERRSCALED[48-1]}})
);

// W_out "feedforward" bus
// Gets driven by the fed-back Wouts, which is driven at the end of the module
wire [8*32 -1 : 0] WOUT_FFBUS;
genvar n,k;
generate

for (n = 1; n <= 8; n=n+1) begin: WOUT_FF_VALDELAYS
  for(k = 1; k <= 32; k=k+1) begin: WOUT_FF_BITDELAYS
    wire WOUT_FF_TMP;
    dff WOUT_FFREG1 (
      .d(WOUT_FBBUS[n*32-k]),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(WOUT_FF_TMP)
    );
    dff WOUT_FFREG2 (
      .d(WOUT_FF_TMP),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(WOUT_FFBUS[n*32-k])
    );
  end
end
endgenerate

// XSTATE feedforward bus
// Gets driven by the network input, delayed 2 cycles to match latency of first
// processor
wire [8*16 -1 : 0] XSTATE_FFBUS;
generate
for (n = 1; n <= 8; n=n+1) begin: XSTATE_FF_VALDELAYS
  for(k = 1; k <= 16; k=k+1) begin: XSTATE_FF_BITDELAYS
    wire XSTATE_FF_TMP;
    dff XSTATE_FFREG1 (
      .d(XSTATE[n*16-k]),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(XSTATE_FF_TMP)
    );
    dff XSTATE_FFREG2 (
      .d(XSTATE_FF_TMP),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(XSTATE_FFBUS[n*16-k])
    );
  end
end
endgenerate

// Second processor, weight updater
// The XSTATE_FFBUS and WOUT_FFBUS and ERRSCALED_SAT inputs need to be
// interleaved appropriately to enable correct processing
wire [32*8 -1 : 0] WEIGHT_OBUS;
wire [16*16 -1 : 0] PE16X1_DBUS;
wire [32*16 -1 : 0] PE16X1_WBUS;
wire [16*16 -1 : 0] UNITYBUS;

assign UNITYBUS = {16'h1000, 16'h4000, 16'h4000, 16'h4000, 16'h4000, 16'h4000,
16'h4000, 16'h4000}; // Values of one, the first one has the point at 2^-12

generate

for (n = 1; n <= 8; n=n+1) begin: PE16X1_DATA_INTERLEAVE
  assign PE16X1_DBUS[(2*n)*16 - 1 -: 16] = XSTATE_FFBUS[n*16-1 -: 16];
  assign PE16X1_DBUS[(2*n-1)*16 - 1 -: 16] = UNITYBUS[n*16-1 -: 16]; 
end

for (n = 1; n <= 8; n=n+1) begin: PE16X1_WEIGHT_INTERLEAVE
  assign PE16X1_WBUS[(2*n)*32 - 1 -: 32] = ERRSCALED_SAT;
  assign PE16X1_WBUS[(2*n-1)*32 - 1 -: 32] = WOUT_FFBUS[n*32-1 -: 32];
end

endgenerate

pe_16x1_hybrid_trunc #(32, 16, 16, 1) PE16X1 (
  .ce(1'b1),
  .clk(clk),
  .DATA(PE16X1_DBUS),
  .WEIGHT(PE16X1_WBUS),
  .Q(WEIGHT_OBUS)
);

// Drive the weight feedback wire with the 16x1 processor's output
generate
for (n = 1; n <= 8; n=n+1) begin: WOUT_FB_VALDELAYS
  for(k = 1; k <= 32; k=k+1) begin: WOUT_FB_BITDELAYS
    wire WOUT_FB_TMP;
    dff WOUT_FBREG1 (
      .d(WEIGHT_OBUS[n*32-k]),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(WOUT_FB_TMP)
    );
    dff WOUT_FBREG2 (
      .d(WOUT_FB_TMP),
      .clk(clk),
      .clrn(rst_N),
      .prn(1'b1),
      .q(WOUT_FBBUS[n*32-k])
    );
  end
end
endgenerate

// Setup the registered module outputs (weights and predicted output)
always @(posedge clk) begin: OUTPUT_ASSIGN
  case (ce)
    // CE=1'b0: LOCK UP AND FORWARD LAST OUTPUT
    1'b0: begin
      W_out <= W_out;
      est <= est;
    end

    // MODE=2'b01 and CE=1'b1: BLOCK MVM MODE
    1'b1: begin
      W_out <= WEIGHT_OBUS;
      est <= OBUS_PE8X2[32*2 -1 -: 32];
    end

    // Default mode... lock up and forward last output  
    default: begin
      W_out <= W_out;
      est <= est;
    end
  endcase
end

// Create a data valid output in sync with input data
wire [1:0] slow_count;
slow_Ctr DVALID_CTR (
  .clock(clk),
  .sclr(!rst_N),
  .q(slow_count)
);

assign data_valid = slow_count[1] && slow_count[0];

endmodule
