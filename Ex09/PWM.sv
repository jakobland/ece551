module PWM(
  input logic clk,
  input logic rst_n,
  input logic [10:0]duty,
  output logic PWM_sig,
  output logic PWM_synch
);

  logic [10:0]cnt;
  logic activate_pwm;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 0;
      PWM_sig <= 0;
    end
    else begin
      cnt <= cnt + 1;
      PWM_sig <= activate_pwm;
    end
  end

  assign activate_pwm = (cnt <= duty) ? 1'b1 : 1'b0;

  assign PWM_synch = (cnt == 11'h001) ? 1'b1 : 1'b0;

endmodule