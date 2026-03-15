// helper, not sure if necessary, but will try.
module or1bit(
    output wire y,
    input wire a,
    input wire b
);
    or o1(y, a,b);
endmodule

module paramOr #(
parameter WIDTH = 8)(
    output wire [WIDTH - 1: 0 ] result,
    input wire [WIDTH - 1: 0 ] a,
    input wire [WIDTH - 1: 0 ] b
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_or_bit
            or1bit or_inst (result[i], a[i],b[i]);
        end
    endgenerate
endmodule

