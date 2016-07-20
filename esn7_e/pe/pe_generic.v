module pe_generic #(parameter WORD_LEN = 16, NEU_IN=16, NEU_OUT = 4) 
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
  mul18x18 MU (
    .dataa(D[((((n-1) % NEU_IN)+1)*WORD_LEN-1):(((n-1) % NEU_IN)*WORD_LEN)]),
    .datab(W[(n*WORD_LEN-1):((n-1)*WORD_LEN)]),
    .result(T[(n*(2*WORD_LEN+1)-1):((n-1)*(2*WORD_LEN+1))])
  );
end

// 2 to 1 Adders
for (n = 0; n < (NEU_IN*NEU_OUT >> 1); n=n+1) begin: SERIAL_ADDS
  add32x32 AD (
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
  padd32x32 PA (
    .data0x(S[(((NEU_IN>>1)*n+1)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data1x(S[(((NEU_IN>>1)*n+2)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data2x(S[(((NEU_IN>>1)*n+3)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data3x(S[(((NEU_IN>>1)*n+4)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data4x(S[(((NEU_IN>>1)*n+5)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data5x(S[(((NEU_IN>>1)*n+6)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data6x(S[(((NEU_IN>>1)*n+7)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .data7x(S[(((NEU_IN>>1)*n+8)*(2*WORD_LEN+1)-1)-:2*WORD_LEN]),
    .result(
      P[((n+1)*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1)-:((2*WORD_LEN)+$clog2((NEU_IN>>1)))]
    )
  );
end

endgenerate

// TRANSFER FUNCTION LUT BLOCK
tf_block TF0(
  .clk(clk),
  .mode(mode),
  .I3(P[(4*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1)-:WORD_LEN]),
  .I2(P[(3*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1)-:WORD_LEN]),
  .I1(P[(2*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1)-:WORD_LEN]),
  .I0(P[(1*((2*WORD_LEN)+$clog2((NEU_IN>>1)))-1)-:WORD_LEN]),
  .Q3(L[(4*WORD_LEN-1):(3*WORD_LEN)]),
  .Q2(L[(3*WORD_LEN-1):(2*WORD_LEN)]),
  .Q1(L[(2*WORD_LEN-1):(1*WORD_LEN)]),
  .Q0(L[(1*WORD_LEN-1):(0*WORD_LEN)])
);


// OUTPUT STAGE
always @(posedge clk) begin: OUTPUT
  integer i;
  case ({ce, mode})
    // CE=1'b0: LOCK UP AND FORWARD LAST OUTPUT
    3'b000: begin
      Q <= Q;
    end

    3'b001: begin
      Q <= Q;
    end
    3'b010: begin
      Q <= Q;
    end
    3'b011: begin
      Q <= Q;
    end

    // MODE =2'b00 and CE=1'b1: WEIGHT UPDATE MODE
    3'b100: begin
      for (i = 0; i < (NEU_IN*NEU_OUT >> 1); i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN]
        <= S[((i+1)*(2*WORD_LEN+1)-1)-:WORD_LEN];
      end
    end

    // MODE=2'b01 and CE=1'b1: BLOCK MVM MODE
    3'b101: begin
      for (i = 0; i < NEU_OUT; i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= L[((i+1)*WORD_LEN-1)-:WORD_LEN];
      end
      for (i = NEU_OUT; i < (NEU_IN*NEU_OUT>>1); i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= {(WORD_LEN){1'b0}};
      end
    end

    // ALL OTHER MODES... KEEP BLOCK MVM MODE
    /* synthesis keep */
    default: begin
      for (i = 0; i < NEU_OUT; i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= L[((i+1)*WORD_LEN-1)-:WORD_LEN];
      end
      for (i = NEU_OUT; i < (NEU_IN*NEU_OUT>>1); i=i+1) begin
        Q[((i+1)*WORD_LEN-1)-:WORD_LEN] <= {(WORD_LEN){1'b0}};
      end
    end
  endcase

end				 


endmodule
