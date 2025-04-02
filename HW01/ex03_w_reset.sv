module ex03(
  input d,
  input clk,
  input reset_n,
  output q
);

  logic mq, clk_inv;
  tri md, sd;

  not (clk_inv, clk);
  or (clk_or_reset, clk, reset_n);
  or (clk_inv_or_reset, clk_inv, reset_n);

  and (d_and_reset, d, reset_n);
  notif1 #1 (md, d_and_reset, clk_or_reset);
  not (mq, md);
  not (weak0, weak1) (md, mq);

  and (mq_and_reset, mq, reset_n);
  notif1 #1 (sd, mq_and_reset, clk_inv_or_reset);
  not (q, sd);
  not (weak0, weak1) (sd, q);

endmodule