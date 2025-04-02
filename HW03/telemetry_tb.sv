module telemetry_tb();

logic clk, rst_n;
logic [11:0] batt_v, avg_curr, avg_torque;
logic tx;
logic [7:0] rx_data;
logic rdy, clr_rdy;

logic [7:0] expected_rx;

telemetry iDUT(.clk(clk), .rst_n(rst_n), .batt_v(batt_v), .avg_curr(avg_curr), .avg_torque(avg_torque), .tx(tx));
UART_rcv iRCV(.clk(clk), .rst_n(rst_n), .RX(tx), .rdy(rdy), .rx_data(rx_data), .clr_rdy(clr_rdy));

always #5 clk = ~clk;

assign clr_rdy = rdy;

initial begin
  clk = 0;
  rst_n = 0;
  batt_v = 12'h000;
  avg_curr = 12'h000;
  avg_torque = 12'h000;

  @(negedge clk);
  rst_n = 1;

  @(negedge clk);
  batt_v = 12'h333;
  avg_curr = 12'h222;
  avg_torque = 12'h111;

  @(posedge rdy);
  expected_rx = 8'hAA;
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = 8'h55;
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = {4'h0, batt_v[11:8]};
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = batt_v[7:0];
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = {4'h0, avg_curr[11:8]};
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = avg_curr[7:0];
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = {4'h0, avg_torque[11:8]};
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  @(posedge rdy);
  expected_rx = avg_torque[7:0];
  if (rx_data != expected_rx) begin
    $display("Error: Expected %h, got %h", expected_rx, rx_data);
    $stop();
  end

  $display("YAHOO!!! Test passed");
  $stop();
end
endmodule
