module ring_osc(
  input en,
  output out
);

  logic n1, n2;

  nand #5 (n1, out, en);
  not #5 (n2, n1);
  not #5 (out, n2);

endmodule