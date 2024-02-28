/*
 * Copyright (c) 2024 Jonny Edwards
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_fountaincoder_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

DMADD madd(
	  	.clk    (clk),
	  	.ena 	(ena),
	  	.run    (ui_in[3]),
	  	.load   (ui_in[2]),
	  	.insn   (ui_in[1:0]),
		.index  (uio_in[7:4]),
		.data   (uio_in[3:0]),
		.out    (uo_out),
		.out_i  (uo_out2),
		.rst_n  (rst_n)

);

endmodule
