module tf_block(clk, mode,
					 I0, I1, I2, I3,
					 Q0, Q1, Q2, Q3);
					 
input [15:0] I0;
input [15:0] I1;
input [15:0] I2;
input [15:0] I3;
input clk;
input [1:0] mode;

output reg [15:0] Q0;
output reg [15:0] Q1;
output reg [15:0] Q2;
output reg [15:0] Q3;

always @(posedge clk) begin
	Q0 <= I0;
	Q1 <= I1;
	Q2 <= I2;
	Q3 <= I3;
end


endmodule

