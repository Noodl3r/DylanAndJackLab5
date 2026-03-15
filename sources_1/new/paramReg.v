`timescale 1ns / 1ns
module paramReg #(
    parameter WIDTH = 8)(
    output wire [WIDTH-1 : 0] q,
    input  wire [WIDTH-1 : 0] d,
    input  wire clk,
    input  wire enable
);
    // When en = 1 , pass stuff through
    // When en = 0 , hold contents
    wire [WIDTH - 1 : 0 ] d_mux;
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : reg_bit
            assign d_mux[i] = enable ? d[i] : q[i];
            dff dff_inst (q[i], d_mux[i], clk);
        end
    endgenerate
endmodule

