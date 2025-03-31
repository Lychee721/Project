`timescale 1ns/1ps


module SingleCycleCPU(
    input logic clk,
    input logic reset
);


    logic [31:0] PC; 
    logic [31:0] instr_mem [0:255]; // 指令存储器，256 条指令，每条 32 位
    logic [31:0] instruction; 


    initial begin
        $readmemh("instr_mem.hex", instr_mem);
    end

  
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'd0;
        else
            PC <= PC + 32'd4;
    end


    assign instruction = instr_mem[PC[9:2]];


    logic [31:0] regs [0:31];
    integer i;
    
	 always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
        end
    end


    wire [31:0] rs1_data = (instruction[19:15] == 5'd0) ? 32'd0 : regs[instruction[19:15]];
    wire [31:0] rs2_data = (instruction[24:20] == 5'd0) ? 32'd0 : regs[instruction[24:20]];


    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2;
    logic [6:0] funct7;
    logic [31:0] imm;

    always_comb begin
        
		  opcode = instruction[6:0];
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        funct7 = instruction[31:25];

        imm = {{20{instruction[31]}}, instruction[31:20]};
    end

    
	 logic [31:0] alu_result;

    always_comb begin
      
        alu_result = 32'd0;
        
		  if (opcode == 7'b0010011) begin  // ADDI
            alu_result = rs1_data + imm;
        end else if (opcode == 7'b0110011) begin // R-type
            if (funct3 == 3'b000) begin
                if (funct7 == 7'b0100000)
                    alu_result = rs1_data - rs2_data; // SUB
                else
                    alu_result = rs1_data + rs2_data; // ADD
            end
            
        end else if (opcode == 7'b0001011) begin //ReLU
            if (funct3 == 3'b000) begin
                if ($signed(rs1_data) < 0)
                    alu_result = 32'd0;
                else
                    alu_result = rs1_data;
            end
        end else begin
            alu_result = 32'd0;
        end
    end


    always_ff @(posedge clk or posedge reset) begin
        if (!reset) begin
            if ((opcode == 7'b0010011) || (opcode == 7'b0110011) || (opcode == 7'b0001011)) begin
                if (rd != 5'd0)
                    regs[rd] <= alu_result;
            end
        end
    end

endmodule
