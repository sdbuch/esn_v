// megafunction wizard: %PARALLEL_ADD%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: parallel_add 

// ============================================================
// File Name: padd_8x38signed_to_1x41signed.v
// Megafunction Name(s):
// 			parallel_add
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.1.0 Build 162 10/23/2013 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module padd_8x38signed_to_1x41signed (
	data0x,
	data1x,
	data2x,
	data3x,
	data4x,
	data5x,
	data6x,
	data7x,
	result);

	input	[37:0]  data0x;
	input	[37:0]  data1x;
	input	[37:0]  data2x;
	input	[37:0]  data3x;
	input	[37:0]  data4x;
	input	[37:0]  data5x;
	input	[37:0]  data6x;
	input	[37:0]  data7x;
	output	[40:0]  result;

	wire [40:0] sub_wire0;
	wire [37:0] sub_wire9 = data7x[37:0];
	wire [37:0] sub_wire8 = data6x[37:0];
	wire [37:0] sub_wire7 = data5x[37:0];
	wire [37:0] sub_wire6 = data4x[37:0];
	wire [37:0] sub_wire5 = data3x[37:0];
	wire [37:0] sub_wire4 = data2x[37:0];
	wire [37:0] sub_wire3 = data1x[37:0];
	wire [40:0] result = sub_wire0[40:0];
	wire [37:0] sub_wire1 = data0x[37:0];
	wire [303:0] sub_wire2 = {sub_wire9, sub_wire8, sub_wire7, sub_wire6, sub_wire5, sub_wire4, sub_wire3, sub_wire1};

	parallel_add	parallel_add_component (
				.data (sub_wire2),
				.result (sub_wire0)
				// synopsys translate_off
				,
				.aclr (),
				.clken (),
				.clock ()
				// synopsys translate_on
				);
	defparam
		parallel_add_component.msw_subtract = "NO",
		parallel_add_component.pipeline = 0,
		parallel_add_component.representation = "SIGNED",
		parallel_add_component.result_alignment = "LSB",
		parallel_add_component.shift = 0,
		parallel_add_component.size = 8,
		parallel_add_component.width = 38,
		parallel_add_component.widthr = 41;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: MSW_SUBTRACT STRING "NO"
// Retrieval info: CONSTANT: PIPELINE NUMERIC "0"
// Retrieval info: CONSTANT: REPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: RESULT_ALIGNMENT STRING "LSB"
// Retrieval info: CONSTANT: SHIFT NUMERIC "0"
// Retrieval info: CONSTANT: SIZE NUMERIC "8"
// Retrieval info: CONSTANT: WIDTH NUMERIC "38"
// Retrieval info: CONSTANT: WIDTHR NUMERIC "41"
// Retrieval info: USED_PORT: data0x 0 0 38 0 INPUT NODEFVAL "data0x[37..0]"
// Retrieval info: USED_PORT: data1x 0 0 38 0 INPUT NODEFVAL "data1x[37..0]"
// Retrieval info: USED_PORT: data2x 0 0 38 0 INPUT NODEFVAL "data2x[37..0]"
// Retrieval info: USED_PORT: data3x 0 0 38 0 INPUT NODEFVAL "data3x[37..0]"
// Retrieval info: USED_PORT: data4x 0 0 38 0 INPUT NODEFVAL "data4x[37..0]"
// Retrieval info: USED_PORT: data5x 0 0 38 0 INPUT NODEFVAL "data5x[37..0]"
// Retrieval info: USED_PORT: data6x 0 0 38 0 INPUT NODEFVAL "data6x[37..0]"
// Retrieval info: USED_PORT: data7x 0 0 38 0 INPUT NODEFVAL "data7x[37..0]"
// Retrieval info: USED_PORT: result 0 0 41 0 OUTPUT NODEFVAL "result[40..0]"
// Retrieval info: CONNECT: @data 0 0 38 0 data0x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 38 data1x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 76 data2x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 114 data3x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 152 data4x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 190 data5x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 228 data6x 0 0 38 0
// Retrieval info: CONNECT: @data 0 0 38 266 data7x 0 0 38 0
// Retrieval info: CONNECT: result 0 0 41 0 @result 0 0 41 0
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL padd_8x38signed_to_1x41signed_syn.v TRUE
// Retrieval info: LIB_FILE: altera_mf
