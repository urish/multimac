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
    output [7:0] out,
    output [3:0] out_top
    
);

 	reg [3:0] j; //j=0 ;
	reg [3:0] i; // i = 4'b1111;
	reg signed [3:0] i_d;//= -1;
	reg [3:0] i_e;// = 4'b0;   
		
	reg signed [5:0] mem[15:0];
	reg bad_pattern;// = 0;
	reg signed [5:0] delta;// =6'b0;
	reg [7:0] count;// = 8'b0;
	reg [9:0] total;// = 10'b0;
	reg [11:0] out_reg;//  = 0;
	reg set; // = 0;
	always @(posedge clk) begin
	  	casez ({rst_n, run,load,insn})
			
			//Reset
     		5'b0_?_?_??: begin out_reg<=0; set<=0; i<= 4'b1111; i_d<=-3'b1; i_e<=4'b0; delta<=6'b0; count<=8'b0;total<=10'b0; bad_pattern=0; for (j=0;j<15;j=j+1) begin mem[j]<=0; end end
     		 
     		//Initialise
     		5'b1_0_0_00: begin i<= 4'b0; i_d<= 4'b1; i_e <= 4'b1111; end  	// Initialise MIN
     		5'b1_0_0_01: begin i<= 4'b1111; i_d<= -3'b1; i_e <= 4'b0; end 	// Initialise MAX
     		5'b1_0_1_00,
     		5'b1_0_1_01: mem[index]  <= 6'b1;					// Load Data MIN
     		5'b1_0_1_10: {mem[index], mem[index-1]} <= {mem[index] + {2'b0,data}, mem[index-1] - {2'b0,data}} ; //MADD
     		5'b1_1_0_00,
     		5'b1_1_0_01: i <= i + i_d;				// Run MIN
     		5'b1_1_0_10: begin i <=i  + i_d; delta <= delta + mem[i-1]; count <= count+{2'b0,delta}; total <=  total + {2'b0,count}; end //MADD

			default: bad_pattern <= 1;
  													 	
		endcase

		if (i == i_e && insn[1]==1) begin
			out_reg <= {2'b0,total} + {4'b0,count};
			i_d <= 0 ;
		end

		 if ((mem[i] != 6'b0) && !set && insn[1]!=1) begin
		  	out_reg <= {8'b0,i};
		  	i_d <= 0;
			set <= 1;
		 end 

		 	
	$display("%d r %d run %d load %d isn %d bad %d i_d %d i_e %d index %d data %d out_reg %d", i ,rst_n, run, load,insn, bad_pattern,i_d,i_e, index, data,out);
	$display("d %d c %d t %d m %d",delta,count,total,mem[i]);
	end
		assign out = out_reg[7:0];
		assign out_top = out_reg[11:8];
		
endmodule





