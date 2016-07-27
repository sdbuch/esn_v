module pe_8x4_16bit #(parameter WORD_LEN = 16, NEU_IN=8, NEU_OUT = 4) 
(ce, clk, DATA, WEIGHT, Q);

// Keep old parameters from pe_generic.v in case they need to be changed
// However this should only be used for an 8 input 4 output 16 bit processor
// Synapse inputs are Q0.15 signed
// Neuron inputs are Q3.12 signed
// Neuron outputs are Q0.15 signed
//
// Old messages:
// The parameter NEU_IN _MUST_ be a power of 2
// The parameters NEU_OUT and WORD_LEN can be positive integers, but WORD_LEN
//   should be <= 18 so that the Cyclone embedded multipliers are used optimally

// System inputs
input ce, clk;

// Input neurons
input [(WORD_LEN*NEU_IN-1):0] DATA;

// Synapses
input [(WORD_LEN*NEU_IN*NEU_OUT-1):0] WEIGHT;

// Product intermediate outputs
wire [((2*WORD_LEN)*NEU_IN*NEU_OUT-1):0] PROD;


// Second Layer Adder (parallel adders) Intermediate Outputs
wire [(((2*WORD_LEN)+6)*NEU_OUT-1):0] SUM;

// Transfer Function Layer Outputs
wire [(WORD_LEN*NEU_OUT-1):0] LUT_INTERP;

// Outputs
output reg [(WORD_LEN*NEU_OUT-1):0] Q;

// Instantiation based submodules
// Includes MULTIPLIERS, 2to1 ADDERS, PARALLEL ADDERS
genvar n;
generate

// Multipliers
for (n = 1; n <= NEU_IN*NEU_OUT; n=n+1) begin: MULTS
  mul16x16to32 MU (
    .dataa(DATA[((((n-1) % NEU_IN)+1)*WORD_LEN-1):(((n-1) % NEU_IN)*WORD_LEN)]),
    .datab(WEIGHT[(n*WORD_LEN-1)-:WORD_LEN]),
    .result(PROD[(n*(2*WORD_LEN)-1)-:2*WORD_LEN])
  );
end

// Parallel Adders
// Sign extend the first 7 product inputs
// Zero-pad the back of the last product input
// If the point position of the input u changes, the pad sizes should change too
for (n = 0; n < NEU_OUT; n=n+1) begin: PARALLEL_ADDS
  // Can do sign extension with $signed() perhaps?
  padd_8x36signed_to_1x38signed PA (
    .data0x(
      {{(3){PROD[((NEU_IN*n+1)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+1)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data1x(
      {{(3){PROD[((NEU_IN*n+2)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+2)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data2x(
      {{(3){PROD[((NEU_IN*n+3)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+3)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data3x(
      {{(3){PROD[((NEU_IN*n+4)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+4)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data4x(
      {{(3){PROD[((NEU_IN*n+5)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+5)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data5x(
      {{(3){PROD[((NEU_IN*n+6)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+6)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data6x(
      {{(3){PROD[((NEU_IN*n+7)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+7)*(2*WORD_LEN)-1)-:2*WORD_LEN]}
    ),
    .data7x(
      {{{PROD[((NEU_IN*n+8)*(2*WORD_LEN)-1)]}},
      PROD[((NEU_IN*n+8)*(2*WORD_LEN)-1)-:2*WORD_LEN], 3'b0}
    ),
    .result(
      SUM[((n+1)*((2*WORD_LEN)+6)-1)-:((2*WORD_LEN)+6)]
    )
  );
end

endgenerate

// TRANSFER FUNCTION LUT BLOCK
tf_tanh #(2*WORD_LEN+6, NEU_OUT) TF0(
  .clk(clk),
  .IBUS(SUM),
  .OBUS(LUT_INTERP)
);


// OUTPUT STAGE
always @(posedge clk) begin: OUTPUT
  //integer i;
  case (ce)
    // CE=1'b0: LOCK UP AND FORWARD LAST OUTPUT
    1'b0: begin
      Q <= Q;
    end

    // MODE=2'b01 and CE=1'b1: BLOCK MVM MODE
    1'b1: begin
      Q <= LUT_INTERP;
      // Next lines are for use in weight update enabled PEs
      /*for (i = NEU_OUT; i < (NEU_IN*NEU_OUT>>1); i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= {(WORD_LEN){1'b0}};
      end*/
    end

    // Default mode... lock up and forward last output  
    default: begin
      Q <= Q;
    end
  endcase

end				 


endmodule
