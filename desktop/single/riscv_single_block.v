module riscv_single_block(
    input clk,
    input rst_n,
    input            ReLU      ,
    //矩阵A
    input      [7:0] matrixA_11,
    input      [7:0] matrixA_12,
    input      [7:0] matrixA_21,
    input      [7:0] matrixA_22,
    //矩阵B
    input      [7:0] matrixB_11,
    input      [7:0] matrixB_12,
    input      [7:0] matrixB_21,
    input      [7:0] matrixB_22,
    output  reg[31:0] matrixp00   ,
    output  reg[31:0] matrixp01   ,
    output  reg[31:0] matrixp10   ,
    output  reg[31:0] matrixp11   ,
    output  reg[31:0] cycle_count
);
    // 控制信号
    wire        reg_write;
    wire        mem_to_reg;
    wire        mem_write;
    wire        mem_read;
    wire [1:0]  alu_src;
    wire        pc_src;
    wire [2:0]  alu_ctrl;
    wire        custom_en;
    
    // 数据通路
    reg  [31:0] pc;
    wire [31:0] instr;
    wire [31:0] rd_data;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] alu_result;
    wire [31:0] mem_data;
    wire [31:0] imm_ext;
    
    // 寄存器文件
    reg [31:0] reg_file [0:31];
    integer        i             ;
    initial begin
        for(i=0; i<32; i=i+1) reg_file[i] = 0;
    end
    
    // 指令存储器
    reg [31:0] instr_mem [0:255];
    initial $readmemh("C:/Users/Administrator/Desktop/single/instr.mem", instr_mem);
    
    // 数据存储器
    reg [31:0] data_mem [0:255];
    initial $readmemh("C:/Users/Administrator/Desktop/single/data.mem", data_mem);
    
    // PC更新逻辑
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) pc <= 0;
        else pc <= pc + (pc_src ? imm_ext : 32'd4);
    end
    
    // 指令获取
    assign instr = instr_mem[pc[9:2]];
    
    // 寄存器文件访问
    assign rs1_data = reg_file[instr[19:15]];
    assign rs2_data = reg_file[instr[24:20]];
    
    // 立即数生成
    assign imm_ext = {{20{instr[31]}}, instr[31:20]}; // I-type
    
    // ALU输入选择
    wire [31:0] alu_in2 = (alu_src == 2'b10) ? imm_ext : 
                          (alu_src == 2'b01) ? 32'd4 : rs2_data;
    
    // ALU核心
    alu u_alu(
        .a(rs1_data),
        .b(alu_in2),
        .op(alu_ctrl),
        .custom_en(custom_en),
        .result(alu_result)
    );
    
    // 数据存储器访问
    assign mem_data = mem_read ? data_mem[alu_result[9:2]] : 0;
    always @(posedge clk) begin
        if(mem_write) data_mem[alu_result[9:2]] <= rs2_data;
    end
    
    // 写回选择
    assign rd_data = mem_to_reg ? mem_data : alu_result;
    
    // 寄存器写回
    always @(posedge clk) begin
        if(reg_write && (instr[11:7] != 0)) begin
            reg_file[instr[11:7]] <= rd_data;
        end
    end
    
    // 控制单元
    ctrl u_control(
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .pc_src(pc_src),
        .alu_ctrl(alu_ctrl),
        .custom_en(custom_en)
    );

    always @(posedge clk) begin
        if(rst_n==1'b0)begin
          cycle_count <= 32'd0;
          matrixp00<=32'd0; 
          matrixp01<=32'd0;
          matrixp10<=32'd0;
          matrixp11<=32'd0;
        end
        else if(ReLU==1'b1)begin
            matrixp00<=matrixA_11*matrixB_11+matrixA_12*matrixB_21;
            matrixp01<=matrixA_11*matrixB_12+matrixA_12*matrixB_22;
            matrixp10<=matrixA_21*matrixB_11+matrixA_22*matrixB_21;
            matrixp11<=matrixA_21*matrixB_12+matrixA_22*matrixB_22; 
            cycle_count<=cycle_count+1'd1;
        end
        end
endmodule

