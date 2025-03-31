`timescale 1ns/1ps

module tb_ALU;
    
    logic [31:0] operand_a, operand_b;
    logic [3:0]  alu_ctrl;
    logic        use_imm;
    logic [31:0] imm;
    logic [31:0] alu_result;

    
    EX_stage uut (
        
		  .rs1_val(operand_a),
        .rs2_val(operand_b),
        .use_imm(use_imm),
        .alu_ctrl(alu_ctrl),
        .imm(imm),
        .alu_result(alu_result)
		  
    );

    
	 initial begin
      
        operand_a = 32'd15;
        operand_b = 32'd10;
        use_imm = 1'b0;
        alu_ctrl = 4'd0; // ALU_ADD
        imm = 32'd0;
        #10;
        $display("Test ADD: %d + %d = %d", operand_a, operand_b, alu_result);
        
        
		  
		 
        operand_a = 32'd20;
        operand_b = 32'd5;
        alu_ctrl = 4'd1; // ALU_SUB
        #10;
        $display("Test SUB: %d - %d = %d", operand_a, operand_b, alu_result);
        
        
		  
		
        operand_a = -32'd5;
        operand_b = 32'd0;
        alu_ctrl = 4'h8; // ALU_RELU -8
        #10;
        $display("Test ReLU: input = %d, output = %d", operand_a, alu_result);
        
        
		  
		  
        operand_a = 32'h01020304; // each 8 bits number
        operand_b = 32'h05060708; 
        alu_ctrl = 4'h9; // ALU_MATMUL  -7
        #10;
        $display("Test MatMul: result = 0x%h", alu_result);
        
        
		 
        operand_a = {16'd100, 16'd200}; // each 16 bits
        operand_b = {16'd300, 16'd400};
        alu_ctrl = 4'ha; // ALU_VECADD -6
        #10;
        $display("Test VecAdd: High=%d, Low=%d", alu_result[31:16], alu_result[15:0]);
        
        
		  
		 
        // 4 signed 8 bit value，
        operand_a = 32'h102005F0;  // 16 32 6 -16
        alu_ctrl = 4'hb; // ALU_MPOOL -5
        #10;
        $display("Test MPOOL: result = 0x%h", alu_result);
        
        $finish;
    end

    
	 initial begin
        
		  $dumpfile("tb_ALU.vcd");
        $dumpvars(0, tb_ALU);
    
	 end
endmodule
