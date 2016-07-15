module pe_16x4 #(parameter WORD_LEN = 16, NEU_IN=16, NEU_OUT = 4) 
(ce, clk, mode, D, W, Q);

// Default of 16 neurons in, and 4 neurons out
// (64 WEIGHT INPUTS AND 16 NEURON INPUTS)
// The parameter NEU_IN _MUST_ be a power of 2
// The parameters NEU_OUT and WORD_LEN can be positive integers, but WORD_LEN
//   should be <= 18 so that the Cyclone embedded multipliers are used optimally

// Mode config signal
input [1:0] mode;
input ce, clk;

// Input neurons
input [(WORD_LEN*NEU_IN-1):0] D;								

// Synapses
input [(WORD_LEN*NEU_IN*NEU_OUT-1):0] W;

// Product intermediate outputs
// An extra bit is added by the multipliers to their outputs
// to account for the LPM_ADD_SUB constraints later on
wire [((2*WORD_LEN+1)*NEU_IN*NEU_OUT-1):0] T;

// First Layer Sum Intermediate Outputs
wire [((2*WORD_LEN+1)*(NEU_IN*NEU_OUT >> 1)-1):0] S;

// Second Layer Adder (parallel adders) Intermediate Outputs
wire [(((2*WORD_LEN)+$clog2((NEU_IN >> 1)))*NEU_OUT-1):0] P;

// Transfer Function Layer Outputs
wire [(WORD_LEN*NEU_OUT-1):0] L;

// Outputs
output reg [(WORD_LEN*(NEU_IN*NEU_OUT >> 1)-1):0] Q;


// Instantiation based submodules
// Includes MULTIPLIERS, 2to1 ADDERS, PARALLEL ADDERS
genvar n;
generate

// Multipliers
for (n = 1; n <= NEU_IN*NEU_OUT; n=n+1) begin: MULTS
  mul18x18 MUL (
    .dataa(D[((n % NEU_IN)*WORD_LEN-1):(((n-1) % NEU_IN)*WORD_LEN)]),
    .datab(W[(n*WORD_LEN-1):((n-1)*WORD_LEN)]),
    .result(T[(n*(2*WORD_LEN+1)-1):((n-1)*(2*WORD_LEN+1))])
  );
end

// 2 to 1 Adders
for (n = 0; n < (NEU_IN*NEU_OUT >> 1); n=n+1) begin: SERIAL_ADDS
  add32x32 ADD (
    .dataa (T[((2*n+1)*(2*WORD_LEN+1)-1):((2*n)*(2*WORD_LEN+1))]),
    .datab (T[((2*n+2)*(2*WORD_LEN+1)-1):((2*n+1)*(2*WORD_LEN+1))]),
    .result(S[((n+1)*(2*WORD_LEN+1)-1):(n*(2*WORD_LEN+1))])
  );
end

//Ideally the below should be configured from an external script. The parallel adder 
//has to be set up with (NEU_IN >> 1) inputs, and we need NEU_OUT of them
//Implicitly in the below code, (NEU_IN >> 1) == 8 or it breaks...

// Parallel Adders
for (n = 0; n < NEU_OUT; n=n+1) begin: PARALLEL_ADDS
  add32x32 PADD (
    .data0x(S[((NEU_IN>>1)*(n+1)*(2*WORD_LEN+1)-1):(((NEU_IN>>1)*n)*(2*WORD_LEN+1)+1)]),
    .data1x(S[((NEU_IN>>1)*(n+2)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+1)*(2*WORD_LEN+1)+1 )]),
    .data2x(S[((NEU_IN>>1)*(n+3)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+2)*(2*WORD_LEN+1)+1 )]),
    .data3x(S[((NEU_IN>>1)*(n+4)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+3)*(2*WORD_LEN+1)+1 )]),
    .data4x(S[((NEU_IN>>1)*(n+5)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+4)*(2*WORD_LEN+1)+1 )]),
    .data5x(S[((NEU_IN>>1)*(n+6)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+5)*(2*WORD_LEN+1)+1 )]),
    .data6x(S[((NEU_IN>>1)*(n+7)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+6)*(2*WORD_LEN+1)+1 )]),
    .data7x(S[((NEU_IN>>1)*(n+8)*(2*WORD_LEN+1)-1):( ((NEU_IN>>1)*n+7)*(2*WORD_LEN+1)+1 )]),
    .result(
      P[((n+1)*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1):(n*((2*WORD_LEN)+$clog2((NEU_IN>>1))))]
    )
  );
