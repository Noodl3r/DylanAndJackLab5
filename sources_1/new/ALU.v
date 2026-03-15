module ALU #(
    parameter WIDTH = 8)(
    output reg [WIDTH-1: 0] R1,
    output wire zero,
    output wire c_out,
    output wire overflow,
    input  wire [WIDTH-1: 0] R2,
    input  wire [WIDTH-1: 0] R3,
    input wire [2:0 ]opcode
);

    // op code 000, mov
    wire [WIDTH-1:0] mov_result;
    paramMov #(WIDTH) mv(mov_result, R2);

    // op code 001, not
    wire [WIDTH-1:0] not_result;
    paramNot #(.WIDTH(WIDTH)) not_inst(
        not_result, R2);

    // op code 010 and 100, add / subtract.
    wire [WIDTH-1:0] addsub_result;
    wire c_out_raw, overflow_raw;
    paramAdderSub #(.WIDTH(WIDTH)) adder_inst(
        addsub_result, c_out_raw, overflow_raw, R2, R3, opcode[2]); // only adds with OP2 = 0 and subs with OP2 = 1. 

    // op code 011, NOR
    wire [WIDTH-1:0] nor_result;
    paramNor #(WIDTH) nor1(nor_result, R2,R3);

    // opcode 100 handled on line 10. 
    // opcode 101, NAND
    wire [WIDTH-1:0] nand_result;
    paramNand #(WIDTH) nand1(nand_result, R2,R3);

    // opcode 110, AND
    wire [WIDTH-1:0 ] and_result;
    paramAnd #(WIDTH) and1(and_result, R2,R3);


    // I presume that R1 -> result, R2 -> Operand 1, R3 -> Operand 2
    always @(*) begin
        case (opcode)
            3'b000 : R1 = mov_result ;
            3'b001 : R1 = not_result;
            3'b010 : R1 = addsub_result;
            3'b011 : R1 = nor_result;
            3'b100 : R1 = addsub_result;
            3'b101 : R1 = nand_result;
            3'b110 : R1 = and_result;
            default : R1 = 0;
        endcase
    end
    assign zero = (R1 == {WIDTH{1'b0}});
    assign c_out = (opcode == 3'b010 || opcode == 3'b100) ? c_out_raw : 1'b0;
    assign overflow = (opcode == 3'b010 || opcode == 3'b100) ? overflow_raw : 1'b0;

    endmodule
