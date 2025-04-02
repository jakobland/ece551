module cadence_filt(
  input clk,
  input rst_n,
  input cadence,
  output logic cadence_filt,
  output cadence_rise
);

  logic [15:0] stbl_cnt, cnt_and_chngd_cadence;
  logic cadence_ff1, cadence_ff2, cadence_ff3, chngd_n, capture_cadence;
  always @(posedge clk, negedge rst_n) begin
    /* first two flip flops used for metastability */
    if (!rst_n)
      cadence_ff1 <= 1'b0;
    else
      cadence_ff1 <= cadence;
    if (!rst_n)
      cadence_ff2 <= 1'b0;
    else
      cadence_ff2 <= cadence_ff1;

    /* third flip flop for edge detection */
    if (!rst_n)
      cadence_ff3 <= 1'b0;
    else
      cadence_ff3 <= cadence_ff2;

    /* 1 ms counter value */
    if (!rst_n)
      stbl_cnt <= 1'b0;
    else
      stbl_cnt <= cnt_and_chngd_cadence;

    /* filtered cadence holds debounced cadence */
    if (!rst_n)
      cadence_filt <= 1'b0;
    else
      cadence_filt <= capture_cadence;
  end

  /* active low when there is a rising or falling edge */
  assign chngd_n = ~(cadence_ff3 ^ cadence_ff2);

  /* rising edge detection of cadence */
  assign cadence_rise = ~cadence_ff3 & cadence_ff2;

  /* stable count is incremented on each clock edge and is knocked to zero
   * on every cadence edge change */
  assign cnt_and_chngd_cadence = (stbl_cnt + 1) & {16{chngd_n}};

  /* capture cadence when ~1 ms has passed from the counter. Otherwise, keep
   * most recent cadence val before counter has triggered again. */
  assign capture_cadence = &stbl_cnt ? cadence_ff3 : cadence_filt;

endmodule