module paramMov #(
    WIDTH = 8)(
    output wire [WIDTH-1 : 0] res,
    input wire [WIDTH-1 :0] a
);
    assign res = a;
endmodule
