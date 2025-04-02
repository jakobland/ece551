module ex03(
  input d,
  input clk,
  output q
);

  logic mq, clk_inv;
  tri md, sd;

  not (clk_inv, clk);

  notif1 #1 (md, d, clk);
  not (mq, md);
  not (weak0, weak1) (md, mq);

  notif1 #1 (sd, mq, clk_inv);
  not (q, sd);
  not (weak0, weak1) (sd, q);

endmodule