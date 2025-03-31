`timescale 1ns/1ps



module pipeline_reg_ID_EX(
    
	 input  logic        clk,
    input  logic        reset,

    
    input  logic [31:0] rs1_val_in,
    input  logic [31:0] rs2_val_in,
    input  logic [31:0] imm_in,
    input  logic [3:0]  alu_ctrl_in,
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        use_imm_in,
    input  logic        branch_in,
    input  logic        jal_in,
    input  logic [4:0]  rd_idx_in,

    output logic [31:0] rs1_val_out,
    output logic [31:0] rs2_val_out,
    output logic [31:0] imm_out,
    output logic [3:0]  alu_ctrl_out,
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        use_imm_out,
    output logic        branch_out,
    output logic        jal_out,
    output logic [4:0]  rd_idx_out
);

    always_ff @(posedge clk or posedge reset) begin
        
		  if(reset) begin
            
				rs1_val_out    <= 32'd0;
            rs2_val_out    <= 32'd0;
            imm_out        <= 32'd0;
            alu_ctrl_out   <= 4'd0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            use_imm_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            rd_idx_out     <= 5'd0;
        
		  end
        
		  else begin
            
				rs1_val_out    <= rs1_val_in;
            rs2_val_out    <= rs2_val_in;
            imm_out        <= imm_in;
            alu_ctrl_out   <= alu_ctrl_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            use_imm_out    <= use_imm_in;
            
				branch_out     <= branch_in;
            jal_out        <= jal_in;
            rd_idx_out     <= rd_idx_in;
        
		  end
    end

endmodule
