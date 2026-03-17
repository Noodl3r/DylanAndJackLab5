module paramNand #(
    parameter WIDTH = 8
) (
    output wire [WIDTH - 1:0] result,
    input  wire [WIDTH - 1:0] a,
    input  wire [WIDTH - 1:0] b
);

  wire [WIDTH- 1:0] and_result;
  paramAnd #(WIDTH) and1 (
      and_result,
      a,
      b
  );
  paramNot #(WIDTH) n1 (
      result,
      and_result
  );

endmodule

