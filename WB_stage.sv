`timescale 1ns/1ps

module WB_stage(
    
	 
	 input  logic [31:0] alu_result, // EX阶段运算结果
    input  logic [31:0] mem_data,   // MEM
    input  logic        mem_read,   // Load
    
	 output logic [31:0] wb_data    
);

    always_comb begin
        
		  if (mem_read)
            
				wb_data = mem_data;
        
		  else
            
				wb_data = alu_result;
    
	 end
endmodule
