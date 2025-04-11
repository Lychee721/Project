module alu (
  input      [31:0] a            ,
  input      [31:0] b            ,
  input      [ 6:0] op           ,
  input      [ 2:0] funct3       ,
  output reg [31:0] result       ,
  output            branch_taken ,
  output     [31:0] branch_target
);


  localparam CUSTOM_OP = 7'b0001011;

  always @(*) begin
    case(op)
      7'b0110011 : begin // R-type
        case(funct3)
          3'b000 : result = a + b;  // ADD
          3'b001 : result = a << b; // SLL
        endcase
      end
      CUSTOM_OP : begin
        case(funct3)
          3'b000 : result = a + b;
          3'b001 : result = (a > 0) ? a : 0;
        endcase
      end
    endcase
  end

  assign branch_taken = (op == 7'b1100011) && ((funct3 == 3'b000 && a == b) ||
    (funct3 == 3'b001 && a != b));
  assign branch_target = a + b;

endmodule