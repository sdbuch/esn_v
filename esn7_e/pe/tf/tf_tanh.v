module tf_tanh #(parameter WORD_LEN = 38, NUM_IN = 4)
(clk, IBUS, OBUS);

// Inputs
input [WORD_LEN*NUM_IN-1:0] IBUS;
input clk;

// Internals
wire [16*NUM_IN-1:0] LUTBUS;
wire [16*NUM_IN-1:0] LUT_PT;
wire [16*NUM_IN-1:0] LUT_CF;
wire [16*NUM_IN-1:0] LUTBUS_FF;
wire [32*NUM_IN-1:0] IPROD;
wire [16*NUM_IN-1:0] INTERP;

// Outputs
output [16*NUM_IN-1:0] OBUS;

// BEGIN COMBINATIONAL CODE
genvar n,k;
generate

// Generate parallel circuits
for (n = 1; n <= NUM_IN; n=n+1) begin: LOGIC
  // Saturate adder outputs and setup LUT inputs
  assign LUTBUS[n*16-1-:16] = (
    &IBUS[n*WORD_LEN-1-:6] || ~|IBUS[n*WORD_LEN-1-:6] ?
    {IBUS[n*WORD_LEN-1], IBUS[n*WORD_LEN-1-6-:15]} :
    ({1'b0, {(15){1'b1}}} ^ {(16){IBUS[n*WORD_LEN-1]}})
  );

  // Create memory
  tf_tanh_mem LUT (
    .address_a({1'b0,LUTBUS[n*16-1-:8]}), // interp point
    .address_b({1'b1,LUTBUS[n*16-1-:8]}), // slope
    .q_a(LUT_PT[n*16-1-:16]),
    .q_b(LUT_CF[n*16-1-:16]),
    .clock(clk)
  );

  // Create interpolation multiplier/adder
  // Create input feedforward
  for (k=1; k <= 16; k=k+1) begin: DELAYS
    wire DEL_LINK;
    dff DEL_A (
      .d(LUTBUS[n*16-k]),
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
      .q(LUTBUS_FF[n*16-k])
    );
  end

  // Create multiplier. The CF is Q0.15 and the input is Q2.13 (signed)
  mul16x16to32 MU (
    .dataa(LUT_CF[16*n-1-:16]),
    .datab(LUTBUS_FF[16*n-1-:16]),
    .result(IPROD[32*n-1-:32])
  );
  // Create adder. The CF*input is Q3.28 (but tested, less than 1)
  // and the interp point is Q0.15
  add_16x16signed AD (
    .dataa({IPROD[32*n-1], IPROD[32*n-5-:15]}),
    .datab(LUT_PT[16*n-1-:16]),
    .result(INTERP[16*n-1-:16])
  );

end

endgenerate


// Output assign
assign OBUS = INTERP;


endmodule
