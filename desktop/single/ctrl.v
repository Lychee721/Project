// 控制单元
module ctrl(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg       reg_write,
    output reg       mem_to_reg,
    output reg       mem_write,
    output reg       mem_read,
    output reg [1:0] alu_src,
    output reg       pc_src,
    output reg [2:0] alu_ctrl,
    output reg       custom_en
);
    always @(*) begin
        // 默认值
        reg_write  = 0;
        mem_to_reg = 0;
        mem_write  = 0;
        mem_read   = 0;
        alu_src    = 2'b00;
        pc_src     = 0;
        alu_ctrl   = 3'b000;
        custom_en  = 0;
        
        case(opcode)
            7'b0110011: begin // R-type
                reg_write = 1;
                case(funct3)
                    3'b000: alu_ctrl = (funct7[5] ? 3'b001 : 3'b000); // ADD/SUB
                    3'b111: alu_ctrl = 3'b010; // AND
                    3'b110: alu_ctrl = 3'b011; // OR
                endcase
            end
            7'b0000011: begin // Load
                reg_write = 1;
                mem_to_reg = 1;
                mem_read = 1;
                alu_src = 2'b10;
                alu_ctrl = 3'b000;
            end
            7'b0100011: begin // Store
                mem_write = 1;
                alu_src = 2'b10;
                alu_ctrl = 3'b000;
            end
            7'b1100011: begin // Branch
                pc_src = 1;
                case(funct3)
                    3'b000: alu_ctrl = 3'b100; // BEQ
                    3'b001: alu_ctrl = 3'b101; // BNE
                endcase
            end
            7'b0001011: begin // 自定义指令
                custom_en = 1;
                reg_write = 1;
                case(funct3)
                    3'b000: alu_ctrl = 3'b110; // 矩阵乘法
                    3'b001: alu_ctrl = 3'b111; // ReLU
                endcase
            end
        endcase
    end
endmodule