end

endgenerate



// TRANSFER FUNCTION LUT BLOCK
tf_block TF0(
  .clk(clk),
  .mode(mode),
  .I0(P0[34:19]),
  .I1(P1[34:19]),
  .I2(P2[34:19]),
  .I3(P3[34:19]),
  .Q0(L0),
  .Q1(L1),
  .Q2(L2),
  .Q3(L3)
);


// OUTPUT STAGE
always @(posedge clk) begin
  case ({ce, mode})
    3'b000: begin
      Q0 <= Q0;
      Q1 <= Q1;
      Q2 <= Q2;
      Q3 <= Q3;
      Q4 <= Q4;
      Q5 <= Q5;
      Q6 <= Q6;
      Q7 <= Q7;
      Q8 <= Q8;
      Q9 <= Q9;
      Q10 <= Q10;
      Q11 <= Q11;
      Q12 <= Q12;
      Q13 <= Q13;
      Q14 <= Q14;
      Q15 <= Q15;
      Q16 <= Q16;
      Q17 <= Q17;
      Q18 <= Q18;
      Q19 <= Q19;
      Q20 <= Q20;
      Q21 <= Q21;
      Q22 <= Q22;
      Q23 <= Q23;
      Q24 <= Q24;
      Q25 <= Q25;
      Q26 <= Q26;
      Q27 <= Q27;
      Q28 <= Q28;
      Q29 <= Q29;
      Q30 <= Q30;
      Q31 <= Q31;
    end
    3'b100: begin
      Q0 <= S0[32:17];
      Q1 <= S1[32:17];
      Q2 <= S2[32:17];
      Q3 <= S3[32:17];
      Q4 <= S4[32:17];
      Q5 <= S5[32:17];
      Q6 <= S6[32:17];
      Q7 <= S7[32:17];
      Q8 <= S8[32:17];
      Q9 <= S9[32:17];
      Q10 <= S10[32:17];
      Q11 <= S11[32:17];
      Q12 <= S12[32:17];
      Q13 <= S13[32:17];
      Q14 <= S14[32:17];
      Q15 <= S15[32:17];
      Q16 <= S16[32:17];
      Q17 <= S17[32:17];
      Q18 <= S18[32:17];
      Q19 <= S19[32:17];
      Q20 <= S20[32:17];
      Q21 <= S21[32:17];
      Q22 <= S22[32:17];
      Q23 <= S23[32:17];
      Q24 <= S24[32:17];
      Q25 <= S25[32:17];
      Q26 <= S26[32:17];
      Q27 <= S27[32:17];
      Q28 <= S28[32:17];
      Q29 <= S29[32:17];
      Q30 <= S30[32:17];
      Q31 <= S31[32:17];
    end

    default: /* synthesis keep */ begin
      Q0 <= L0;
      Q1 <= L1;
      Q2 <= L2;
      Q3 <= L3;
      Q4 <= 16'b0;
      Q5 <= 16'b0;
      Q6 <= 16'b0;
      Q7 <= 16'b0;
      Q8 <= 16'b0;
      Q9 <= 16'b0;
      Q10 <= 16'b0;
      Q11 <= 16'b0;
      Q12 <= 16'b0;
      Q13 <= 16'b0;
      Q14 <= 16'b0;
      Q15 <= 16'b0;
      Q16 <= 16'b0;
      Q17 <= 16'b0;
      Q18 <= 16'b0;
      Q19 <= 16'b0;
      Q20 <= 16'b0;
      Q21 <= 16'b0;
      Q22 <= 16'b0;
      Q23 <= 16'b0;
      Q24 <= 16'b0;
      Q25 <= 16'b0;
      Q26 <= 16'b0;
      Q27 <= 16'b0;
      Q28 <= 16'b0;
      Q29 <= 16'b0;
      Q30 <= 16'b0;
      Q31 <= 16'b0;
    end
  endcase

end				 


endmodule
