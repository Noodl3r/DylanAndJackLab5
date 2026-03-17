module ALU #(
    parameter WIDTH = 8
) (
    output reg [WIDTH-1:0] Result,
    output wire Zero,
    output wire Carry_out,
    output wire Overflow,
    input wire [WIDTH-1:0] Operand1,
    input wire [WIDTH-1:0] Operand2,
    input wire [2:0] Opcode
);

  // op code 000, mov
  wire [WIDTH-1:0] mov_result;
  paramMov #(WIDTH) mv (
      mov_result,
      Operand1
  );

  // op code 001, not
  wire [WIDTH-1:0] not_result;
  paramNot #(
      .WIDTH(WIDTH)
  ) not_inst (
      not_result,
      Operand1
  );

  // op code 010 and 100, add / subtract.
  wire [WIDTH-1:0] addsub_result;
  wire c_out_raw, overflow_raw;
  paramAdderSub #(
      .WIDTH(WIDTH)
  ) adder_inst (
      addsub_result,
      c_out_raw,
      overflow_raw,
      Operand1,
      Operand2,
      Opcode[2]
  );  // only adds with OP2 = 0 and subs with OP2 = 1. 

  // op code 011, NOR
  wire [WIDTH-1:0] nor_result;
  paramNor #(WIDTH) nor1 (
      nor_result,
      Operand1,
      Operand2
  );

  // opcode 100 handled on line 10. 
  // opcode 101, NAND
  wire [WIDTH-1:0] nand_result;
  paramNand #(WIDTH) nand1 (
      nand_result,
      Operand1,
      Operand2
  );

  // opcode 110, AND
  wire [WIDTH-1:0] and_result;
  paramAnd #(WIDTH) and1 (
      and_result,
      Operand1,
      Operand2
  );


  // I presume that R1 -> result, R2 -> Operand 1, R3 -> Operand 2
  always @(*) begin
    case (Opcode)
      3'b000:  Result = mov_result;
      3'b001:  Result = not_result;
      3'b010:  Result = addsub_result;
      3'b011:  Result = nor_result;
      3'b100:  Result = addsub_result;
      3'b101:  Result = nand_result;
      3'b110:  Result = and_result;
      default: Result = 0;
    endcase
  end
  assign Zero = (Result == {WIDTH{1'b0}});
  assign Carry_out = (Opcode == 3'b010 || Opcode == 3'b100) ? c_out_raw : 1'b0;
  assign Overflow = (Opcode == 3'b010 || Opcode == 3'b100) ? overflow_raw : 1'b0;

endmodule
