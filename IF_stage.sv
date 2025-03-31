`timescale 1ns/1ps

// IF_stage 模块：取指阶段，带内部指令存储器 + PC寄存器
// Chinese: 包含PC、指令存储器；每个时钟上升沿更新PC(除非stall=1)；分支成功时可flush指令；
// English: Includes an internal instruction memory and a PC register. 
// On each rising clock edge, if not stalled, PC increments or uses branch address. 
// If flush is set, output instruction is forced to NOP.

module IF_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,          //When stall=1, hold (freeze) the PC value; 
													 //when stall=0, allow PC to update
    input  logic        flush,          // flush=1时输出NOP指令 No Operation
    input  logic        pc_sel,         // select between pc_in or (pc_reg+4) for next PC
    input  logic [31:0] pc_in,          // 若分支/跳转成功时，用此地址更新PC  If a branch/jump is taken, use this address to update PC
    output logic [31:0] instr_out,      // 当前指令
    output logic [31:0] pc_out          // 当前PC值
);

    // 简单的内部指令存储器 memory[0..255]
    logic [31:0] memory[0:255];
    
	 
	 initial begin
        
		  $readmemh("instr_mem.hex", memory);
    
	 end

    // PC寄存器
    
	 logic [31:0] pc_reg;
    logic [31:0] next_pc;

    // 计算 pc_reg+4
    logic [31:0] pc_plus4;
    assign pc_plus4 = pc_reg + 32'd4;

    
	 
	 // next_pc 由 pc_sel决定  next_pc is selected based on pc_sel
    
	 
	 always_comb begin
        
		  if (pc_sel)
            
				next_pc = pc_in;      // branch/jump target
        
		  else
            
				next_pc = pc_plus4;  // 顺序执行
    end

    // PC在时钟上升沿更新，若stall=1则保持
    
	 
	 always_ff @(posedge clk or posedge reset) begin
        
		  if(reset) begin
            pc_reg <= 32'd0;
        
		  end else if(!stall) begin
            pc_reg <= next_pc;
        
		  end
    end

    // 用 pc_reg[9:2] 作为指令地址(假设对齐4字节)
    wire [7:0] idx = pc_reg[9:2];
    wire [31:0] raw_instr = memory[idx];

    // 若 flush=1 则输出NOP(0x00000013 => addi x0,x0,0)
	 // If flush=1, output a NOP (0x00000013 => addi x0,x0,0)
    assign instr_out = flush ? 32'h00000013 : raw_instr; // 2:1 MUX
    assign pc_out    = pc_reg;

endmodule
