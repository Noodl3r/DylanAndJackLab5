`timescale 1ns / 1ns

module ALU_tb;
  parameter n = 32;
  // Inputs
  reg  [n-1:0] R2;  // Operand1
  reg  [n-1:0] R3;  // Operand2
  reg  [  2:0] ALUOp;  // Opcode control signal
  reg          clk;
  reg          Enable;

  // Wires for the structural ALU's combinational outputs
  wire [n-1:0] alu_comb_result;
  wire         alu_zero;
  wire         alu_carry;
  wire         alu_overflow;

  // Instantiate the structural, combinational ALU
  ALU #(n) uut_alu (
      .Operand1(R2),
      .Operand2(R3),
      .Opcode(ALUOp),
      .Result(alu_comb_result),
      .Zero(alu_zero),
      .Carry_out(alu_carry),
      .Overflow(alu_overflow)
  );

  // Wires for the registered outputs of the structural ALU
  wire [n-1:0] R0;
  wire         z_flag;
  wire         c_out;
  wire         ovf;

  // Instantiate the register module for the structural ALU outputs
  paramReg #(n) alu_reg_inst (
      .clk(clk),
      .enable(Enable),
      .in_result(alu_comb_result),
      .in_zero(alu_zero),
      .in_carry(alu_carry),
      .in_overflow(alu_overflow),
      .out_result(R0),
      .out_zero(z_flag),
      .out_carry(c_out),
      .out_overflow(ovf)
  );

  // Behavioral ALU for verification (combinational)
  wire [n-1:0] behav_out;
  wire         behav_z;
  wire         behav_c;
  wire         behav_ovf;

  Verification_ALU #(n) verify_alu_inst (
      .a(R2),
      .b(R3),
      .select(ALUOp),
      .out(behav_out),
      .c_out(behav_c),
      .zero(behav_z),
      .overflow(behav_ovf)
  );

  // Wires for the registered outputs of the behavioral ALU
  wire [n-1:0] verify_reg_result;
  wire         z_verify;
  wire         c_out_verify;
  wire         ovf_verify;

  // Instantiate the register module for the behavioral ALU outputs
  paramReg #(n) behav_reg_inst (
      .clk(clk),
      .enable(Enable),
      .in_result(behav_out),
      .in_zero(behav_z),
      .in_carry(behav_c),
      .in_overflow(behav_ovf),
      .out_result(verify_reg_result),
      .out_zero(z_verify),
      .out_carry(c_out_verify),
      .out_overflow(ovf_verify)
  );

  // Generate an error flag if the registered outputs differ
  wire error_flag;
  assign error_flag = (R0 !== verify_reg_result) ||
                        (c_out !== c_out_verify)     ||
                        (ovf   !== ovf_verify)       ||
                        (z_flag !== z_verify);

  // Testbench stimulus
  initial begin
    // Initialize Inputs
    R2     = 0;
    R3     = 0;
    ALUOp  = 0;
    clk    = 0;
    Enable = 1;  // Enable both registers

    // Wait 10 ns for global reset to finish
    #10;

    // -------- Test cases for MOV --------
    #20;
    ALUOp = 3'b000;  // MOV: R0 = R2
    R2 = 32'd0;
    R3 = 32'd0;
    #3 R2 = 32'd421;
    #4 R2 = 32'd3;
    #4 R2 = 32'd76;

    // -------- Test cases for NOT --------
    #4;
    ALUOp = 3'b001;  // NOT: R0 = ~R2
    R2 = 32'hAAAAAAAA;
    #4 R2 = 32'd0;
    #4 R2 = 32'hFFFFFFFF;

    // -------- Test cases for ADD --------
    #4;
    ALUOp = 3'b010;  // ADD: R0 = R2 + R3
    // Big values with overflow
    R2 = 32'hFFFFFFFF;
    R3 = 32'hFFFFFFFF;
    #4;
    // Big values without overflow
    R2 = 32'd1000;
    R3 = 32'd999;
    #4;
    // Small values
    R2 = 32'd5;
    R3 = 32'd12;
    #4;
    // Negative and positive (54 + -53)
    R2 = 32'd54;
    R3 = 32'hFFFFFFCB;

    // -------- Test cases for NOR --------
    #4;
    ALUOp = 3'b011;  // NOR: R0 = ~(R2 | R3)
    R2 = 32'hFFFFFFFF;
    R3 = 32'd0;
    #4;
    R2 = 32'd0;
    R3 = 32'hFFFFFFFF;
    #4;
    R2 = 32'hAAAAAAAA;
    R3 = 32'h55555555;
    #4;
    R2 = 32'hFFFFFFFF;
    R3 = 32'hFFFFFFFF;

    // -------- Test cases for SUB --------
    #4;
    ALUOp = 3'b100;  // SUB: R0 = R2 - R3
    // Big values with overflow
    R2 = 32'hFFFFFFFF;
    R3 = 32'hFFFFFFFF;
    #4;
    // Big values without overflow
    R2 = 32'd1000;
    R3 = 32'd999;
    #4;
    // Small values
    R2 = 32'd5;
    R3 = 32'd12;
    #4;
    // Negative and positive (54 - (-53))
    R2 = 32'd54;
    R3 = 32'hFFFFFFCB;
    #4;
    // Subtract 0
    R3 = 32'd0;

    // -------- Test cases for NAND --------
    #4;
    ALUOp = 3'b101;  // NAND: R0 = ~(R2 & R3)
    R2 = 32'hFFFFFFFF;
    R3 = 32'd0;
    #4;
    R2 = 32'd0;
    R3 = 32'hFFFFFFFF;
    #4;
    R2 = 32'hAAAAAAAA;
    R3 = 32'h55555555;
    #4;
    R2 = 32'hFFFFFFFF;
    R3 = 32'hFFFFFFFF;

    // -------- Test cases for AND --------
    #4;
    ALUOp = 3'b110;  // AND: R0 = R2 & R3
    R2 = 32'hFFFFFFFF;
    R3 = 32'd0;
    #4;
    R2 = 32'd0;
    R3 = 32'hFFFFFFFF;
    #4;
    R2 = 32'hAAAAAAAA;
    R3 = 32'h55555555;
    #4;
    R2 = 32'hFFFFFFFF;
    R3 = 32'hFFFFFFFF;


    // Wait some time and then finish simulation
    #50;
    $finish;
  end

  // Clock generation: toggle clock every 2 ns.
  always #2 clk = ~clk;

endmodule
