`timescale 1ns / 1ns
module paramReg #(
    parameter WIDTH = 8
) (
    output wire [WIDTH-1 : 0] out_result,
    output wire out_zero,
    output wire out_carry,
    output wire out_overflow,
    input wire [WIDTH-1 : 0] in_result,
    input wire in_zero,
    input wire in_carry,
    input wire in_overflow,

    input wire clk,
    input wire enable
);

  // Clever way of avoiding more writing to account for the additional requirements.
  wire [WIDTH + 2 : 0] in_bus = {in_result, in_zero, in_carry, in_overflow};
  wire [WIDTH + 2 : 0] out_bus;
  assign {out_result, out_zero, out_carry, out_overflow} = out_bus;

  // When en = 1 , pass stuff through
  // When en = 0 , hold contents
  wire [WIDTH + 2 : 0] d_mux;
  genvar i;
  generate
    for (i = 0; i < WIDTH + 3; i = i + 1) begin : g_reg_bit
      assign d_mux[i] = enable ? in_bus[i] : out_bus[i];
      dff dff_inst (
          out_bus[i],
          d_mux[i],
          clk
      );
    end
  endgenerate

endmodule

