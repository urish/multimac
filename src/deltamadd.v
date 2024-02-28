module DMADD
#()
(
	//input wire load,run,[1:0] insn,  //[min,max,madd,madd_approx]
  // Port list
	input wire [3:0]  index,
	input wire [3:0]  data,
	input wire [1:0]  insn,
	input wire load,
    input wire run,
	input wire clk,
    input wire ena,      // will go high when the design is enabled
    input wire rst_n,     // reset_n - low to reset
	output [15:0] out,
	output [3:0] out_i
 	
);
	reg [3:0] j;  	
	reg [3:0] i = 0;
	reg [3:0] i_e = 4'b1111;  	
	reg [3:0] i_n;
	reg signed [3:0] i_d;
	
	reg signed [5:0] mem[15:0];
	 
	initial begin
		for (j = 0; j < 15; j = j +1) begin
	    	mem[j] = 6'b0; // initialize all elements to zero
	  	end
	end
	
	reg [5:0] mem_up;
	reg [5:0] mem_down;
	reg hit  = 0;
	reg halt = 0;

	reg signed [5:0] delta;
	reg signed [5:0] delta_n;
	reg [9:0] count;
	reg [9:0] count_n;	
	reg [12:0] total;
	reg [12:0] total_n;
		
	always @(posedge clk) begin
	  	casez ({ena,run,load,insn,hit,halt})

     		//Initialise
     		7'b1_0_0_00_0_0: {i,i_e,i_d} = {4'b0,4'b1111,4'b1}; 	//MIN
     		7'b1_0_0_01_0_0, 							//MAX										
     		7'b1_0_0_10_0_0,							//MADD
     		7'b1_0_0_11_0_0: {i,i_e,i_d} = {4'b1111,4'b0,-4'b1}; //AMADD
     		
	  		//LOAD DATA
     		7'b1_0_1_00_0_0,										//MIN
     		7'b1_0_1_01_0_0 : mem[index] = 6'b1;					//MAX														 	
     		7'b1_0_1_10_0_0,								//MADD
     		7'b1_0_1_11_0_0: {mem[index+1], mem[index]} = {mem_up, mem_down} ; //AMADD
  
     		//UPDATE and HALT
     		7'b1_1_0_00_0_0, 			//MIN
     		7'b1_1_0_01_0_0: i = i_n;	//MAX														 	
     		7'b1_1_0_00_1_0,			//MIN
     		7'b1_1_0_01_1_0: halt = 1; 	//MAX	
     		7'b1_1_0_10_?_0,			//MADD
     		7'b1_1_0_11_?_0: {i,delta,count,total} = {i_n,delta_n,count_n,total_n} ; //AMADD
     		
			default: halt = 1;
         endcase
	end
	
	assign mem_up   = mem[index + 1] + {2'b00,data};
	assign mem_down = mem[index] - {2'b00,data};
	assign i_n      = i  + i_d;
	assign hit      = mem[i] != 6'b0;
	assign halt     = i == i_e; 
	assign out_i    = i;

	assign delta_n = delta + mem[i];
	assign count_n = count + {3'b000,delta};
	assign total_n = total + {3'b000,count};
	assign out     = {3'b000,total} + {6'b000000,count};


endmodule





