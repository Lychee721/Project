
`timescale 1ns/1ps






module HazardUnit(
    
    input  logic       id_ex_memRead, // Whether the previous instruction is a load
    input  logic [4:0] id_ex_rd_idx,  // Destination register of the previous instruction

    
    input  logic [4:0] if_id_rs1_idx,
    input  logic [4:0] if_id_rs2_idx,

   
    output logic       stall // stall 1 
);

    always_comb begin
        
		  stall = 1'b0;

       
        if (id_ex_memRead && (id_ex_rd_idx != 5'd0) &&
           ((id_ex_rd_idx == if_id_rs1_idx)||(id_ex_rd_idx == if_id_rs2_idx))) begin
            
				stall = 1'b1;
        
		  end
    end

endmodule
