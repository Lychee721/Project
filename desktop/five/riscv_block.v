module riscv_block (
  input clk  ,
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


  reg [31:0] IF_ID_inst, IF_ID_pc;
  reg [31:0] ID_EX_pc, ID_EX_rs1_data, ID_EX_rs2_data;
  reg [31:0] ID_EX_imm      ;
  reg [ 4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
  reg [ 6:0] ID_EX_opcode   ;
  reg [ 2:0] ID_EX_funct3   ;
  reg        ID_EX_reg_wr_en;
  reg        ID_EX_mem_rd_en, ID_EX_mem_wr_en;

  wire [31:0] EX_MEM_alu_res  ;
  reg  [31:0] EX_MEM_rs2_data ;
  reg  [ 4:0] EX_MEM_rd       ;
  reg         EX_MEM_reg_wr_en;
  reg         EX_MEM_mem_rd_en, EX_MEM_mem_wr_en;

  wire [31:0] MEM_WB_mem_data ;
  reg  [31:0] MEM_WB_alu_res  ;
  reg  [ 4:0] MEM_WB_rd       ;
  reg         MEM_WB_reg_wr_en;


  wire        pc_src       ;
  wire [31:0] branch_target;
  wire        hazard_detect;
  wire [ 1:0] forward_rs1, forward_rs2;


  reg [31:0] instr_mem[0:255];
  initial $readmemh("C:/Users/Administrator/Desktop/five/instr.mem", instr_mem);


  reg [31:0] data_mem[0:255];
  initial $readmemh("C:/Users/Administrator/Desktop/five/data.mem", data_mem);


  reg     [31:0] reg_file[0:31];
  integer        i             ;
  initial for(i=0;i<32;i=i+1) reg_file[i] = 0;


  wire [31:0] pc_next = (pc_src | ~rst_n) ? branch_target : (IF_ID_pc + 4);
  reg  [31:0] pc                                                          ;
  always @(posedge clk) begin
    if(~rst_n) pc <= 0;
    else if(~hazard_detect) pc <= pc_next;
  end

  always @(posedge clk) begin
    if(~rst_n) begin
      IF_ID_inst <= 0;
      IF_ID_pc   <= 0;
    end else if(~hazard_detect) begin
      IF_ID_inst <= instr_mem[pc[9:2]];
      IF_ID_pc   <= pc;
    end
  end


  wire [ 6:0] opcode = IF_ID_inst[6:0]                                                               ;
  wire [ 4:0] rs1    = IF_ID_inst[19:15]                                                             ;
  wire [ 4:0] rs2    = IF_ID_inst[24:20]                                                             ;
  wire [ 4:0] rd     = IF_ID_inst[11:7]                                                              ;
  wire [ 2:0] funct3 = IF_ID_inst[14:12]                                                             ;
  wire [31:0] imm    = { {21{IF_ID_inst[31]}}, IF_ID_inst[30:25], IF_ID_inst[24:21], IF_ID_inst[20] };


  hazard_unit hu (
    .ID_EX_rd       (ID_EX_rd       ),
    .EX_MEM_rd      (EX_MEM_rd      ),
    .rs1            (rs1            ),
    .rs2            (rs2            ),
    .ID_EX_mem_rd_en(ID_EX_mem_rd_en),
    .hazard_detect  (hazard_detect  )
  );


  forwarding_unit fu (
    .ID_EX_rs1       (ID_EX_rs1       ),
    .ID_EX_rs2       (ID_EX_rs2       ),
    .EX_MEM_rd       (EX_MEM_rd       ),
    .MEM_WB_rd       (MEM_WB_rd       ),
    .EX_MEM_reg_wr_en(EX_MEM_reg_wr_en),
    .MEM_WB_reg_wr_en(MEM_WB_reg_wr_en),
    .forward_rs1     (forward_rs1     ),
    .forward_rs2     (forward_rs2     )
  );


  wire [31:0] rs1_data = (rs1 == 0) ? 0 : reg_file[rs1];
  wire [31:0] rs2_data = (rs2 == 0) ? 0 : reg_file[rs2];

  always @(posedge clk) begin
    if(~rst_n) begin
      ID_EX_pc        <= 0;
      ID_EX_rs1_data  <= 0;
      ID_EX_rs2_data  <= 0;
      ID_EX_imm       <= 0;
      ID_EX_rs1       <= 0;
      ID_EX_rs2       <= 0;
      ID_EX_rd        <= 0;
      ID_EX_opcode    <= 0;
      ID_EX_funct3    <= 0;
      ID_EX_reg_wr_en <= 0;
      ID_EX_mem_rd_en <= 0;
      ID_EX_mem_wr_en <= 0;
    end else if(~hazard_detect) begin
      ID_EX_pc        <= IF_ID_pc;
      ID_EX_rs1_data  <= rs1_data;
      ID_EX_rs2_data  <= rs2_data;
      ID_EX_imm       <= imm;
      ID_EX_rs1       <= rs1;
      ID_EX_rs2       <= rs2;
      ID_EX_rd        <= rd;
      ID_EX_opcode    <= opcode;
      ID_EX_funct3    <= funct3;
      ID_EX_reg_wr_en <= (opcode == 7'b0110011 || opcode == 7'b0000011); // R-type or Load
      ID_EX_mem_rd_en <= (opcode == 7'b0000011);
      ID_EX_mem_wr_en <= (opcode == 7'b0100011);
    end
  end


  wire [31:0] alu_in1 = (forward_rs1 == 2'b10) ? EX_MEM_alu_res :
    (forward_rs1 == 2'b01) ? MEM_WB_alu_res :
      ID_EX_rs1_data;

  wire [31:0] alu_in2 = (ID_EX_opcode == 7'b0010011) ? ID_EX_imm :
    (forward_rs2 == 2'b10) ? EX_MEM_alu_res :
      (forward_rs2 == 2'b01) ? MEM_WB_alu_res :
        ID_EX_rs2_data;

  alu u_alu (
    .a            (alu_in1       ),
    .b            (alu_in2       ),
    .op           (ID_EX_opcode  ),
    .funct3       (ID_EX_funct3  ),
    .result       (EX_MEM_alu_res),
    .branch_taken (pc_src        ),
    .branch_target(branch_target )
  );


  always @(posedge clk) begin
    EX_MEM_rd        <= ID_EX_rd;
    EX_MEM_reg_wr_en <= ID_EX_reg_wr_en;
    EX_MEM_mem_rd_en <= ID_EX_mem_rd_en;
    EX_MEM_mem_wr_en <= ID_EX_mem_wr_en;
    EX_MEM_rs2_data  <= alu_in2;

    if(EX_MEM_mem_wr_en)
      data_mem[EX_MEM_alu_res[9:2]] <= EX_MEM_rs2_data;
  end

  assign MEM_WB_mem_data = data_mem[EX_MEM_alu_res[9:2]];


  always @(posedge clk) begin
    MEM_WB_rd        <= EX_MEM_rd;
    MEM_WB_reg_wr_en <= EX_MEM_reg_wr_en;
    MEM_WB_alu_res   <= EX_MEM_alu_res;

    if(MEM_WB_reg_wr_en && MEM_WB_rd != 0) begin
      reg_file[MEM_WB_rd] <= (EX_MEM_mem_rd_en) ? MEM_WB_mem_data : MEM_WB_alu_res;
    end
  end

  // 流水线寄存器
  reg [15:0] add1;
  reg [15:0] add2;
  reg [15:0] add3;
  reg [15:0] add4;
  reg [15:0] add5;
  reg [15:0] add6;
  reg [15:0] add7;
  reg [15:0] add8;


//matrixp00
  always @(posedge clk) begin
    if(rst_n==1'b0)
      add1 <= 16'd0;
    else if(ReLU==1'b1)
      add1 <= matrixA_11*matrixB_11;
    else
      add1 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      add2 <= 16'd0;
    else if(ReLU==1'b1)
      add2 <= matrixA_12*matrixB_21;
    else
      add2 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      matrixp00 <= 32'd0;
    else if(ReLU==1'b1)
      matrixp00 <= add1+add2;
  end

//matrixp01
  always @(posedge clk) begin
    if(rst_n==1'b0)
      add3 <= 16'd0;
    else if(ReLU==1'b1)
      add3 <= matrixA_11*matrixB_12;
    else
      add3 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      add4 <= 16'd0;
    else if(ReLU==1'b1)
      add4 <= matrixA_12*matrixB_22;
    else
      add4 <= 16'd0;
  end


  always @(posedge clk) begin
    if(rst_n==1'b0)
      matrixp01 <= 32'd0;
    else if(ReLU==1'b1)
      matrixp01 <= add3+add4;
  end

//matrixp10
  always @(posedge clk) begin
    if(rst_n==1'b0)
      add5 <= 16'd0;
    else if(ReLU==1'b1)
      add5 <= matrixA_21*matrixB_11;
    else
      add5 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      add6 <= 16'd0;
    else if(ReLU==1'b1)
      add6 <= matrixA_22*matrixB_21;
    else
      add6 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      matrixp10 <= 32'd0;
    else if(ReLU==1'b1)
      matrixp10 <= add5+add6;
  end

//matrixp11
  always @(posedge clk) begin
    if(rst_n==1'b0)
      add7 <= 16'd0;
    else if(ReLU==1'b1)
      add7 <= matrixA_21*matrixB_12;
    else
      add7 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      add8 <= 16'd0;
    else if(ReLU==1'b1)
      add8 <= matrixA_22*matrixB_22;
    else
      add8 <= 16'd0;
  end

  always @(posedge clk) begin
    if(rst_n==1'b0)
      matrixp11 <= 32'd0;
    else if(ReLU==1'b1)
      matrixp11 <= add7+add8;
  end
  always @(posedge clk) begin
    if(rst_n==1'b0)
    cycle_count <= 32'd0;
    else if(ReLU==1'b1)
      cycle_count <= cycle_count+1'b1;
  end
  

endmodule








