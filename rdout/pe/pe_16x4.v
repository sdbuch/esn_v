module pe_16x4(ce, clk, D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11,
								D12, D13, D14, D15, 
								W0, W1, W2, W3, W4, W5, W6, W7, W8, W9, W10, W11,
								W12, W13, W14, W15, W16, W17, W18, W19, W20, W21,
								W22, W23, W24, W25, W26, W27, W28, W29, W30, W31,
								W32, W33, W34, W35, W36, W37, W38, W39, W40, W41,
								W42, W43, W44, W45, W46, W47, W48, W49, W50, W51,
								W52, W53, W54, W55, W56, W57, W58, W59, W60, W61,
								W62, W63, 
								Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11,
								Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21,
								Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31,
								mode);

// Mode config signal
input [1:0] mode;
input ce, clk;
								
// Input neurons								
input [15:0] D0;
input [15:0] D1;
input [15:0] D2;
input [15:0] D3;
input [15:0] D4;
input [15:0] D5;
input [15:0] D6;
input [15:0] D7;
input [15:0] D8;
input [15:0] D9;
input [15:0] D10;
input [15:0] D11;
input [15:0] D12;
input [15:0] D13;
input [15:0] D14;
input [15:0] D15;

// Synapses
// W0-W15, W16-W31, W32-W47, W48-W63 respectively 
// correspond to the same output neurons
// NEURON 0
input [15:0] W0;
input [15:0] W1;
input [15:0] W2;
input [15:0] W3;
input [15:0] W4;
input [15:0] W5;
input [15:0] W6;
input [15:0] W7;
input [15:0] W8;
input [15:0] W9;
input [15:0] W10;
input [15:0] W11;
input [15:0] W12;
input [15:0] W13;
input [15:0] W14;
input [15:0] W15;
// NEURON 1
input [15:0] W16;
input [15:0] W17;
input [15:0] W18;
input [15:0] W19;
input [15:0] W20;
input [15:0] W21;
input [15:0] W22;
input [15:0] W23;
input [15:0] W24;
input [15:0] W25;
input [15:0] W26;
input [15:0] W27;
input [15:0] W28;
input [15:0] W29;
input [15:0] W30;
input [15:0] W31;
// NEURON 2
input [15:0] W32;
input [15:0] W33;
input [15:0] W34;
input [15:0] W35;
input [15:0] W36;
input [15:0] W37;
input [15:0] W38;
input [15:0] W39;
input [15:0] W40;
input [15:0] W41;
input [15:0] W42;
input [15:0] W43;
input [15:0] W44;
input [15:0] W45;
input [15:0] W46;
input [15:0] W47;
// NEURON 3
input [15:0] W48;
input [15:0] W49;
input [15:0] W50;
input [15:0] W51;
input [15:0] W52;
input [15:0] W53;
input [15:0] W54;
input [15:0] W55;
input [15:0] W56;
input [15:0] W57;
input [15:0] W58;
input [15:0] W59;
input [15:0] W60;
input [15:0] W61;
input [15:0] W62;
input [15:0] W63;

