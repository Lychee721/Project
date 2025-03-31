`timescale 1ns/1ps


module tb_Hazard_Forward;
 
    
	 logic hazard_id_ex_memRead;
    logic [4:0] hazard_id_ex_rd_idx;
    logic [4:0] hazard_if_id_rs1_idx, hazard_if_id_rs2_idx;
    
	 logic hazard_stall;

   
    HazardUnit hazard_inst(
        
		  .id_ex_memRead(hazard_id_ex_memRead),
        .id_ex_rd_idx(hazard_id_ex_rd_idx),
        .if_id_rs1_idx(hazard_if_id_rs1_idx),
        .if_id_rs2_idx(hazard_if_id_rs2_idx),
        .stall(hazard_stall)
    );

    
    logic [4:0] forward_ex_rs1_idx, forward_ex_rs2_idx;
    logic forward_ex_mem_regWrite;
    logic [4:0] forward_ex_mem_rd_idx;
    logic forward_mem_wb_regWrite;
    logic [4:0] forward_mem_wb_rd_idx;
    logic [1:0] forwardA, forwardB;

  
    ForwardUnit forward_inst(
        .ex_rs1_idx(forward_ex_rs1_idx),
        .ex_rs2_idx(forward_ex_rs2_idx),
        .ex_mem_regWrite(forward_ex_mem_regWrite),
        .ex_mem_rd_idx(forward_ex_mem_rd_idx),
        .mem_wb_regWrite(forward_mem_wb_regWrite),
        .mem_wb_rd_idx(forward_mem_wb_rd_idx),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

	 
	 
	 
	 
	 
    initial begin
        // HazardUnit测试
        // Case 1: 无冒险
        hazard_id_ex_memRead = 1'b0;
        hazard_id_ex_rd_idx = 5'd5;
        hazard_if_id_rs1_idx = 5'd3;
        hazard_if_id_rs2_idx = 5'd4;
        #10;
        $display("Hazard Test 1: stall = %b (expected 0)", hazard_stall);
        
        // Case 2: 存在冒险（Load指令） -> stall 应为1
        hazard_id_ex_memRead = 1'b1;
        hazard_id_ex_rd_idx = 5'd3;
        hazard_if_id_rs1_idx = 5'd3;
        hazard_if_id_rs2_idx = 5'd4;
        #10;
        $display("Hazard Test 2: stall = %b (expected 1)", hazard_stall);
        
        // ForwardUnit测试
        // Case 1: 无前递（无匹配）
        forward_ex_rs1_idx = 5'd2;
        forward_ex_rs2_idx = 5'd3;
        forward_ex_mem_regWrite = 1'b0;
        forward_ex_mem_rd_idx = 5'd0;
        forward_mem_wb_regWrite = 1'b0;
        forward_mem_wb_rd_idx = 5'd0;
        #10;
        $display("Forward Test 1: forwardA = %b, forwardB = %b (expected 00,00)", forwardA, forwardB);
        
        // Case 2: EX/MEM前递（匹配rs1）
        forward_ex_rs1_idx = 5'd7;
        forward_ex_rs2_idx = 5'd3;
        forward_ex_mem_regWrite = 1'b1;
        forward_ex_mem_rd_idx = 5'd7;
        forward_mem_wb_regWrite = 1'b0;
        forward_mem_wb_rd_idx = 5'd0;
        #10;
        $display("Forward Test 2: forwardA = %b (expected 10)", forwardA);
        
        // Case 3: MEM/WB前递（匹配rs2）
        forward_ex_rs1_idx = 5'd2;
        forward_ex_rs2_idx = 5'd8;
        forward_ex_mem_regWrite = 1'b0;
        forward_ex_mem_rd_idx = 5'd0;
        forward_mem_wb_regWrite = 1'b1;
        forward_mem_wb_rd_idx = 5'd8;
        #10;
        $display("Forward Test 3: forwardB = %b (expected 01)", forwardB);
        
        
		  
		  $finish;
    end

    initial begin
        
		  $dumpfile("tb_Hazard_Forward.vcd");
        $dumpvars(0, tb_Hazard_Forward);
    
	 end

endmodule
