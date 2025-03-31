`timescale 1ns/1ps

module ID_stage(
    
	 input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_in,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    output logic [4:0]  rs1_idx,
    output logic [4:0]  rs2_idx,
    output logic [4:0]  rd_idx,
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        use_imm,
    output logic [3:0]  alu_ctrl,
    output logic [31:0] imm,
    output logic        branch,
    output logic        jal
);

    
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode  = instr_in[6:0];
    assign rd_idx  = instr_in[11:7];
    assign funct3  = instr_in[14:12];
    assign rs1_idx = instr_in[19:15];
    assign rs2_idx = instr_in[24:20];
    assign funct7  = instr_in[31:25];

   
    logic reg_write_d;
    logic mem_read_d;
    logic mem_write_d;
    logic use_imm_d;
    logic [3:0] alu_ctrl_d;
    logic [31:0] imm_d;
    logic branch_d;
    logic jal_d;

    always_comb begin
      
        reg_write_d = 1'b0;
        mem_read_d  = 1'b0;
        mem_write_d = 1'b0;
        use_imm_d   = 1'b0;
        alu_ctrl_d  = 4'd0;
        imm_d       = 32'd0;
        
		  branch_d    = 1'b0;
        jal_d       = 1'b0;

        case (opcode)
            7'b0110011: begin
                reg_write_d = 1'b1;
                use_imm_d   = 1'b0;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_ctrl_d = 4'd1;
                        else
                            alu_ctrl_d = 4'd0;
                    end
                    3'b111: alu_ctrl_d = 4'd2;
                    3'b110: alu_ctrl_d = 4'd3;
                    3'b100: alu_ctrl_d = 4'd4;
                    default: alu_ctrl_d = 4'd0;
                endcase
            end
            7'b0010011: begin
                reg_write_d = 1'b1;
                use_imm_d   = 1'b1;
                imm_d       = {{20{instr_in[31]}}, instr_in[31:20]};
                alu_ctrl_d  = 4'd0;
            end
            7'b0000011: begin
                reg_write_d = 1'b1;
                mem_read_d  = 1'b1;
                use_imm_d   = 1'b1;
                imm_d       = {{20{instr_in[31]}}, instr_in[31:20]};
                alu_ctrl_d  = 4'd0;
            end
            7'b0100011: begin
                mem_write_d = 1'b1;
                use_imm_d   = 1'b1;
                imm_d       = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
                alu_ctrl_d  = 4'd0;
            end
            7'b1100011: begin
                branch_d    = 1'b1;
                alu_ctrl_d  = 4'd1;
                imm_d = {{19{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
            end
            7'b1101111: begin
                jal_d       = 1'b1;
                reg_write_d = 1'b1;
                imm_d = {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
                alu_ctrl_d  = 4'd0;
            end
            7'b0001011: begin
                reg_write_d = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl_d = 4'h8;  // ReLU
                    3'b001: alu_ctrl_d = 4'h9;  // MatMul
                    3'b010: alu_ctrl_d = 4'ha;  // VecAdd
                    3'b011: alu_ctrl_d = 4'hb;  // MPOOL
                    default: alu_ctrl_d = 4'd0;
                endcase
            end
            default: begin
                reg_write_d = 1'b0;
                mem_read_d  = 1'b0;
                mem_write_d = 1'b0;
                use_imm_d   = 1'b0;
                alu_ctrl_d  = 4'd0;
                imm_d       = 32'd0;
                branch_d    = 1'b0;
                jal_d       = 1'b0;
            end
        endcase
    end

    assign reg_write = reg_write_d;
    assign mem_read  = mem_read_d;
    assign mem_write = mem_write_d;
    assign use_imm   = use_imm_d;
    assign alu_ctrl  = alu_ctrl_d;
    assign imm       = imm_d;
    assign branch    = branch_d;
    assign jal       = jal_d;

endmodule
