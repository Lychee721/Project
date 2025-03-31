`timescale 1ns/1ps

module pipeline_reg_MEM_WB(
    input  logic clk,
    input  logic reset,
    input  logic [31:0] wb_data_in,  // 读入数据（Load指令数据）
    input  logic        reg_write_in,
    input  logic [4:0]  rd_idx_in,
    output logic [31:0] wb_data_out, // 输出数据，供WB阶段使用
    output logic        reg_write_out,
    output logic [4:0]  rd_idx_out
);
    
	 
	 always_ff @(posedge clk or posedge reset) begin
        
		  if (reset) begin
            wb_data_out   <= 32'd0;
            reg_write_out <= 1'b0;
            rd_idx_out    <= 5'd0;
        
		  end else begin
            
				wb_data_out   <= wb_data_in;
            reg_write_out <= reg_write_in;
            rd_idx_out    <= rd_idx_in;
        
		  
		  end
    end
endmodule
