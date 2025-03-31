`timescale 1ns/1ps

module RegisterFile(
    input  logic         clk,
    input  logic         reset,    
    input  logic [4:0]   rs1_idx,
    input  logic [4:0]   rs2_idx,
    output logic [31:0]  rs1_data,
    output logic [31:0]  rs2_data,
    input  logic         we,       
    input  logic [4:0]   rd_idx,   
    input  logic [31:0]  rd_data   
);

    
    reg [31:0] regs [0:31];
    
	 integer i;
    
    
    always_ff @(posedge clk or posedge reset) begin
        
		  
		  if (reset) begin
            
            for(i = 0; i < 32; i = i + 1)
                
					 regs[i] <= 32'd0;
        
		  end else begin
            
				if (we && (rd_idx != 5'd0))
                regs[rd_idx] <= rd_data;
          
            regs[0] <= 32'd0;
        
		  end
    end

    
    always_comb begin
        
		  
		  if (rs1_idx == 5'd0)
            
				rs1_data = 32'd0;
        else
            
				rs1_data = regs[rs1_idx]; //Read

        if (rs2_idx == 5'd0)
            
				rs2_data = 32'd0;
        
		  else
            
				rs2_data = regs[rs2_idx];
    
	 end

endmodule
