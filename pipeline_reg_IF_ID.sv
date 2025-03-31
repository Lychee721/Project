`timescale 1ns/1ps



module pipeline_reg_IF_ID(
    input  logic        clk,
    input  logic        reset,

    // stall=1则保持现状，flush=1则插入NOP
    input  logic        stall,
    input  logic        flush,

    // IF阶段输出
    input  logic [31:0] pc_in,
    input  logic [31:0] instr_in,

    // ID阶段输入
    output logic [31:0] pc_out,
    output logic [31:0] instr_out
);

    always_ff @(posedge clk or posedge reset) begin
        
		  if(reset) begin
            pc_out    <= 32'd0;
            instr_out <= 32'h00000013; // NOP => addi x0,x0,0
        end
        
		  else if(flush) begin
            // 分支冲刷 => 指令变NOP
            pc_out    <= 32'd0;
            instr_out <= 32'h00000013;
        end
        
		  else if(stall) begin
            // 保持
            pc_out    <= pc_out;
            instr_out <= instr_out;
        end
        
		  else begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end

endmodule
