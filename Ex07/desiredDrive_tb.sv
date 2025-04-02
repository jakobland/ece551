module desiredDrive_tb();

logic [11:0]avg_torque;
logic [4:0]cadence;
logic not_pedaling;
logic [12:0]incline;
logic [2:0]scale;
logic [11:0]target_curr;

desiredDrive iDUT(.avg_torque(avg_torque), .cadence(cadence),
                  .not_pedaling(not_pedaling), .incline(incline),
                  .scale(scale), .target_curr(target_curr));

initial begin
  avg_torque = 0;
  cadence = 0;
  incline = 0;
  scale = 0;
  not_pedaling = 0;

  #5;

  /* Case 1 */
  avg_torque = 12'h800;
  cadence = 5'h10;
  incline = 13'h0150;
  scale = 3'h3;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'hA1A) begin
    $display("Case 1 failed");
    $stop();
  end

  /* Case 2 */
  avg_torque = 12'h800;
  cadence = 5'h10;
  incline = 13'h1F22;
  scale = 3'h5;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'h11E) begin
    $display("Case 2 failed");
    $stop();
  end

  /* Case 3 */
  avg_torque = 12'h360;
  cadence = 5'h10;
  incline = 13'h00C0;
  scale = 3'h5;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'h000) begin
    $display("Case 3 failed");
    $stop();
  end

  /* Case 4 */
  avg_torque = 12'h800;
  cadence = 5'h18;
  incline = 13'h1EF0;
  scale = 3'h5;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'h000) begin
    $display("Case 4 failed");
    $stop();
  end

  /* Case 5 */
  avg_torque = 12'h7E0;
  cadence = 5'h18;
  incline = 13'h0000;
  scale = 3'h7;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'hD66) begin
    $display("Case 5 failed");
    $stop();
  end

  /* Case 6 */
  avg_torque = 12'h7E0;
  cadence = 5'h18;
  incline = 13'h0080;
  scale = 3'h7;
  not_pedaling = 0;
  #5;
  if (target_curr != 12'hFFF) begin
    $display("Case 6 failed");
    $stop();
  end

  /* Case 7 */
  avg_torque = 12'h7E0;
  cadence = 5'h18;
  incline = 13'h0080;
  scale = 3'h7;
  not_pedaling = 1;
  #5;
  if (target_curr != 12'h000) begin
    $display("Case 7 failed");
    $stop();
  end

  $stop();

end
endmodule