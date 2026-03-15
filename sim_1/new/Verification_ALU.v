`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2025 12:08:44 AM
// Design Name: 
// Module Name: Verification_ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Verification_ALU #(parameter N = 32)(
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [2:0]   select,
    output reg [N-1:0] out,
    output reg        c_out,
    output reg        zero,
    output reg        overflow
);
    // temp is N+1 bits wide to capture any carry out.
    reg [N:0] temp;
    always @(*) begin
        case(select)
            3'b000: begin          // MOV: a
                out = a;
                c_out = 1'b0;
                overflow = 1'b0;
            end
            3'b001: begin          // NOT: ~a
                out = ~a;
                c_out = 1'b0;
                overflow = 1'b0;
            end
            3'b010: begin          // ADD: a + b
                temp = {1'b0, a} + {1'b0, b};
                out = temp[N-1:0];
                c_out = temp[N];
                // Overflow for addition: when sign of both inputs is the same,
                // but the result's sign is different.
                overflow = (~a[N-1] & ~b[N-1] &  out[N-1]) |
                           ( a[N-1] &  b[N-1] & ~out[N-1]);
            end
            3'b011: begin          // NOR: ~(a | b)
                out = ~(a | b);
                c_out = 1'b0;
                overflow = 1'b0;
            end
            3'b100: begin          // SUB: a - b computed as A + (~B) + 1
                temp = {1'b0, a} + {1'b0, ~b} + 1;
                out = temp[N-1:0];
                c_out = temp[N];
                // Overflow for subtraction:
                overflow = ( a[N-1] & ~b[N-1] & ~out[N-1]) |
                           (~a[N-1] &  b[N-1] &  out[N-1]);
            end
            3'b101: begin          // NAND: ~(a & b)
                out = ~(a & b);
                c_out = 1'b0;
                overflow = 1'b0;
            end
            3'b110: begin          // AND: a & b
                out = a & b;
                c_out = 1'b0;
                overflow = 1'b0;
            end
            default: begin
                out = {N{1'b0}};
                c_out = 1'b0;
                overflow = 1'b0;
            end
        endcase
        zero = (out == {N{1'b0}});
    end
endmodule
