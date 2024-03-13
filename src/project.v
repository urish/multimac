/*
 * Copyright (c) 2024 Jonny Edwards
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_fountaincoder_top (
    input  wire       clk,      // clock
    input  wire       ena,      // will go high when the design is enabled
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       rst_n     // reset_n - low to reset
);

// All output pins must be assigned. If not used, assign to 0.
assign uio_out[3:0] = 4'b0;
/* verilator lint_off UNUSED */
wire [3:0] dummy1 = uio_in[7:4];
wire dummy2 = ena;
assign uio_oe       = 8'b11110000;
//assign all the loose ports
wire [7:0] out;
wire [3:0] out_top;
assign uo_out = out;
assign uio_out[7:4] = out_top;
DMADD madd(
        .clk    (clk),
        .run    (uio_in[3]),
        .load   (uio_in[2]),
        .insn   (uio_in[1:0]),
        .index  (ui_in[7:4]),
        .data   (ui_in[3:0]),
        .out    (out),
        .out_top (out_top), 
        .rst_n  (rst_n)
);

endmodule

