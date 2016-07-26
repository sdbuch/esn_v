module pe_8x2_hybrid #(parameter WWORD_LEN = 32, SWORD_LEN = 16, NEU_IN=8,
NEU_OUT = 2) (ce, clk, DATA, WEIGHT, Q);

// State inputs are Q0.15 signed
// Input data is Q3.12 signed
// Output weight inputs are Q10.21 signed

// System inputs
input ce, clk;

// Input neurons
input [(SWORD_LEN*NEU_IN-1):0] DATA;

// Synapses
input [(SWORD_LEN*NEU_IN+WWORD_LEN*NEU_IN)-1:0] WEIGHT;

// Product intermediate outputs
wire [((WWORD_LEN+SWORD_LEN)*NEU_IN + ((2*SWORD_LEN)*NEU_IN)-1):0] PROD;

// Second Layer Adder (parallel adders) Intermediate Outputs
// The +6 term is for the bus extend on the synapse connected to esn input
// The first +3 term is for the bus extend on the synapse connected to esn input
// The second +3 term is to account for accumulation of 8 inputs into the padd output
wire [(WWORD_LEN+SWORD_LEN+3+3)+(SWORD_LEN*2+6+3)-1:0] SUM;

// Transfer Function Layer Outputs
wire [(2*WWORD_LEN-1):0] LUT_INTERP;

// Outputs
output reg [(2*WWORD_LEN-1):0] Q;

// Instantiation based submodules
// Includes MULTIPLIERS, 2to1 ADDERS, PARALLEL ADDERS
genvar n;
generate

// Multipliers
// Route the NORM MULTIPLIER WEIGHTS on the LSBs of the weight bus
// Route the OUTPUT MULTIPLIER WEIGHTS on the MSBs of the weight bus
// As always, route the input synapse on the MSBs of whichever bus section is at
//  hand, and the input data on the MSBs of the DATA bus
for (n = 1; n <= NEU_IN; n=n+1) begin: NORM_MULTS
  mul16x16to32 N_MU (
    .dataa(DATA[((((n-1) % NEU_IN)+1)*SWORD_LEN-1):(((n-1) % NEU_IN)*SWORD_LEN)]),
    .datab(WEIGHT[(n*SWORD_LEN-1)-:SWORD_LEN]),
    .result(PROD[(n*(2*SWORD_LEN)-1)-:2*SWORD_LEN])
  );
end

// The weight bus offset for these is 8*SWORD_LEN
// Likewise the PROD bus offset is 16*SWORD_LEN
for (n = 1; n <= NEU_IN; n=n+1) begin: WOUT_MULTS
  mul16x32to48 W_MU (
    .dataa(DATA[((((n-1) % NEU_IN)+1)*SWORD_LEN-1):(((n-1) % NEU_IN)*SWORD_LEN)]),
    .datab(WEIGHT[(n*WWORD_LEN-1) + NEU_IN*SWORD_LEN-:WWORD_LEN]),
    .result(PROD[(n*(SWORD_LEN+WWORD_LEN)-1) + 2*NEU_IN*SWORD_LEN-:(SWORD_LEN+WWORD_LEN)])
  );
end

endgenerate

// Parallel Adders
// Sign extend the first 7 product inputs (LSBs)
// Zero-pad the back of the last product input (MSBs)
// If the point position of the input u changes, the pad sizes should change too
padd_8x38signed_to_1x41signed PA38 (
  .data0x(
    {{(6){PROD[(1*(2*SWORD_LEN)-1)]}},
    PROD[((1)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data1x(
    {{(6){PROD[((2)*(2*SWORD_LEN)-1)]}},
    PROD[((2)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data2x(
    {{(6){PROD[((3)*(2*SWORD_LEN)-1)]}},
    PROD[((3)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data3x(
    {{(6){PROD[((4)*(2*SWORD_LEN)-1)]}},
    PROD[((4)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data4x(
    {{(6){PROD[((5)*(2*SWORD_LEN)-1)]}},
    PROD[((5)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data5x(
    {{(6){PROD[((6)*(2*SWORD_LEN)-1)]}},
    PROD[((6)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data6x(
    {{(6){PROD[((7)*(2*SWORD_LEN)-1)]}},
    PROD[((7)*(2*SWORD_LEN)-1)-:2*SWORD_LEN]}
  ),
  .data7x(
    {PROD[((8)*(2*SWORD_LEN)-1)-:2*SWORD_LEN], 6'b0}
  ),
  .result(
    SUM[((1)*((2*SWORD_LEN)+9)-1)-:((2*SWORD_LEN)+9)]
  )
);

padd_8x51signed_to1x54signed PA51 (
  .data0x(
    {{(3){PROD[((WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[((WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data1x(
    {{(3){PROD[(2*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(2*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data2x(
    {{(3){PROD[(3*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(3*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data3x(
    {{(3){PROD[(4*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(4*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data4x(
    {{(3){PROD[(5*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(5*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data5x(
    {{(3){PROD[(6*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(6*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data6x(
    {{(3){PROD[(7*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)]}},
    PROD[(7*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:(WWORD_LEN+SWORD_LEN)]}
  ),
  .data7x(
    {PROD[((8)*(WWORD_LEN+SWORD_LEN)+16*SWORD_LEN-1)-:WWORD_LEN+SWORD_LEN],
    3'b0}
  ),
  .result(
    SUM[((1)*((WWORD_LEN+SWORD_LEN)+6)+(2*SWORD_LEN+9)-1)-:((WWORD_LEN+SWORD_LEN)+6)]
  )
);
// TRANSFER FUNCTION LUT BLOCKS
tf_inv #((WWORD_LEN+SWORD_LEN+3+3)+(SWORD_LEN*2+6+3), 2) TF0(
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
