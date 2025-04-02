module ex03(
  input d,
  input clk,
  input reset_n,
  output q
);

  logic mq, clk_inv, reset_or_md, reset_or_sd;
  tri md, sd;

  not (clk_inv, clk);
  not (reset_n_inv, reset_n);

  notif1 #1 (md, d, clk);
  or (reset_or_md, md, reset_n_inv);
  not (mq, reset_or_md);
  not (weak0, weak1) (md, mq);

  notif1 #1 (sd, mq, clk_inv);
  or (reset_or_sd, sd, reset_n_inv);
  not (q, reset_or_sd);
  not (weak0, weak1) (sd, q);

endmodule