module paramNor #(
parameter WIDTH = 8)(
    output wire [WIDTH - 1: 0] result,
    input wire [WIDTH - 1 : 0] a,
    input wire [WIDTH - 1 : 0] b
);
    wire [WIDTH-1 : 0] or_result;

    paramOr #(WIDTH) or1(or_result, a,b);
    paramNot #(WIDTH) not1(result, or_result);

endmodule

