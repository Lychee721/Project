
module forwarding_unit(
    input  [4:0] ID_EX_rs1,
    input  [4:0] ID_EX_rs2,
    input  [4:0] EX_MEM_rd,
    input  [4:0] MEM_WB_rd,
    input        EX_MEM_reg_wr_en,
    input        MEM_WB_reg_wr_en,
    output reg [1:0] forward_rs1,
    output reg [1:0] forward_rs2
);

always @(*) begin
    forward_rs1 = 2'b00;
    forward_rs2 = 2'b00;
    

    if(EX_MEM_reg_wr_en && (EX_MEM_rd != 0)) begin
        if(EX_MEM_rd == ID_EX_rs1) forward_rs1 = 2'b10;
        if(EX_MEM_rd == ID_EX_rs2) forward_rs2 = 2'b10;
    end
    

    if(MEM_WB_reg_wr_en && (MEM_WB_rd != 0)) begin
        if(MEM_WB_rd == ID_EX_rs1) forward_rs1 = 2'b01;
        if(MEM_WB_rd == ID_EX_rs2) forward_rs2 = 2'b01;
    end
end

endmodule