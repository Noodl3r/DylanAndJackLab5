module paramNot #(
parameter WIDTH = 8)(
    output wire [WIDTH - 1: 0 ] result,
    input wire [WIDTH - 1: 0 ] a
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_not_bit
            not1bit not_inst (result[i], a[i]);
        end
    endgenerate
endmodule

module not1bit(
    output wire y,
    input wire a
);
    not n1(y,a);
endmodule
