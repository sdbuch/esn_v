`timescale 1ns/1ps

module mem_demo(clk, ce, sclr, Q);

input clk, ce, sclr;
output [15:0] Q;
wire actr_sclr;
wire clk_div;
wire [7:0] actr_Q;
wire [8:0] mem_addr;
wire [15:0] mem_Q;

clkdiv CLK32768 (.inclk0 (clk),
						.c0 (clk_div));

in_actr CTR ( .clk_en(ce),
					.clock(clk_div),
					.sclr(actr_sclr),
					.q(actr_Q)
					);
					
assign actr_sclr = ~sclr || actr_Q[6];		
assign mem_addr = {1'b0, actr_Q};	

in_mem MEM ( .address (mem_addr),
					.clock(clk_div),
					.rden(ce),
					.q(mem_Q)
					);
					
assign Q = mem_Q;

endmodule