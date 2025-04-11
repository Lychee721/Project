// ALU模块（含自定义指令）
module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [2:0]  op,
    input         custom_en,
    output reg [31:0] result
);
    always @(*) begin
        if(custom_en) begin
            case(op)
                3'b110: result  <= a * b;       // 矩阵乘法（简化版）
                3'b111: result  <= (a > 0) ? a : 0; // ReLU
                default: result <= 0;
            endcase
        end else begin
            case(op)
                3'b000: result  <= a + b;
                3'b001: result  <= a - b;
                3'b010: result  <= a & b;
                3'b011: result  <= a | b;
                3'b100: result  <= (a == b);
                3'b101: result  <= (a != b);
                default: result <= 0;
            endcase
        end
    end
endmodule