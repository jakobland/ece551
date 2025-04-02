module desiredDrive_rnd_tb();

logic [11:0] expected_target_curr [0:1499];
logic [33:0] stim [0:1499];

logic [11:0] avg_torque;
logic [4:0] cadence;
logic not_pedaling;
logic [12:0] incline;
logic [2:0] scale;
logic [11:0] target_curr;
logic [11:0] expected;
logic error;

desiredDrive iDUT(.avg_torque(avg_torque),
                  .cadence(cadence),
                  .not_pedaling(not_pedaling),
                  .incline(incline),
                  .scale(scale),
                  .target_curr(target_curr));

initial begin
  $readmemh("desiredDrive_stim.hex", stim);
  $readmemh("desiredDrive_resp.hex", expected_target_curr);

  error = 1'b0;

  for (int i = 0; i < 1500; i++) begin
    avg_torque = stim[i][33:22];
    cadence = stim[i][21:17];
    not_pedaling = stim[i][16];
    incline = stim[i][15:3];
    scale = stim[i][2:0];
    expected = expected_target_curr[i];
    #5;
    if (target_curr !== expected) begin
      $display("Error at %d: expected 0x%h, got 0x%h", i, expected, target_curr);
      error = 1'b1;
    end
  end

  if (error == 1'b0)
    $display("All tests passed");
  else
    $display("Failed tests");

  $stop();
end

endmodule
