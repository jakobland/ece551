module mtr_drv (
  input logic clk,
  input logic rst_n,
  input logic [10:0] duty,
  input logic [1:0] selGrn,
  input logic [1:0] selYlw,
  input logic [1:0] selBlu,
  output logic highGrn,
  output logic lowGrn,
  output logic highYlw,
  output logic lowYlw,
  output logic highBlu,
  output logic lowBlu,
  output logic PWM_synch
);

  logic PWM_sig;
  logic highGrnIn, lowGrnIn, highYlwIn, lowYlwIn, highBluIn, lowBluIn;

  PWM iPWM(
    .clk(clk),
    .rst_n(rst_n),
    .duty(duty),
    .PWM_sig(PWM_sig),
    .PWM_synch(PWM_synch)
  );

  /* Green drive */
  assign highGrnIn = (selGrn == 2'b00) ? 1'b0 :
                     (selGrn == 2'b01) ? ~PWM_sig :
                     (selGrn == 2'b10) ? PWM_sig :
                     1'b0;
  assign lowGrnIn = (selGrn == 2'b00) ? 1'b0 :
                    (selGrn == 2'b01) ? PWM_sig :
                    (selGrn == 2'b10) ? ~PWM_sig :
                    PWM_sig;

  nonoverlap iNonOverlapGrn(
    .clk(clk),
    .rst_n(rst_n),
    .highIn(highGrnIn),
    .lowIn(lowGrnIn),
    .highOut(highGrn),
    .lowOut(lowGrn)
  );

  /* Yellow drive */
  assign highYlwIn = (selYlw == 2'b00) ? 1'b0 :
                     (selYlw == 2'b01) ? ~PWM_sig :
                     (selYlw == 2'b10) ? PWM_sig :
                     1'b0;
  assign lowYlwIn = (selYlw == 2'b00) ? 1'b0 :
                    (selYlw == 2'b01) ? PWM_sig :
                    (selYlw == 2'b10) ? ~PWM_sig :
                    PWM_sig;

  nonoverlap iNonOverlapYlw(
    .clk(clk),
    .rst_n(rst_n),
    .highIn(highYlwIn),
    .lowIn(lowYlwIn),
    .highOut(highYlw),
    .lowOut(lowYlw)
  );

  /* Blue drive */
  assign highBluIn = (selBlu == 2'b00) ? 1'b0 :
                     (selBlu == 2'b01) ? ~PWM_sig :
                     (selBlu == 2'b10) ? PWM_sig :
                     1'b0;
  assign lowBluIn = (selBlu == 2'b00) ? 1'b0 :
                    (selBlu == 2'b01) ? PWM_sig :
                    (selBlu == 2'b10) ? ~PWM_sig :
                    PWM_sig;

  nonoverlap iNonOverlapBlu(
    .clk(clk),
    .rst_n(rst_n),
    .highIn(highBluIn),
    .lowIn(lowBluIn),
    .highOut(highBlu),
    .lowOut(lowBlu)
  );

endmodule
