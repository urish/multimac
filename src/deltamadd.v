/*
 * Copyright (c) 2024 Jonny Edwards
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module DMADD(	
	input wire clk,
    input wire rst_n,     // reset_n - low to reset
	input wire [3:0]  index,
	input wire [3:0]  data,	
	input wire [1:0]  insn,
	input wire load,
    input wire run,
    output [11:0] out 	
);
 	reg [3:0] j=0 ;
	reg [3:0] i = 4'b1111;
	reg signed [3:0] i_d= -1;
	reg [3:0] i_e = 4'b0;   
		
	reg signed [5:0] mem[15:0];
	reg bad_pattern = 0;
	reg signed [5:0] delta;
	reg [7:0] count = 8'b0;
	reg [9:0] total = 10'b0;
	reg [11:0] out_reg;
	reg run_reg = 1; 
	always @(posedge clk) begin
	  	casez ({rst_n, run,load,insn})
			
			//Reset
     		5'b0_?_?_??: begin i<= 4'b1111; i_d<=-3'b1; i_e<=4'b0; run_reg = 1; for (j=0;j<15;j=j+1) begin mem[j]<=0; end end
     		 
     		//Initialise
     		5'b1_0_0_00: {i,i_d,i_e} <= {4'b0, 4'b1, 4'b1111};  	// Initialise MIN
     		5'b1_0_1_00: mem[index]  <= 6'b1;					// Load Data MIN
     		5'b1_1_0_00:           i <= i + i_d;				// Run MIN

			default: bad_pattern <= 1;
  
     		//7'b1_0_1_01: 					//MAX														 	
     		//Update and Halt
     		//7'b1_1_0_01: 	//MAX														 	
     		//7'b1_0_1_10: {mem[index], mem[index-1]} <= {mem[index] + {2'b0,data}, mem[index-1] - {2'b0,data}} ; //MADD
     		//7'b1_1_0_10: {i,delta,count,total} <= {i  + i_d, delta + mem[i], count+{2'b0,delta}, total + {2'b0,count}} ; //MADD
         endcase

		// if (i == i_e) begin
		//out_reg = {2'b0,total} + {4'b0,count};
		//	# rst_n_reg <= 0 ;
		//end

		if (mem[i] != 6'b0 ) begin
			out_reg <= {8'b0,i};
			i_d <= 0;
			 
		end  	
	$display("%d r %d run %d load %d isn %d bad %d i_d %d i_e %d index %d data %d out_reg %d", i ,rst_n, run, load,insn, bad_pattern,i_d,i_e, index, data,out_reg);
	
	end
		assign out = out_reg;
		assign rst_n = run_reg;
		
endmodule





