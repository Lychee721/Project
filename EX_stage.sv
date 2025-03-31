`timescale 1ns/1ps

module EX_stage(
    input  logic [31:0] rs1_val,      
    input  logic [31:0] rs2_val,      
    input  logic        use_imm,      
    input  logic [3:0]  alu_ctrl,     
    input  logic [31:0] imm,         
    output logic [31:0] alu_result    
);

    // Select op
    logic [31:0] opA, opB;
    assign opA = rs1_val;
    assign opB = (use_imm) ? imm : rs2_val;

    
    localparam ALU_ADD    = 4'd0,
               ALU_SUB    = 4'd1,
               ALU_AND    = 4'd2,
               ALU_OR     = 4'd3,
               ALU_XOR    = 4'd4,
               ALU_RELU   = 4'h8,
               ALU_MATMUL = 4'h9,
               ALU_VECADD = 4'ha,
               ALU_MPOOL  = 4'hb;

    
	 
	 
    always_comb begin
        
        //  MatMul 
        byte unsigned a00, a01, a10, a11;
        byte unsigned b00, b01, b10, b11;
        logic [15:0] p00, p01, p10, p11;
        // MPOOL 
        byte signed v00, v01, v10, v11;
        byte signed maxv;

        case (alu_ctrl)
            
				
				ALU_ADD:    alu_result = opA + opB;
            ALU_SUB:    alu_result = opA - opB;
            ALU_AND:    alu_result = opA & opB;
            ALU_OR:     alu_result = opA | opB;
            ALU_XOR:    alu_result = opA ^ opB;
            
				
				
				ALU_RELU: begin
                
					 if ($signed(opA) < 0)
                    alu_result = 32'd0;
                
					 else
                    alu_result = opA;
            end
            
				ALU_MATMUL: begin
                
					 {a11, a10, a01, a00} = opA;
                {b11, b10, b01, b00} = opB;
                p00 = a00 * b00 + a01 * b10;
                p01 = a00 * b01 + a01 * b11;
                p10 = a10 * b00 + a11 * b10;
                p11 = a10 * b01 + a11 * b11;
                alu_result = {p11[7:0], p10[7:0], p01[7:0], p00[7:0]};
            end
            
				ALU_VECADD: begin
                
					 logic [15:0] A0, A1, B0, B1;
                {A1, A0} = opA;
                {B1, B0} = opB;
                alu_result[15:0]  = A0 + B0;
                alu_result[31:16] = A1 + B1;
            end
            
				ALU_MPOOL: begin
                
					 {v11, v10, v01, v00} = opA;
                maxv = v00;
                if (v01 > maxv) maxv = v01;
                if (v10 > maxv) maxv = v10;
                if (v11 > maxv) maxv = v11;
                if (maxv < 0)
                    alu_result = 32'd0;
                else
                    alu_result = {24'd0, maxv};
            end
            
				default:    alu_result = 32'd0;
        
		  endcase
    end

endmodule
