
module hazard_unit(
    input  [4:0] ID_EX_rd,
    input  [4:0] EX_MEM_rd,
    input  [4:0] rs1,
    input  [4:0] rs2,
    input        ID_EX_mem_rd_en,
    output reg   hazard_detect
);

always @(*) begin
    hazard_detect = 0;
    if(ID_EX_mem_rd_en && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2)))
        hazard_detect = 1;
end

endmodule