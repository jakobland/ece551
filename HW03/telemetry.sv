module telemetry(
  input logic clk,
  input logic rst_n,
  input logic [11:0] batt_v,
  input logic [11:0] avg_curr,
  input logic [11:0] avg_torque,
  output logic tx
);

/* For sending a transmission periodically */
logic [19:0] trans_div;

/* State machine outputs */
logic trmt;
logic [7:0] tx_data;

/* State machine inputs */
logic tx_done;
logic start_payload;

/* Payload bytes */
logic [7:0] delim1, delim2, payload1, payload2, payload3, payload4, payload5, payload6;

assign delim1 = 8'hAA;
assign delim2 = 8'h55;
assign payload1 = {4'h0, batt_v[11:8]};
assign payload2 = batt_v[7:0];
assign payload3 = {4'h0, avg_curr[11:8]};
assign payload4 = avg_curr[7:0];
assign payload5 = {4'h0, avg_torque[11:8]};
assign payload6 = avg_torque[7:0];

UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(tx), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));

/* Send a transmission every ~21 ms */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    trans_div <= 20'h0;
  else
    trans_div <= trans_div + 1;
end

assign start_payload = &trans_div;

/* State machine states for each byte in the payload along with IDLE*/
typedef enum logic [4:0] {
  IDLE,
  DELIM1,
  DELIM2,
  PAYLOAD1,
  PAYLOAD2,
  PAYLOAD3,
  PAYLOAD4,
  PAYLOAD5,
  PAYLOAD6
} state_t;

state_t state, nxt_state;

/* Current state flip-flop */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;
end

/* State machine logic. IDLES most of the time until a transmission is triggered. */
always_comb begin
  tx_data = 8'h00;

  case (state)
    IDLE: begin
      if (start_payload) begin
        nxt_state = DELIM1;
        trmt = 1'b1;
        tx_data = delim1;
      end
      else begin
        nxt_state = IDLE;
        trmt = 1'b0;
        tx_data = 8'h00;
      end
    end

    DELIM1: begin
      if (tx_done) begin
        nxt_state = DELIM2;
        trmt = 1'b1;
        tx_data = delim2;
      end
      else begin
        nxt_state = DELIM1;
        trmt = 1'b0;
        tx_data = delim1;
      end
    end

    DELIM2: begin
      if (tx_done) begin
        nxt_state = PAYLOAD1;
        trmt = 1'b1;
        tx_data = payload1;
      end
      else begin
        nxt_state = DELIM2;
        trmt = 1'b0;
        tx_data = delim2;
      end
    end

    PAYLOAD1: begin
      if (tx_done) begin
        nxt_state = PAYLOAD2;
        trmt = 1'b1;
        tx_data = payload2;
      end
      else begin
        nxt_state = PAYLOAD1;
        trmt = 1'b0;
        tx_data = payload1;
      end
    end

    PAYLOAD2: begin
      if (tx_done) begin
        nxt_state = PAYLOAD3;
        trmt = 1'b1;
        tx_data = payload3;
      end
      else begin
        nxt_state = PAYLOAD2;
        trmt = 1'b0;
        tx_data = payload2;
      end
    end

    PAYLOAD3: begin
      if (tx_done) begin
        nxt_state = PAYLOAD4;
        trmt = 1'b1;
        tx_data = payload4;
      end
      else begin
        nxt_state = PAYLOAD3;
        trmt = 1'b0;
        tx_data = payload3;
      end
    end

    PAYLOAD4: begin
      if (tx_done) begin
        nxt_state = PAYLOAD5;
        trmt = 1'b1;
        tx_data = payload5;
      end
      else begin
        nxt_state = PAYLOAD4;
        trmt = 1'b0;
        tx_data = payload4;
      end
    end

    PAYLOAD5: begin
      if (tx_done) begin
        nxt_state = PAYLOAD6;
        trmt = 1'b1;
        tx_data = payload6;
      end
      else begin
        nxt_state = PAYLOAD5;
        trmt = 1'b0;
        tx_data = payload5;
      end
    end

    default: begin
      if (tx_done) begin
        nxt_state = IDLE;
        trmt = 1'b0;
        tx_data = 8'h00;
      end
      else begin
        nxt_state = PAYLOAD6;
        trmt = 1'b0;
        tx_data = payload6;
      end
    end
  endcase
end

endmodule