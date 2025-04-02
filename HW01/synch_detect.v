module synch_detect(
  input asynch_sig_in,
  input clk,
  output rise_edge
);

wire q_stabilize1, q_stabile, q_detect, q_detect_inv;

// stabilize
dff DFF_STABILIZE1(.D(asynch_sig_in), .clk(clk), .Q(q_stabilize1));
dff DFF_STABILIZE2(.D(q_stabilize1), .clk(clk), .Q(q_stabile));

// rising edge detect
dff DFF_DETECT(.D(q_stabile), .clk(clk), .Q(q_detect));
not (q_detect_inv, q_detect);
and (rise_edge, q_detect_inv, q_stabile);

endmodule