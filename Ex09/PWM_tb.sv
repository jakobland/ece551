module PWM_tb();
  logic clk, rst_n, PWM_sig, PWM_synch;
  logic [10:0] duty;

  PWM iDUT(.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_sig(PWM_sig), .PWM_synch(PWM_synch));

  always
    #10 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    duty = 0;

    @(negedge clk);
    rst_n = 1;

    /* PWM signal should be low the entire time*/
    repeat (2048) @(negedge clk);

    /* PWM signal should be %50 high/low */
    duty = 1024;
    repeat (2048) @(negedge clk);

    /* High about a third of the period */
    duty = 679;
    repeat (2048) @(negedge clk);

    /* High for a large majority of the period */
    duty = 1723;
    repeat (2048) @(negedge clk);

    /* High the entire time */
    duty = 2047;
    repeat (2048) @(negedge clk);

    $stop();
  end

endmodule