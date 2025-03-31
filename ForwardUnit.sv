`timescale 1ns/1ps

//不用等待数据通过寄存器写回后再取出

module ForwardUnit(
    // EX阶段当前指令(rs1, rs2)
    input  logic [4:0] ex_rs1_idx,
    input  logic [4:0] ex_rs2_idx,

    // EX/MEM流水寄存器信息
    input  logic       ex_mem_regWrite,
    input  logic [4:0] ex_mem_rd_idx,

    // MEM/WB流水寄存器信息
    input  logic       mem_wb_regWrite,
    input  logic [4:0] mem_wb_rd_idx,

   
    // 00 => no forward, 
    // 10 => forward from EX/MEM,
    // 01 => forward from MEM/WB
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

    always_comb begin
        
        forwardA = 2'b00;
        forwardB = 2'b00;

        //  EX/MEM
        if(ex_mem_regWrite && (ex_mem_rd_idx != 5'd0) && (ex_mem_rd_idx == ex_rs1_idx))
            forwardA = 2'b10;
        if(ex_mem_regWrite && (ex_mem_rd_idx != 5'd0) && (ex_mem_rd_idx == ex_rs2_idx))
            forwardB = 2'b10;

        // MEM/WB
        if(mem_wb_regWrite && (mem_wb_rd_idx != 5'd0) && (mem_wb_rd_idx == ex_rs1_idx))
            forwardA = 2'b01;
        if(mem_wb_regWrite && (mem_wb_rd_idx != 5'd0) && (mem_wb_rd_idx == ex_rs2_idx))
            forwardB = 2'b01;
    end

endmodule
