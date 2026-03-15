`timescale 1ns / 1ps
module tempALU_tb;
    parameter WIDTH = 8;

    reg [WIDTH-1:0] R2, R3;
    reg [2:0]       opcode;
    reg             clk;

    wire [WIDTH-1:0] R1;
    wire             zero, c_out, overflow;

    ALU #(WIDTH) uut (
        .R1(R1), .zero(zero), .c_out(c_out), .overflow(overflow),
        .R2(R2), .R3(R3), .opcode(opcode)
    );

    wire [WIDTH-1:0] verify_result;
    wire             verify_zero, verify_c, verify_ovf;

    Verification_ALU #(WIDTH) verify_inst (
        .a(R2), .b(R3), .select(opcode),
        .out(verify_result), .c_out(verify_c),
        .zero(verify_zero), .overflow(verify_ovf)
    );

    wire error_flag;
    assign error_flag = (R1       !== verify_result) ||
                        (zero     !== verify_zero)   ||
                        (c_out    !== verify_c)      ||
                        (overflow !== verify_ovf);

    integer pass_count, fail_count;

    task apply_test;
        input [WIDTH-1:0] a, b;
        input [2:0]       op;
        begin
            R2 = a; R3 = b; opcode = op;
            #10;
            if (error_flag) begin
                $display("FAIL | opcode=%b R2=%h R3=%h | DUT: R1=%h z=%b c=%b ovf=%b | EXP: R1=%h z=%b c=%b ovf=%b",
                    opcode, R2, R3,
                    R1, zero, c_out, overflow,
                    verify_result, verify_zero, verify_c, verify_ovf);
                fail_count = fail_count + 1;
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    initial begin
        clk        = 0;
        R2         = 0;
        R3         = 0;
        opcode     = 0;
        pass_count = 0;
        fail_count = 0;
        #10;

        // =========================================================
        // MOV (000) - result should always equal R2, ignore R3
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b000); // zero
        apply_test(8'hFF, 8'h00, 3'b000); // all ones
        apply_test(8'h01, 8'hFF, 3'b000); // min positive, R3 irrelevant
        apply_test(8'h7F, 8'hAA, 3'b000); // max positive signed
        apply_test(8'h80, 8'h00, 3'b000); // min negative signed
        apply_test(8'hAA, 8'h55, 3'b000); // alternating bits

        // =========================================================
        // NOT (001) - bitwise invert R2, ignore R3
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b001); // ~0 = FF
        apply_test(8'hFF, 8'h00, 3'b001); // ~FF = 00 (zero flag)
        apply_test(8'hAA, 8'h00, 3'b001); // ~AA = 55
        apply_test(8'h55, 8'h00, 3'b001); // ~55 = AA
        apply_test(8'h7F, 8'h00, 3'b001); // ~7F = 80
        apply_test(8'h80, 8'h00, 3'b001); // ~80 = 7F
        apply_test(8'h01, 8'h00, 3'b001); // ~01 = FE

        // =========================================================
        // ADD (010)
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b010); // 0+0=0, zero flag
        apply_test(8'h01, 8'h01, 3'b010); // 1+1=2
        apply_test(8'h7F, 8'h01, 3'b010); // signed overflow: 127+1=-128
        apply_test(8'h80, 8'h80, 3'b010); // signed overflow: -128+-128=0
        apply_test(8'hFF, 8'h01, 3'b010); // carry out: 255+1=0
        apply_test(8'hFF, 8'hFF, 3'b010); // carry out + overflow: 255+255
        apply_test(8'h0F, 8'h01, 3'b010); // nibble boundary
        apply_test(8'h55, 8'h55, 3'b010); // alternating bits
        apply_test(8'hFF, 8'h00, 3'b010); // x+0=x
        apply_test(8'h00, 8'hFF, 3'b010); // 0+x=x
        apply_test(8'h7F, 8'h7F, 3'b010); // max positive + max positive

        // =========================================================
        // NOR (011)
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b011); // NOR(0,0)=FF
        apply_test(8'hFF, 8'hFF, 3'b011); // NOR(FF,FF)=00, zero flag
        apply_test(8'hFF, 8'h00, 3'b011); // NOR(FF,0)=00, zero flag
        apply_test(8'h00, 8'hFF, 3'b011); // NOR(0,FF)=00, zero flag
        apply_test(8'hAA, 8'h55, 3'b011); // NOR(AA,55)=00, zero flag
        apply_test(8'hAA, 8'hAA, 3'b011); // NOR(AA,AA)=55
        apply_test(8'h55, 8'h55, 3'b011); // NOR(55,55)=AA
        apply_test(8'h0F, 8'hF0, 3'b011); // NOR(0F,F0)=00, zero flag

        // =========================================================
        // SUB (100)
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b100); // 0-0=0, zero flag
        apply_test(8'h01, 8'h01, 3'b100); // 1-1=0, zero flag
        apply_test(8'hFF, 8'hFF, 3'b100); // x-x=0, zero flag
        apply_test(8'h00, 8'h01, 3'b100); // 0-1 underflow
        apply_test(8'h80, 8'h01, 3'b100); // signed overflow: -128-1=127
        apply_test(8'h7F, 8'hFF, 3'b100); // signed overflow: 127-(-1)=-128
        apply_test(8'hFF, 8'h01, 3'b100); // 255-1=254
        apply_test(8'h0F, 8'h01, 3'b100); // nibble boundary
        apply_test(8'hAA, 8'h55, 3'b100); // alternating bits
        apply_test(8'h10, 8'h01, 3'b100); // borrow across nibble
        apply_test(8'h00, 8'hFF, 3'b100); // 0-255

        // =========================================================
        // NAND (101)
        // =========================================================
        apply_test(8'hFF, 8'hFF, 3'b101); // NAND(FF,FF)=00, zero flag
        apply_test(8'h00, 8'h00, 3'b101); // NAND(0,0)=FF
        apply_test(8'hFF, 8'h00, 3'b101); // NAND(FF,0)=FF
        apply_test(8'h00, 8'hFF, 3'b101); // NAND(0,FF)=FF
        apply_test(8'hAA, 8'h55, 3'b101); // NAND(AA,55)=FF
        apply_test(8'hAA, 8'hAA, 3'b101); // NAND(AA,AA)=55
        apply_test(8'h55, 8'h55, 3'b101); // NAND(55,55)=AA
        apply_test(8'h0F, 8'hFF, 3'b101); // NAND(0F,FF)=F0

        // =========================================================
        // AND (110)
        // =========================================================
        apply_test(8'h00, 8'h00, 3'b110); // AND(0,0)=0, zero flag
        apply_test(8'hFF, 8'hFF, 3'b110); // AND(FF,FF)=FF
        apply_test(8'hFF, 8'h00, 3'b110); // AND(FF,0)=0, zero flag
        apply_test(8'h00, 8'hFF, 3'b110); // AND(0,FF)=0, zero flag
        apply_test(8'hAA, 8'h55, 3'b110); // AND(AA,55)=0, zero flag
        apply_test(8'hAA, 8'hFF, 3'b110); // AND(AA,FF)=AA
        apply_test(8'h55, 8'hFF, 3'b110); // AND(55,FF)=55
        apply_test(8'h0F, 8'hFF, 3'b110); // AND(0F,FF)=0F

        // =========================================================
        // Summary
        // =========================================================
        #10;
        $display("========================================");
        $display("RESULTS: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - check above");
        $display("========================================");
        $finish;
    end

    always #2 clk = ~clk;

endmodule