
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

	reg [3:0] i = 0;
	reg [3:0] j = 0;
	reg [3:0] i_e = 4'b1111;  	
	reg signed [3:0] i_d= 1;
	reg signed [5:0] mem[15:0];
	 
	reg hit=0;
	reg halt = 0;
	reg signed [5:0] delta;
	reg [7:0] count = 8'b0;
	reg [9:0] total = 10'b0;
	
	always @(posedge clk) begin
	  	casez ({rst_n,run,load,insn,hit,halt})

			//Reset
     		7'b0_?_?_??_?_?: begin {i,i_e,halt,count,total,hit} <= {4'b0,4'b1111,1'b0,8'b0,10'b0,1'b0};
     								for (j = 0 ; j <15 ; j = j + 1) begin mem[j] <= 6'b0; end end

     		//Initialise
     		7'b1_0_0_00_0_0: {i,i_e}          <= {4'b0,4'b1111}; 		//MIN
     		7'b1_0_0_01_0_0, 											//MAX										
     		7'b1_0_0_10_0_0: {i,i_e,i_d}      <= {4'b1111,4'b0,-4'b1};	//MADD
     		
	  		//Load Data
     		7'b1_0_1_00_0_0,										//MIN
     		7'b1_0_1_01_0_0: mem[index] <= 6'b1;					//MAX														 	
     		7'b1_0_1_10_0_0: {mem[index], mem[index-1]} <= {mem[index] + {2'b0,data}, mem[index-1] - {2'b0,data}} ; //MADD
  
     		//Update and Halt
     		7'b1_1_0_00_0_0, 				//MIN
     		7'b1_1_0_01_0_0: i <= i + 1;	//MAX														 	
     		7'b1_1_0_00_1_0,				//MIN
     		7'b1_1_0_01_1_0: {halt,i} <= {1'b1,i - 1'b1}; 	//MAX	
     		7'b1_1_0_10_?_0: {i,delta,count,total} <= {i  + i_d, delta + mem[i], count+{2'b0,delta}, total + {2'b0,count}} ; //MADD
			default: halt <= 1;
         endcase

		if (i == i_e) begin
			halt <= 1;
		end

		if (mem[i] != 6'b0) begin
			hit <= 1;
		end
		$display("r %d run %d load %d isn %d hit %d halt %d i %d out %d",  rst_n,run,load,insn,hit,halt, i,out );
		//$display("index %d data %d", index,data,mem[index]);
		// for (j = 0 ; j <15 ; j = j + 1) begin $display("%d", mem[j]); end
		// 
	end
	 
	assign out      = insn[1]  ? {2'b0,total} + {4'b0,count} : {8'b0,i} ;

endmodule





