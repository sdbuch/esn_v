`timescale 1ns/1ps

module pe_16x4_tb;

reg ce, clk;
reg [1:0] mode;

// Runtime params
// Change depending on what the PE design is
integer ndata = 'd16;
integer nweight = 'd64;
integer nout = 'd4;
integer nweightout = 'd32;
integer wordlen = 'd16;

// Data, weight, output registers
reg [wordlen*ndata:0] D;
reg [wordlen*nweight:0] W;
wire [wordlen*nweightout:0] Q;

//reg [15:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15;
//reg [15:0] W0, W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11, W12, W13, W14, W15;
//reg [15:0] W16, W17, W18, W19, W20, W21, W22, W23, W24, W25, W26, W27, W28, W29, W30, W31;
//reg [15:0] W32, W33, W34, W35, W36, W37, W38, W39, W40, W41, W42, W43, W44, W45, W46, W47;
//reg [15:0] W48, W49, W50, W51, W52, W53, W54, W55, W56, W57, W58, W59, W60, W61, W62, W63;
//wire [15:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
//wire [15:0] Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31;

// Runtime params
// Change based on what inputs the PE should get
integer val = (wordlen)'h0B2A;
integer weight = (wordlen)'h2F04;

initial begin
	// Initialize registers
	for (i = 1 ; i <= ndata; i=i+1) begin
		D[(i*wordlen-1):((i-1)*wordlen)] = val;
	end
	for (i = 1 ; i <= nweight; i=i+1) begin
		W[(i*wordlen-1):((i-1)*wordlen)] = weight;
	end
end



pe_16x4 DUT();



endmodule
