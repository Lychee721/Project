`timescale 1ns/1ps

module pipeline_reg_EX_MEM(
    input  logic        clk,
    input  logic        reset,

    
    input  logic [31:0] alu_result_in,
    input  logic [31:0] rs2_val_in,
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic [4:0]  rd_idx_in,

   
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_val_out,
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic [4:0]  rd_idx_out
);

    always_ff @(posedge clk or posedge reset) begin
        
		  if(reset) begin
            alu_result_out <= 32'd0;
            rs2_val_out    <= 32'd0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            rd_idx_out     <= 5'd0;
        end
        
		  else begin
            alu_result_out <= alu_result_in;
            rs2_val_out    <= rs2_val_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            rd_idx_out     <= rd_idx_in;
        end
    end

endmodule