// Product intermediate outputs
// T0-T15, T16-T31, T32-T47, T48-T63 respectively 
// correspond to the same output neurons
// NEURON 0
wire [32:0] T0;
wire [32:0] T1;
wire [32:0] T2;
wire [32:0] T3;
wire [32:0] T4;
wire [32:0] T5;
wire [32:0] T6;
wire [32:0] T7;
wire [32:0] T8;
wire [32:0] T9;
wire [32:0] T10;
wire [32:0] T11;
wire [32:0] T12;
wire [32:0] T13;
wire [32:0] T14;
wire [32:0] T15;
// NEURON 1
wire [32:0] T16;
wire [32:0] T17;
wire [32:0] T18;
wire [32:0] T19;
wire [32:0] T20;
wire [32:0] T21;
wire [32:0] T22;
wire [32:0] T23;
wire [32:0] T24;
wire [32:0] T25;
wire [32:0] T26;
wire [32:0] T27;
wire [32:0] T28;
wire [32:0] T29;
wire [32:0] T30;
wire [32:0] T31;
// NEURON 2
wire [32:0] T32;
wire [32:0] T33;
wire [32:0] T34;
wire [32:0] T35;
wire [32:0] T36;
wire [32:0] T37;
wire [32:0] T38;
wire [32:0] T39;
wire [32:0] T40;
wire [32:0] T41;
wire [32:0] T42;
wire [32:0] T43;
wire [32:0] T44;
wire [32:0] T45;
wire [32:0] T46;
wire [32:0] T47;
// NEURON 3
wire [32:0] T48;
wire [32:0] T49;
wire [32:0] T50;
wire [32:0] T51;
wire [32:0] T52;
wire [32:0] T53;
wire [32:0] T54;
wire [32:0] T55;
wire [32:0] T56;
wire [32:0] T57;
wire [32:0] T58;
wire [32:0] T59;
wire [32:0] T60;
wire [32:0] T61;
wire [32:0] T62;
wire [32:0] T63;

// First Layer Sum Intermediate Outputs
// NEURON 0
wire [32:0] S0;
wire [32:0] S1;
wire [32:0] S2;
wire [32:0] S3;
wire [32:0] S4;
wire [32:0] S5;
wire [32:0] S6;
wire [32:0] S7;
// NEURON 1
wire [32:0] S8;
wire [32:0] S9;
wire [32:0] S10;
wire [32:0] S11;
wire [32:0] S12;
wire [32:0] S13;
wire [32:0] S14;
wire [32:0] S15;
// NEURON 2
wire [32:0] S16;
wire [32:0] S17;
wire [32:0] S18;
wire [32:0] S19;
wire [32:0] S20;
wire [32:0] S21;
wire [32:0] S22;
wire [32:0] S23;
// NEURON 3
wire [32:0] S24;
wire [32:0] S25;
wire [32:0] S26;
wire [32:0] S27;
wire [32:0] S28;
wire [32:0] S29;
wire [32:0] S30;
wire [32:0] S31;

// Second Layer Adder (parallel adders) Intermediate Outputs
// NEURON 0
wire [34:0] P0;
// NEURON 1
wire [34:0] P1;
// NEURON 2
wire [34:0] P2;
// NEURON 3
wire [34:0] P3;

// Transfer Function Layer Outputs
// NEURON 0
wire [15:0] L0;
// NEURON 1
wire [15:0] L1;
// NEURON 2
wire [15:0] L2;
// NEURON 3
wire [15:0] L3;

// Outputs
// Q0-Q3 are output neurons
// Q4-Q31 are weight update sum outputs
// Q0 formed from I0-I15 and W0-W15, and so on
// Q4-Q31 are used for weight update mode
output reg [15:0] Q0;
output reg [15:0] Q1;
output reg [15:0] Q2;
output reg [15:0] Q3;
output reg [15:0] Q4;
output reg [15:0] Q5;
output reg [15:0] Q6;
output reg [15:0] Q7;
output reg [15:0] Q8;
output reg [15:0] Q9;
output reg [15:0] Q10;
output reg [15:0] Q11;
output reg [15:0] Q12;
output reg [15:0] Q13;
output reg [15:0] Q14;
output reg [15:0] Q15;
output reg [15:0] Q16;
output reg [15:0] Q17;
output reg [15:0] Q18;
output reg [15:0] Q19;
output reg [15:0] Q20;
output reg [15:0] Q21;
output reg [15:0] Q22;
output reg [15:0] Q23;
output reg [15:0] Q24;
output reg [15:0] Q25;
output reg [15:0] Q26;
output reg [15:0] Q27;
output reg [15:0] Q28;
output reg [15:0] Q29;
output reg [15:0] Q30;
output reg [15:0] Q31;


