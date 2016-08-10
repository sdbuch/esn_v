module esn_top(clk, ce, rst_N, est, W_out, RDOUT_DATA_VALID, U);

input clk;      // System clock
input rst_N;    // Global sync reset
input ce;       // Readout output enable (it still trains even when ce is low...)
output [31:0] est;    // predicted output, from readout
output [8*32 -1 : 0] W_out;  // learned weights, from readout
output [15:0] U;      // Reservoir input

wire [5:0] DATA_ADDR;   // lookup address for input/output train data
wire [8*16-1:0] XSTATE; // extended system state from reservoir

reg rst_pulse_N;
res_top RESERVOIR (
  .clk(clk),
  .rst_N(rst_pulse_N),
  .XSTATE(XSTATE),
  .ADDR_OUT(DATA_ADDR)
);

assign U = XSTATE[8*16-1 -: 16];

wire rstdly_N;
rdout_rst_sreg SREGD (
  .clock(clk),
  .shiftin(rst_pulse_N),
  .shiftout(rstdly_N)
);

reg [2:0] count; // 6 cycle reset pulse
reg [1:0] RSTSTATE;
reg [1:0] RST_SREG;
always @(posedge clk) begin: RESET_MON
  RST_SREG[1] <= RST_SREG[0];
  RST_SREG[0] <= rst_N;
end

always @(posedge clk) begin: RESET_NEXTSTATE
  if (RST_SREG[1] && !RST_SREG[0]) begin: RESET_TRIGGERED
    RSTSTATE <= 2'b00;
  end else if (RSTSTATE == 2'b00) begin: RESET_INITIALIZED
    RSTSTATE <= 2'b01;
  end else if (count >= 3'b100) begin: COUNT_MAX
    RSTSTATE <= 2'b10;
  end else if (RSTSTATE == 2'b10) begin: RESET_FINISHED
    RSTSTATE <= 2'b11;
  end else begin: KEEP_STATE
    RSTSTATE <= RSTSTATE; 
  end
end

always @(posedge clk) begin: RESET_SM
  case (RSTSTATE)

    2'b00: begin: RESET_SM_INIT
      count <= 3'b0;
      rst_pulse_N <= 1'b0;
    end 

    2'b01: begin: RESET_SM_COUNT
      count <= count + 3'b001;
      rst_pulse_N <= 1'b0;
    end

    2'b10: begin: RESET_SM_MAXCOUNT
      rst_pulse_N <= 1'b1;
      count <= 3'b0;
    end

    2'b11: begin: RESET_SM_IDLE
      rst_pulse_N <= 1'b1;
      count <= 3'b0;
    end

    default: begin
      rst_pulse_N <= 1'b1;
      count <= 3'b0;
    end
  endcase
end

output RDOUT_DATA_VALID;
rdout_top READOUT (
  .clk(clk),
  .ce(ce),
  .rst_N(rstdly_N),
  .XSTATE(XSTATE),
  .addr(DATA_ADDR),
  .est(est),
  .W_out(W_out),
  .data_valid(RDOUT_DATA_VALID)
);

endmodule
