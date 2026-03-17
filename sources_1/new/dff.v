`timescale 1ns / 1ns
module dff (
    q,
    d,
    clk
);

  //parameter D = 0;		

  input d, clk;  //declare inputs d and clk, 1 bit each
  output reg q;  //declare output q, 1 bit

  always @(posedge clk) q <= d;

endmodule
