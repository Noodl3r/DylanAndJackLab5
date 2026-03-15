module and1bit(
    output wire y,
    input wire a,
    input wire b
);
    and a1(y,a,b);
endmodule

module paramAnd #(
parameter WIDTH = 8)(
    output wire [WIDTH - 1: 0 ] result,
    input wire [WIDTH - 1: 0 ] a,
    input wire [WIDTH - 1: 0 ] b
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_not_bit
            and1bit and_inst (result[i], a[i], b[i]);
        end
    endgenerate
endmodule

