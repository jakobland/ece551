module SPI_mnrch_tb();

logic clk, rst_n, SS_n, SCLK, MOSI, MISO, snd, done;
logic [15:0] cmd, resp;
logic [2:0] chnl;

SPI_mnrch iDUT(
  .clk(clk),
  .rst_n(rst_n),
  .SS_n(SS_n),
  .SCLK(SCLK),
  .MOSI(MOSI),
  .MISO(MISO),
  .snd(snd),
  .cmd(cmd),
  .done(done),
  .resp(resp)
);

ADC128S iADC(
  .clk(clk),
  .rst_n(rst_n),
  .SS_n(SS_n),
  .SCLK(SCLK),
  .MOSI(MOSI),
  .MISO(MISO)
);

always #5 clk = ~clk;

assign cmd = {2'b00, chnl, 11'h000};

initial begin
  clk = 0;
  rst_n = 0;
  snd = 0;
  chnl = 3'h0;

  @(negedge clk)
  rst_n = 1;

  /* Case 1: send channel 1, receiving channel 0 */
  @(negedge clk)
  chnl = 3'h1;
  snd = 1;
  @(negedge clk)
  snd = 0;
  @(posedge done)
  if (resp != 16'h0C00)
    $display("Error: chnl = %d, resp = %d", chnl, resp);
  else
    $display("Success: chnl = %d, resp = %d", chnl, resp);

  /* Case 2: send channel 1 again, receiving channel 1 from last request */
  repeat (10) @(negedge clk)
  chnl = 3'h1;
  snd = 1;
  @(negedge clk)
  snd = 0;
  @(posedge done)
  if (resp != 16'h0C01)
    $display("Error: chnl = %d, resp = %d", chnl, resp);
  else
    $display("Success: chnl = %d, resp = %d", chnl, resp);

  /* Case 3: send channel 4, receiving channel 1 from last request, decremented
   * by 0x10 because of two reads. */
  repeat (10) @(negedge clk)
  chnl = 3'h4;
  snd = 1;
  @(negedge clk)
  snd = 0;
  @(posedge done)
  if (resp != 16'h0BF1)
    $display("Error: chnl = %d, resp = %d", chnl, resp);
  else
    $display("Success: chnl = %d, resp = %d", chnl, resp);

  /* Case 4: send channel 4 again, receiving channel 4 from last request. */
  repeat (10) @(negedge clk)
  chnl = 3'h4;
  snd = 1;
  @(negedge clk)
  snd = 0;
  @(posedge done)
  if (resp != 16'h0BF4)
    $display("Error: chnl = %d, resp = %d", chnl, resp);
  else
    $display("Success: chnl = %d, resp = %d", chnl, resp);

  $display("YAHOO!!! Test passed");
  $stop();
end


endmodule
