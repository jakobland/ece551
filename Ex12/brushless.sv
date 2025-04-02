module brushless (
  input logic clk,
  input logic rst_n,
  input logic [11:0] drv_mag,
  input logic hallGrn,
  input logic hallYlw,
  input logic hallBlu,
  input logic brake_n,
  input logic PWM_synch,
  output logic [10:0] duty,
  output logic [1:0] selGrn,
  output logic [1:0] selYlw,
  output logic [1:0] selBlu
);

  /* Meta-stability */
  logic hallGrn_d1, hallGrn_d2, hallYlw_d1, hallYlw_d2, hallBlu_d1, hallBlu_d2;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hallGrn_d1 <= 1'b0;
      hallGrn_d2 <= 1'b0;
      hallYlw_d1 <= 1'b0;
      hallYlw_d2 <= 1'b0;
      hallBlu_d1 <= 1'b0;
      hallBlu_d2 <= 1'b0;
    end
    else begin
      hallGrn_d1 <= hallGrn;
      hallGrn_d2 <= hallGrn_d1;
      hallYlw_d1 <= hallYlw;
      hallYlw_d2 <= hallYlw_d1;
      hallBlu_d1 <= hallBlu;
      hallBlu_d2 <= hallBlu_d1;
    end
  end

  /* Synching the hall sensors to the PWM signal */
  logic synchGrn, synchYlw, synchBlu;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      synchGrn <= 1'b0;
      synchYlw <= 1'b0;
      synchBlu <= 1'b0;
    end
    else if (PWM_synch) begin
      synchGrn <= hallGrn_d2;
      synchYlw <= hallYlw_d2;
      synchBlu <= hallBlu_d2;
    end
  end

  logic [2:0] rotation_state;
  assign rotation_state = {synchGrn, synchYlw, synchBlu};

  typedef enum logic [1:0] {
    HIGHZ = 2'b00,
    REVERSE = 2'b01,
    FORWARD = 2'b10,
    REGEN = 2'b11
  } drive_state_t;

  logic [10:0] duty_lookup [0:5];

  initial begin
    // Using int (perfectly fine!)
    for (int i = 0; i < 6; i++) begin
      duty_lookup[i] = (i + 1) * 11'h100;
    end
  end

  logic [10:0] max_duty;
  always_comb begin
    max_duty = 11'h000;
    // Find maximum duty value
    for (int i = 0; i < 6; i++) begin
      if (duty_lookup[i] > max_duty)
        max_duty = duty_lookup[i];
    end
  end

  logic [10:0] duty_history [0:5];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 6; i++) begin
        duty_history[i] <= 11'h000;
      end
    end
    else begin
      // Shift values down
      for (int i = 5; i > 0; i--) begin
        duty_history[i] <= duty_history[i-1];
      end
      duty_history[0] <= duty;
    end
  end

  always_comb begin
    selGrn = HIGHZ;
    selYlw = HIGHZ;
    selBlu = HIGHZ;
    duty = 11'h000;

    if (!brake_n) begin
      selGrn = REGEN;
      selYlw = REGEN;
      selBlu = REGEN;
      duty = 11'h600;
    end
    else begin
      duty = 11'h400 + {1'b0, drv_mag[11:2]};

      case (rotation_state)
        3'b001: begin
          selGrn = HIGHZ;
          selYlw = REVERSE;
          selBlu = FORWARD;
        end
        3'b011: begin
          selGrn = REVERSE;
          selYlw = HIGHZ;
          selBlu = FORWARD;
        end
        3'b010: begin
          selGrn = REVERSE;
          selYlw = FORWARD;
          selBlu = HIGHZ;
        end
        3'b110: begin
          selGrn = HIGHZ;
          selYlw = FORWARD;
          selBlu = REVERSE;
        end
        3'b100: begin
          selGrn = FORWARD;
          selYlw = HIGHZ;
          selBlu = REVERSE;
        end
        3'b101: begin
          selGrn = FORWARD;
          selYlw = REVERSE;
          selBlu = HIGHZ;
        end
      endcase
    end
  end
endmodule
