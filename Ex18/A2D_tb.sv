module A2D_tb();

  logic clk, rst_n;
  logic [11:0] batt, curr, brake, torque;
  logic SS_n, SCLK, MOSI, MISO;

  // instantiation
  ADC128S iADC(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));
  A2D_intf iA2D(.clk(clk), .rst_n(rst_n), .MISO(MISO), .batt(batt), .curr(curr), .brake(brake), .torque(torque), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI));


  always #5 clk = ~clk;

  initial begin
    // initializing values
    clk = 0;
    rst_n = 0;

    // gives time for rst_n to be low before it goes high
    @(negedge clk);
    @(negedge clk);
    rst_n = 1;
    @(negedge clk);

    // start self-checking portion of tb


  #10000000;

    $stop();

  end

endmodule
