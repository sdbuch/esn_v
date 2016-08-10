module pe_16x1_hybrid_trunc #(parameter WWORD_LEN = 32, SWORD_LEN = 16, NEU_IN=16,
NEU_OUT = 1) (ce, clk, DATA, WEIGHT, Q);

// State inputs are Q0.15 signed
// Output weight inputs and scaled error inputs are Q10.21 signed
// Wire the extended state vector plus NEU_IN (SWORD_LEN)'b1 values as DATA
// Wire the scaled error inputs x(NEU_IN) and the output weights as WEIGHT

// System inputs
input ce, clk;

// Input neurons
input [(SWORD_LEN*NEU_IN-1):0] DATA;

// Synapses
input [WWORD_LEN*NEU_IN-1:0] WEIGHT;

// Product intermediate outputs
wire [((WWORD_LEN+SWORD_LEN)*NEU_IN -1):0] PROD;

// 2 to 1 Adder result bus
wire [(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1:0] SUM;

// Outputs
output [((NEU_IN>>1)*WWORD_LEN-1):0] Q;

// Instantiation based submodules
// Includes MULTIPLIERS, 2to1 ADDERS, PARALLEL ADDERS
genvar n;
generate

// Multipliers
for (n = 1; n <= NEU_IN; n=n+1) begin: MULTS
  mul16x32to48 MU (
    .dataa(DATA[((((n-1) % NEU_IN)+1)*SWORD_LEN-1):(((n-1) % NEU_IN)*SWORD_LEN)]),
    .datab(WEIGHT[(n*WWORD_LEN-1) -: WWORD_LEN]),
    .result(PROD[(n*(SWORD_LEN+WWORD_LEN)-1) -:(SWORD_LEN+WWORD_LEN)])
  );
end


// Serial adders
// Designed so that the 16'b1 inputs are on the LSBs of each pair of DATA inputs 
for (n = 1; n <= (NEU_IN>>1)-1; n=n+1) begin: SERIAL_ADDS
  add_48x48signed SAD (
    .dataa(
      {{(1){PROD[(2*n)*(WWORD_LEN+SWORD_LEN)-1]}},
      PROD[(2*n)*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN-1)]}
    ),
    .datab(
      PROD[(2*n-1)*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN)]
    ),
    .result(SUM[n*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN)])
  );
end

endgenerate
// Setup the MSB serial adder separate (for the feedforward input weight)
add_48x48signed SAD_MSB (
  .dataa(
    PROD[NEU_IN*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN)]
  ),
  .datab(
    PROD[(NEU_IN-1)*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN)]
  ),
  .result(SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1 -: (WWORD_LEN+SWORD_LEN)])
);

generate
// Do output saturation
for (n = 1; n <= (NEU_IN>>1)-1; n=n+1) begin: OUTPUT_SAT
  assign Q[n*WWORD_LEN-1-:WWORD_LEN] = (
    (~|SUM[n*(WWORD_LEN+SWORD_LEN)-1 -:3] ||
    &SUM[n*(WWORD_LEN+SWORD_LEN)-1 -:3]) ? 
    {SUM[n*(WWORD_LEN+SWORD_LEN)-1], SUM[n*(WWORD_LEN+SWORD_LEN)-1-3 -: 31]} : 
    ({1'b0, {(31){1'b1}}} ^ {(32){SUM[n*(WWORD_LEN+SWORD_LEN)-1]}})
  );
end

endgenerate

// Saturate the MSBs too
assign Q[(NEU_IN>>1)*WWORD_LEN-1-:WWORD_LEN] = (
  (~|SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1 -:5] ||
  &SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1 -:5]) ? 
  {SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1], SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1-5 -: 31]} : 
  ({1'b0, {(31){1'b1}}} ^ {(32){SUM[(NEU_IN>>1)*(WWORD_LEN+SWORD_LEN)-1]}})
);

// OUTPUT STAGE
// Do this assignment manually for the truncated mode

/*
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
      for (i = NEU_OUT; i < (NEU_IN*NEU_OUT>>1); i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= {(WORD_LEN){1'b0}};
      end
    end

    // Default mode... lock up and forward last output  
    default: begin
      Q <= Q;
    end
  endcase

end				 
*/



endmodule
