`timescale 1ns/1ps





module MEM_stage(
    input  logic        clk,
    input  logic        reset,       
    input  logic [31:0] addr,        
    input  logic [31:0] store_data,  
    input  logic        mem_read,    // Load
    input  logic        mem_write,   // Store
    output logic [31:0] mem_out      
);

  
    reg [31:0] data_mem [0:255];
    integer j;

   
    wire [7:0] index = addr[9:2];

    
    always_ff @(posedge clk or posedge reset) begin
        
		  
		  
		  if (reset) begin
            
            for(j = 0; j < 256; j = j + 1)
                
					 data_mem[j] <= 32'd0;
            
				mem_out <= 32'd0;
        
		  end else begin
            
            if (mem_write)
                
					 data_mem[index] <= store_data;
           
            if (mem_read)
                
					 mem_out <= data_mem[index];
            
				else
                
					 mem_out <= 32'd0;
        end
    end

endmodule