// 18x18 Multiplier elements
// NEURON 0
mul18x18 M0_00(.dataa(D0),
				   .datab(W0),
				   .result(T0));
mul18x18 M0_01(.dataa(D1),
				   .datab(W1),
				   .result(T1));
mul18x18 M0_02(.dataa(D2),
				   .datab(W2),
				   .result(T2));				
mul18x18 M0_03(.dataa(D3),
				   .datab(W3),
				   .result(T3));		
mul18x18 M0_04(.dataa(D4),
				   .datab(W4),
				   .result(T4));
mul18x18 M0_05(.dataa(D5),
				   .datab(W5),
				   .result(T5));
mul18x18 M0_06(.dataa(D6),
				   .datab(W6),
				   .result(T6));				
mul18x18 M0_07(.dataa(D7),
				   .datab(W7),
				   .result(T7));	
mul18x18 M0_08(.dataa(D8),
				   .datab(W8),
				   .result(T8));
mul18x18 M0_09(.dataa(D9),
				   .datab(W9),
				   .result(T9));
mul18x18 M0_10(.dataa(D10),
				   .datab(W10),
				   .result(T10));				
mul18x18 M0_11(.dataa(D11),
				   .datab(W11),
				   .result(T11));	
mul18x18 M0_12(.dataa(D12),
				   .datab(W12),
				   .result(T12));
mul18x18 M0_13(.dataa(D13),
				   .datab(W13),
				   .result(T13));
mul18x18 M0_14(.dataa(D14),
				   .datab(W14),
				   .result(T14));				
mul18x18 M0_15(.dataa(D15),
				   .datab(W15),
				   .result(T15));	

// NEURON 1
mul18x18 M1_00(.dataa(D0),
				   .datab(W16),
				   .result(T16));
mul18x18 M1_01(.dataa(D1),
				   .datab(W17),
				   .result(T17));
mul18x18 M1_02(.dataa(D2),
				   .datab(W18),
				   .result(T18));				
mul18x18 M1_03(.dataa(D3),
				   .datab(W19),
				   .result(T19));		
mul18x18 M1_04(.dataa(D4),
				   .datab(W20),
				   .result(T20));
mul18x18 M1_05(.dataa(D5),
				   .datab(W21),
				   .result(T21));
mul18x18 M1_06(.dataa(D6),
				   .datab(W22),
				   .result(T22));				
mul18x18 M1_07(.dataa(D7),
				   .datab(W23),
				   .result(T23));	
mul18x18 M1_08(.dataa(D8),
				   .datab(W24),
				   .result(T24));
mul18x18 M1_09(.dataa(D9),
				   .datab(W25),
				   .result(T25));
mul18x18 M1_10(.dataa(D10),
				   .datab(W26),
				   .result(T26));				
mul18x18 M1_11(.dataa(D11),
				   .datab(W27),
				   .result(T27));	
mul18x18 M1_12(.dataa(D12),
				   .datab(W28),
				   .result(T28));
mul18x18 M1_13(.dataa(D13),
				   .datab(W29),
				   .result(T29));
mul18x18 M1_14(.dataa(D14),
				   .datab(W30),
				   .result(T30));				
mul18x18 M1_15(.dataa(D15),
				   .datab(W31),
				   .result(T31));				
				
// NEURON 2
mul18x18 M2_00(.dataa(D0),
				   .datab(W32),
				   .result(T32));
mul18x18 M2_01(.dataa(D1),
				   .datab(W33),
				   .result(T33));
mul18x18 M2_02(.dataa(D2),
				   .datab(W34),
				   .result(T34));				
mul18x18 M2_03(.dataa(D3),
				   .datab(W35),
				   .result(T35));		
mul18x18 M2_04(.dataa(D4),
				   .datab(W36),
				   .result(T36));
