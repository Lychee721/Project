`timescale 1ns/1ps

module PipelineCPU(
    input  logic clk,
    input  logic reset
);

    // ======================================================
    // 1. 信号统一声明（仅声明一次）
    // ======================================================
    // IF阶段及IF/ID流水寄存器信号
    logic [31:0] pc_if, instr_if;
    logic [31:0] pc_ifid, instr_ifid;
    logic         stall;
    logic         flush_ifid;
    logic         pc_sel;          // 1: 使用外部pc_in（分支/跳转目标）；0: 顺序执行
    logic [31:0]  pc_in;           // 分支/跳转目标地址

    // ID阶段信号
    logic [31:0] rs1_data, rs2_data;
    logic [4:0]  id_rs1_idx, id_rs2_idx, id_rd_idx;
    logic        id_reg_write, id_mem_read, id_mem_write, id_use_imm;
    logic [3:0]  id_alu_ctrl;
    logic [31:0] id_imm;
    logic        id_branch, id_jal;

    // ID/EX流水寄存器信号
    logic [31:0] id_ex_rs1_val, id_ex_rs2_val, id_ex_imm;
    logic [3:0]  id_ex_alu_ctrl;
    logic        id_ex_reg_write, id_ex_mem_read, id_ex_mem_write, id_ex_use_imm;
    logic        id_ex_branch, id_ex_jal;
    logic [4:0]  id_ex_rd_idx;
    // 将ID阶段的寄存器索引传递出去用于前递
    logic [4:0]  id_ex_rs1_idx, id_ex_rs2_idx;

    // EX阶段信号
    logic [31:0] ex_alu_result;

    // EX/MEM流水寄存器信号
    logic [31:0] ex_mem_alu_result;
    logic [31:0] ex_mem_rs2_val;
    logic        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
    logic [4:0]  ex_mem_rd_idx;

    // MEM阶段信号
    logic [31:0] mem_data_out;

    // MEM/WB流水寄存器信号
    logic [31:0] wb_data_in;  // 作为 MEM/WB模块的输入
    logic        mem_wb_reg_write;
    logic [4:0]  mem_wb_rd_idx;

    // WB阶段输出
    logic [31:0] wb_final_data;

    // Forwarding信号
    logic [1:0] forwardA, forwardB;

    // 分支/跳转处理信号
    logic        branch_taken;
    logic [31:0] branch_target;
    logic [31:0] jal_target;

    // ======================================================
    // 2. IF阶段及IF/ID流水寄存器实例
    // ======================================================
    IF_stage if_stage_u(
        .clk      (clk),
        .reset    (reset),
        .stall    (stall),
        .flush    (flush_ifid),
        .pc_sel   (pc_sel),
        .pc_in    (pc_in),
        .instr_out(instr_if),
        .pc_out   (pc_if)
    );

    pipeline_reg_IF_ID if_id_reg_u(
        .clk      (clk),
        .reset    (reset),
        .stall    (stall),
        .flush    (flush_ifid),
        .pc_in    (pc_if),
        .instr_in (instr_if),
        .pc_out   (pc_ifid),
        .instr_out(instr_ifid)
    );

    // ======================================================
    // 3. RegisterFile和ID阶段实例
    // ======================================================
    RegisterFile regfile_u(
        .clk      (clk),
        .reset    (reset),
        .rs1_idx  (id_rs1_idx),
        .rs2_idx  (id_rs2_idx),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .we       (mem_wb_reg_write),
        .rd_idx   (mem_wb_rd_idx),
        .rd_data  (wb_final_data)
    );

    ID_stage id_stage_u(
        .clk         (clk),
        .reset       (reset),
        .instr_in    (instr_ifid),
        .rs1_data    (rs1_data),
        .rs2_data    (rs2_data),
        .rs1_idx     (id_rs1_idx),
        .rs2_idx     (id_rs2_idx),
        .rd_idx      (id_rd_idx),
        .reg_write   (id_reg_write),
        .mem_read    (id_mem_read),
        .mem_write   (id_mem_write),
        .use_imm     (id_use_imm),
        .alu_ctrl    (id_alu_ctrl),
        .imm         (id_imm),
        .branch      (id_branch),
        .jal         (id_jal)
    );

    // ======================================================
    // 4. Hazard Detection和ID/EX流水寄存器实例
    // ======================================================
    HazardUnit hazard_u(
        .id_ex_memRead (id_mem_read),  // 简化处理：使用ID阶段的mem_read检测Load指令
        .id_ex_rd_idx  (id_rd_idx),
        .if_id_rs1_idx (id_rs1_idx),
        .if_id_rs2_idx (id_rs2_idx),
        .stall         (stall)
    );

    pipeline_reg_ID_EX id_ex_reg_u(
        .clk           (clk),
        .reset         (reset),
        .rs1_val_in    (rs1_data),
        .rs2_val_in    (rs2_data),
        .imm_in        (id_imm),
        .alu_ctrl_in   (id_alu_ctrl),
        .reg_write_in  (id_reg_write),
        .mem_read_in   (id_mem_read),
        .mem_write_in  (id_mem_write),
        .use_imm_in    (id_use_imm),
        .branch_in     (id_branch),
        .jal_in        (id_jal),
        .rd_idx_in     (id_rd_idx),
        .rs1_val_out   (id_ex_rs1_val),
        .rs2_val_out   (id_ex_rs2_val),
        .imm_out       (id_ex_imm),
        .alu_ctrl_out  (id_ex_alu_ctrl),
        .reg_write_out (id_ex_reg_write),
        .mem_read_out  (id_ex_mem_read),
        .mem_write_out (id_ex_mem_write),
        .use_imm_out   (id_ex_use_imm),
        .branch_out    (id_ex_branch),
        .jal_out       (id_ex_jal),
        .rd_idx_out    (id_ex_rd_idx)
    );
    assign id_ex_rs1_idx = id_rs1_idx;
    assign id_ex_rs2_idx = id_rs2_idx;

    // ======================================================
    // 5. Forwarding和EX阶段实例
    // ======================================================
    ForwardUnit forward_u(
        .ex_rs1_idx      (id_ex_rs1_idx),
        .ex_rs2_idx      (id_ex_rs2_idx),
        .ex_mem_regWrite (ex_mem_reg_write),
        .ex_mem_rd_idx   (ex_mem_rd_idx),
        .mem_wb_regWrite (mem_wb_reg_write),
        .mem_wb_rd_idx   (mem_wb_rd_idx),
        .forwardA        (forwardA),
        .forwardB        (forwardB)
    );

    logic [31:0] operandA, operandB;
    always_comb begin
        case (forwardA)
            2'b10: operandA = ex_mem_alu_result;
            2'b01: operandA = wb_final_data;
            default: operandA = id_ex_rs1_val;
        endcase
    end
    always_comb begin
        case (forwardB)
            2'b10: operandB = ex_mem_alu_result;
            2'b01: operandB = wb_final_data;
            default: operandB = id_ex_rs2_val;
        endcase
    end

    // 若使用立即数，则EX阶段第二操作数为立即数
    logic [31:0] ex_opB;
    assign ex_opB = (id_ex_use_imm) ? id_ex_imm : operandB;

    EX_stage ex_stage_u(
        .rs1_val   (operandA),
        .rs2_val   (ex_opB),
        .use_imm   (1'b0),
        .alu_ctrl  (id_ex_alu_ctrl),
        .imm       (32'd0),
        .alu_result(ex_alu_result)
    );

    // ======================================================
    // 6. 分支和跳转处理（EX阶段）
    // ======================================================
    assign branch_taken = id_ex_branch && (id_ex_rs1_val == id_ex_rs2_val);
    assign branch_target = pc_ifid + (id_ex_imm << 1);
    assign jal_target = pc_ifid + id_ex_imm;
    assign pc_sel = branch_taken || id_ex_jal;
    assign pc_in  = branch_taken ? branch_target : jal_target;
    assign flush_ifid = branch_taken || id_ex_jal;

    // ======================================================
    // 7. EX/MEM流水寄存器实例
    // ======================================================
    pipeline_reg_EX_MEM ex_mem_reg_u(
        .clk         (clk),
        .reset       (reset),
        .alu_result_in(ex_alu_result),
        .rs2_val_in  (id_ex_rs2_val),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in (id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .rd_idx_in   (id_ex_rd_idx),
        .alu_result_out(ex_mem_alu_result),
        .rs2_val_out   (ex_mem_rs2_val),
        .reg_write_out (ex_mem_reg_write),
        .mem_read_out  (ex_mem_mem_read),
        .mem_write_out (ex_mem_mem_write),
        .rd_idx_out    (ex_mem_rd_idx)
    );

    // ======================================================
    // 8. MEM Stage实例
    // ======================================================
    MEM_stage mem_stage_u(
        .clk       (clk),
        .reset     (reset),
        .addr      (ex_mem_alu_result),
        .store_data(ex_mem_rs2_val),
        .mem_read  (ex_mem_mem_read),
        .mem_write (ex_mem_mem_write),
        .mem_out   (mem_data_out)
    );

    // ======================================================
    // 9. MEM/WB流水寄存器实例
    // ======================================================
    pipeline_reg_MEM_WB mem_wb_reg_u(
        .clk           (clk),
        .reset         (reset),
        .wb_data_in    (mem_data_out),
        .reg_write_in  (ex_mem_reg_write),
        .rd_idx_in     (ex_mem_rd_idx),
        .wb_data_out   (wb_data_in),
        .reg_write_out (mem_wb_reg_write),
        .rd_idx_out    (mem_wb_rd_idx)
    );

    // ======================================================
    // 10. WB Stage实例
    // ======================================================
    WB_stage wb_stage_u(
        .alu_result (ex_mem_alu_result),
        .mem_data   (mem_data_out),
        .mem_read   (ex_mem_mem_read),
        .wb_data    (wb_final_data)
    );

    // ======================================================
    // 11. Weight Memory实例（加载cnn_weights.hex）
    // ======================================================
    // 新增权重存储器模块，用于加载CNN权重数据
    logic [9:0] weight_addr;      // 权重存储器地址信号
    logic [31:0] weight_data;     // 权重存储器数据输出

    // 在测试中，你可以驱动weight_addr为某个固定值或用作自定义指令的数据源
    assign weight_addr = 10'd0;  // 示例：读取第0地址的权重

    weight_memory #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(10)
    ) weight_mem_inst (
        .clk(clk),
        .addr(weight_addr),
        .data_out(weight_data)
    );

    // 可将 weight_data 信号与自定义指令模块接口相连，作为计算时使用的权重参数

endmodule
