`timescale 1ns / 1ns
module paramAdderSub #(
    parameter WIDTH = 8
) (
    output wire [WIDTH-1 : 0] sum,
    output wire c_out,
    output wire overflow,
    input wire [WIDTH-1 : 0] a,
    input wire [WIDTH-1 : 0] b,
    input wire op
);
  wire [  WIDTH : 0] carry;
  wire [WIDTH-1 : 0] b_xor;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_adder_sub_bit
      assign b_xor[i] = b[i] ^ op;
      FA_str fa_inst (
          carry[i+1],
          sum[i],
          a[i],
          b_xor[i],
          carry[i]
      );
    end
  endgenerate

  assign carry[0] = op;
  assign c_out = carry[WIDTH];
  assign overflow = carry[WIDTH] ^ carry[WIDTH-1];  // I promise this works!!!
endmodule