mul18x18 M2_05(.dataa(D5),
				   .datab(W37),
				   .result(T37));
mul18x18 M2_06(.dataa(D6),
				   .datab(W38),
				   .result(T38));				
mul18x18 M2_07(.dataa(D7),
				   .datab(W39),
				   .result(T39));	
mul18x18 M2_08(.dataa(D8),
				   .datab(W40),
				   .result(T40));
mul18x18 M2_09(.dataa(D9),
				   .datab(W41),
				   .result(T41));
mul18x18 M2_10(.dataa(D10),
				   .datab(W42),
				   .result(T42));				
mul18x18 M2_11(.dataa(D11),
				   .datab(W43),
				   .result(T43));	
mul18x18 M2_12(.dataa(D12),
				   .datab(W44),
				   .result(T44));
mul18x18 M2_13(.dataa(D13),
				   .datab(W45),
				   .result(T45));
mul18x18 M2_14(.dataa(D14),
				   .datab(W46),
				   .result(T46));				
mul18x18 M2_15(.dataa(D15),
				   .datab(W47),
				   .result(T47));			
	
// NEURON 3
mul18x18 M3_00(.dataa(D0),
				   .datab(W48),
				   .result(T48));
mul18x18 M3_01(.dataa(D1),
				   .datab(W49),
				   .result(T49));
mul18x18 M3_02(.dataa(D2),
				   .datab(W50),
				   .result(T50));				
mul18x18 M3_03(.dataa(D3),
				   .datab(W51),
				   .result(T51));		
mul18x18 M3_04(.dataa(D4),
				   .datab(W52),
				   .result(T52));
mul18x18 M3_05(.dataa(D5),
				   .datab(W53),
				   .result(T53));
mul18x18 M3_06(.dataa(D6),
				   .datab(W54),
				   .result(T54));				
mul18x18 M3_07(.dataa(D7),
				   .datab(W55),
				   .result(T55));	
mul18x18 M3_08(.dataa(D8),
				   .datab(W56),
				   .result(T56));
mul18x18 M3_09(.dataa(D9),
				   .datab(W57),
				   .result(T57));
mul18x18 M3_10(.dataa(D10),
				   .datab(W58),
				   .result(T58));				
mul18x18 M3_11(.dataa(D11),
				   .datab(W59),
				   .result(T59));	
mul18x18 M3_12(.dataa(D12),
				   .datab(W60),
				   .result(T60));
mul18x18 M3_13(.dataa(D13),
				   .datab(W61),
				   .result(T61));
mul18x18 M3_14(.dataa(D14),
				   .datab(W62),
				   .result(T62));				
mul18x18 M3_15(.dataa(D15),
				   .datab(W63),
				   .result(T63));
		
// 2 to 1 32x32 adder elements
// First addition layer
// NEURON 0
add32x32 A0_0(.dataa(T0),
					.datab(T1),
					.result(S0));
add32x32 A0_1(.dataa(T2),
					.datab(T3),
					.result(S1));					
add32x32 A0_2(.dataa(T4),
					.datab(T5),
					.result(S2));
add32x32 A0_3(.dataa(T6),
					.datab(T7),
					.result(S3));
add32x32 A0_4(.dataa(T8),
					.datab(T9),
					.result(S4));
add32x32 A0_5(.dataa(T10),
					.datab(T11),
					.result(S5));					
add32x32 A0_6(.dataa(T12),
					.datab(T13),
					.result(S6));
add32x32 A0_7(.dataa(T14),
					.datab(T15),
					.result(S7));		

// NEURON 1
add32x32 A1_0(.dataa(T16),
					.datab(T17),
					.result(S8));
add32x32 A1_1(.dataa(T18),
					.datab(T19),
					.result(S9));					
add32x32 A1_2(.dataa(T20),
					.datab(T21),
					.result(S10));
add32x32 A1_3(.dataa(T22),
					.datab(T23),
					.result(S11));
