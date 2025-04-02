module nonoverlap_tb();

  logic clk, rst_n;
  logic highIn, lowIn;
  logic highOut, lowOut;
  logic pwm;

  nonoverlap iDUT(.clk(clk), .rst_n(rst_n), .highIn(highIn),
                        .lowIn(lowIn), .highOut(highOut), .lowOut(lowOut));

  always #5 clk = ~clk;

  assign highIn = pwm;
  assign lowIn = ~pwm;

  initial begin
    pwm = 0;
    clk = 0;
    rst_n = 0;

    @(negedge clk);
    rst_n = 1;

    @(negedge clk);
    pwm = 1;

    repeat (32) @(negedge clk) begin
      if (highOut || lowOut) begin
        $display("either highOut or lowOut has been asserted during deadTime at time %t", $time);
        $stop();
      end
    end

    @(negedge clk);
    if ((highOut != highIn) || (lowOut != lowIn)) begin
      $display("highOut or lowOut has not taken on the value of highIn or lowIn after deadTime has ended");
      $stop();
    end

    repeat(32) @(negedge clk);

    @(negedge clk);
    pwm = 0;

    repeat (32) @(negedge clk) begin
      if (highOut || lowOut) begin
        $display("either highOut or lowOut has been asserted during deadTime at time %t", $time);
        $stop();
      end
    end

    @(negedge clk);
    if ((highOut != highIn) || (lowOut != lowIn)) begin
      $display("highOut or lowOut has not taken on the value of highIn or lowIn after deadTime has ended");
      $stop();
    end

    $display("YAHOO!!! Test passed!");
    repeat(32) @(negedge clk);
    $stop();

  end

endmodule