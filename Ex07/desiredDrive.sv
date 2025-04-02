module desiredDrive(
  input [11:0]avg_torque,
  input [4:0]cadence,
  input not_pedaling,
  input [12:0]incline,
  input [2:0]scale,
  output [11:0]target_curr
);

  localparam TORQUE_MIN = 12'h380;

  logic [9:0]incline_sat;
  logic [10:0]incline_factor;
  logic [8:0]incline_lim;
  logic [9:0]cadence_factor;
  logic [12:0]torque_off;
  logic [11:0]torque_pos;
  logic [29:0]assist_prod;

  /* Saturature incline */
  assign incline_sat = (!incline[12] && |incline[11:9]) ? 10'h1FF :
                       (incline[12] && !(&incline[11:9])) ? 10'h200 :
                       incline[9:0];

  /* Saturated incline is sign-extended and added 256 */
  assign incline_factor = {incline_sat[9], incline_sat} + 11'h100;

  /* Incline factor is either clipped at 0 or saturates incline lim */
  assign incline_lim = incline_factor[10] ? 9'h000 :
                       incline_factor[9] ? 9'h1FF :
                       incline_factor[8:0];

  /* We have a cadence factor which is cadence added 32 when greater than 1.
   * Otherwise, cadence factor is 0 */
  assign cadence_factor = (cadence > 1) ? (cadence + 10'h020) :
                          10'h000;

  /* Compensate for torque sensor offset */
  assign torque_off = {1'b0, avg_torque} - {1'b0, TORQUE_MIN};

  /* Clip offset-compensated torque at 0 if negative */
  assign torque_pos = torque_off[12] ? 11'h000 :
                     torque_off[11:0];

  /* Contribute all factors to the final product. The final product is set to 0
   * if not pedaling */
  assign assist_prod = (torque_pos * incline_lim * cadence_factor * scale) & {30{~not_pedaling}};

  assign target_curr = |assist_prod[29:27] ? 12'hFFF :
                       assist_prod[26:15];

endmodule