add32x32 A1_4(.dataa(T25),
					.datab(T26),
					.result(S12));
add32x32 A1_5(.dataa(T26),
					.datab(T27),
					.result(S13));					
add32x32 A1_6(.dataa(T28),
					.datab(T29),
					.result(S14));
add32x32 A1_7(.dataa(T30),
					.datab(T31),
					.result(S15));		

// NEURON 2
add32x32 A2_0(.dataa(T32),
					.datab(T33),
					.result(S16));
add32x32 A2_1(.dataa(T34),
					.datab(T35),
					.result(S17));					
add32x32 A2_2(.dataa(T36),
					.datab(T37),
					.result(S18));
add32x32 A2_3(.dataa(T38),
					.datab(T39),
					.result(S19));
add32x32 A2_4(.dataa(T40),
					.datab(T41),
					.result(S20));
add32x32 A2_5(.dataa(T42),
					.datab(T43),
					.result(S21));					
add32x32 A2_6(.dataa(T44),
					.datab(T45),
					.result(S22));
add32x32 A2_7(.dataa(T46),
					.datab(T47),
					.result(S23));		
	
// NEURON 3
add32x32 A3_0(.dataa(T48),
					.datab(T49),
					.result(S24));
add32x32 A3_1(.dataa(T50),
					.datab(T51),
					.result(S25));					
add32x32 A3_2(.dataa(T52),
					.datab(T53),
					.result(S26));
add32x32 A3_3(.dataa(T54),
					.datab(T55),
					.result(S27));
add32x32 A3_4(.dataa(T56),
					.datab(T57),
					.result(S28));
add32x32 A3_5(.dataa(T58),
					.datab(T59),
					.result(S29));					
add32x32 A3_6(.dataa(T60),
					.datab(T61),
					.result(S30));
add32x32 A3_7(.dataa(T62),
					.datab(T63),
					.result(S31));	
				
// 8 TO 1 32X32 ADDER ELEMENTS X4
// SECOND ADDITION LAYer

// NEURON 0
padd32x32 PA0(.data0x(S0[32:1]),
					.data1x(S1[32:1]),
					.data2x(S2[32:1]),
					.data3x(S3[32:1]),
					.data4x(S4[32:1]),
					.data5x(S5[32:1]),
					.data6x(S6[32:1]),
					.data7x(S7[32:1]),
					.result(P0));	

// NEURON 1
padd32x32 PA1(.data0x(S8[32:1]),
					.data1x(S9[32:1]),
					.data2x(S10[32:1]),
					.data3x(S11[32:1]),
					.data4x(S12[32:1]),
					.data5x(S13[32:1]),
					.data6x(S14[32:1]),
					.data7x(S15[32:1]),
					.result(P1));	

// NEURON 2
padd32x32 PA2(.data0x(S16[32:1]),
					.data1x(S17[32:1]),
					.data2x(S18[32:1]),
					.data3x(S19[32:1]),
					.data4x(S20[32:1]),
					.data5x(S21[32:1]),
					.data6x(S22[32:1]),
					.data7x(S23[32:1]),
					.result(P2));	

// NEURON 3
padd32x32 PA3(.data0x(S24[32:1]),
					.data1x(S25[32:1]),
					.data2x(S26[32:1]),
					.data3x(S27[32:1]),
					.data4x(S28[32:1]),
					.data5x(S29[32:1]),
					.data6x(S30[32:1]),
					.data7x(S31[32:1]),
					.result(P3));						
					

// TRANSFER FUNCTION LUT BLOCK
tf_block TF0(.clk(clk),
				 .mode(mode),
				 .I0(P0[34:19]),
				 .I1(P1[34:19]),
				 .I2(P2[34:19]),
				 .I3(P3[34:19]),
				 .Q0(L0),
				 .Q1(L1),
				 .Q2(L2),
				 .Q3(L3));
				 
				 
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
