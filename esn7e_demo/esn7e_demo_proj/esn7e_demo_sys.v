module esn7e_demo_sys(clock_50, led, clock_1_locked_sync);

input clock_50;
output [7:0] led;
output reg clock_1_locked_sync;

wire clock_1_locked;
wire reset_while_not_locked;

assign reset_while_not_locked = clock_1_locked;

esn7e_demo_system U0 (
	.clk_clk(clock_50),
	.reset_reset_n(1'b1),
	.esn_rst_external_n_reset(!reset_while_not_locked),
	.altpll_esn_locked_export(clock_1_locked),
	.led_export(led)
);

always @(posedge clock_50) begin: PLL_LOCKED
	clock_1_locked_sync <= clock_1_locked;
end

endmodule
