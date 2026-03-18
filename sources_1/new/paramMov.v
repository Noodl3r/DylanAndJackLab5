module paramMov #(
    parameter WIDTH = 8
)(
    output wire [WIDTH-1:0] res,
    input  wire [WIDTH-1:0] a
);

    wire [WIDTH-1:0] tmp;

    assign tmp = a;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            buf (res[i], tmp[i]);
        end
    endgenerate

endmodule