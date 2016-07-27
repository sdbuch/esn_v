module tf_inv #(parameter BITS_IN = 95, NUM_IN = 2)
(clk, IBUS, OBUS);

// Inputs
input [BITS_IN-1:0] IBUS;
input clk;

// Internals
wire [24-1:0] LUTBUS;
wire [18-1:0] LUT_PT_H;
wire [18-1:0] LUT_CF_H;
wire [18-1:0] LUT_PT_L;
wire [18-1:0] LUT_CF_L;
wire [18-1:0] LUT_PT;
wire [18-1:0] LUT_CF;
wire [17-1:0] LUTBUS_FF;
wire [36-1:0] IPROD;
wire [NUM_IN*32-1:0] INTERP;

// Outputs
output [32*NUM_IN-1:0] OBUS;

// BEGIN COMBINATIONAL CODE
genvar n,k;
generate

// Generate parallel circuits, one output neuron at a time
for (n = 1; n <= 1; n=n+1) begin: LOGIC_NORM
  // First set: for NORM output neuron
  // The sign bit is always 0
  assign LUTBUS[n*24-1-:24] = (
    ~|IBUS[n*41-1-:3] ?
    {IBUS[n*41-1-3-:24]} :
    ({1'b0, {(23){1'b1}}})
  );

  // Create memory for upper 8 bits
  tf_inv_mem LUT_H (
    .address_a({1'b0,LUTBUS[n*24-1-:8]}), // interp point
    .address_b({1'b1,LUTBUS[n*24-1-:8]}), // slope
    .q_a(LUT_PT_H[n*18-1-:18]),
    .q_b(LUT_CF_H[n*18-1-:18]),
    .clock(clk)
  );
  // Create memory for lower 8 bits
  tf_inv_mem LUT_L (
    .address_a({1'b0,LUTBUS[n*24-8-1-:8]}), // interp point
    .address_b({1'b1,LUTBUS[n*24-8-1-:8]}), // slope
    .q_a(LUT_PT_L[n*18-1-:18]),
    .q_b(LUT_CF_L[n*18-1-:18]),
    .clock(clk)
  );

  // Create the selector for the forwarding logic
  // A value of 0 for the MSB indicates to use the _L lookups
  // Value of 1 indicates to use the _H lookups
  wire [16:0] LUTBUS_FWD;
  assign LUTBUS_FWD = (
    ~|LUTBUS[n*24-1 -: 8] ?
    {1'b0, LUTBUS[n*24-1-8 -: 16]} :
    {1'b1, LUTBUS[n*24-1 -: 16]}
  );
  
  // Create interpolation multiplier/adder
  // Create input feedforward
  for (k=1; k <= 17; k=k+1) begin: DELAYS_NORM
    wire DEL_LINK;
    dff DEL_A (
      .d(LUTBUS_FWD[n*17-k]),
      .clk(clk),
      .clrn(1'b1),
      .prn(1'b1),
      .q(DEL_LINK)
    );
    dff DEL_B (
      .d(DEL_LINK),
      .clk(clk),
      .clrn(1'b1),
      .prn(1'b1),
      .q(LUTBUS_FF[n*17-k])
    );
  end

  assign LUT_CF = (
    LUTBUS_FF[n*17-1] ? LUT_CF_H[n*18-1-:18] : LUT_CF_L[n*18-1-:18]
  );
assign LUT_PT = (
    LUTBUS_FF[n*17-1] ? LUT_PT_H[n*18-1-:18] : LUT_PT_L[n*18-1-:18]
  );

  // Create multiplier. The CF is either Q1.16 sgn or Q9.8 sgn
  // and the input is either Q8.8 uns or Q0.16 uns
  mul18x18to36 MU (
    .dataa(LUT_CF[18*n-1-:18]),
    .datab({2'b0, LUTBUS_FF[16*n-1-:16]}),
    .result(IPROD[36*n-1-:36])
  );
  // Create adder. The CF*input is Q11.24 sgn (with prev extension)
  // and the interp point is either Q1.16 sgn or Q9.8 sgn
  wire [35:0] LUT_PT_PAD;
  wire [35:0] SUM_TMP;
  assign LUT_PT_PAD = (
    LUTBUS_FF[n*17-1] ? {10'b0, LUT_PT[n*18-1-:18], 8'b0} : {2'b0,
    LUT_PT[n*18-1-:18], 16'b0}
  );
  add36x36signed_sub SUB (
    .dataa(LUT_PT_PAD),
    .datab(IPROD[36*n-1-:36]),
    .result(SUM_TMP)
  );

  // Truncate the output to Q11.20 (32bit)
  assign INTERP[n*32-1-:32] = SUM_TMP[36-1-:32];

end

endgenerate

// Pass through second input without scaling
// Add a delay to match the norm path though
// Saturate the Q17.36 signed input to Q10.21
wire [31:0] IBUS_UPPER_SAT;
assign IBUS_UPPER_SAT = (
  (~|IBUS[BITS_IN-1 -: 8] || &IBUS[BITS_IN-1 -: 8])?
  {IBUS[BITS_IN-1], IBUS[BITS_IN-1-8 -: 31]} :
  ({1'b0, {(31){1'b1}}} ^ {(32){IBUS[BITS_IN-1]}})
);
generate

for (k=1; k <= 32; k=k+1) begin: DELAYS_WEIGHT
  wire DEL_LINK;
  dff DEL_A (
    .d(IBUS_UPPER_SAT[32-k]),
    .clk(clk),
    .clrn(1'b1),
    .prn(1'b1),
    .q(DEL_LINK)
  );
  dff DEL_B (
    .d(DEL_LINK),
    .clk(clk),
    .clrn(1'b1),
    .prn(1'b1),
    .q(INTERP[2*32-k])
  );
end

endgenerate

// Output assign
assign OBUS = INTERP;


endmodule
