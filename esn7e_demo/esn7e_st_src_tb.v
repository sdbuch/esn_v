`timescale 1ns/1ns
module esn7e_st_src_tb;

reg clk;
reg reset_n;
wire data_valid;
wire [31:0] data_out;

esn7e_st_src U0 (
	.clk(clk),
	.reset_n(reset_n),
	.data_valid(data_valid),
	.data_out(data_out)
);

initial begin
	$dumpfile("esn7e_st_src_tb.vcd");
	$dumpvars(0,esn7e_st_src_tb.data_valid, esn7e_st_src_tb.data_out, esn7e_st_src_tb.U0.ESN0.W_out, esn7e_st_src_tb.U0.ESN0.XSTATE);
end

initial begin: INITS
	clk = 1'b0;
	reset_n = 1'b1;
	#8 reset_n = 1'b0;
	#11 reset_n = 1'b1;
end

always begin: CLOCK
	#1 clk = !clk;
end

endmodule
