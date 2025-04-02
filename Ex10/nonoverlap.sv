module nonoverlap(
  input logic clk,
  input logic rst_n,
  input logic highIn,
  input logic lowIn,
  output logic highOut,
  output logic lowOut
);

  logic highIn_edge, lowIn_edge;
  logic highIn_d, lowIn_d;

  logic [4:0] deadTime_counter;
  logic deadTime;

  /* Input edge detection. */
  assign highIn_edge = highIn ^ highIn_d;
  assign lowIn_edge = lowIn ^ lowIn_d;

  /* Deadtime is whenever the deadTime counter hos not finished counting or
   * when an edge is detected. */
  assign deadTime = ~(&deadTime_counter) || highIn_edge || lowIn_edge;

  always_ff @(posedge clk or negedge rst_n) begin

    /* For edge detection of input signals. */
    if (!rst_n) begin
      highIn_d <= 0;
      lowIn_d <= 0;
    end
    else begin
      highIn_d <= highIn;
      lowIn_d <= lowIn;
    end

    /* Deadtime counter is a one-shot time which begins when an edge is
     * detected and ends when deadTime is over. */
    if (!rst_n) begin
      deadTime_counter <= 0;
    end
    else if (highIn_edge || lowIn_edge) begin
      deadTime_counter <= 0;
    end
    else if (deadTime) begin
      deadTime_counter <= deadTime_counter + 1;
    end

    /* Flopped output prevents glitching, and takes on the value of the input
     * when deadTime is not asserted. */
    if (!rst_n) begin
      highOut <= 0;
      lowOut <= 0;
    end
    else begin
      highOut <= highIn & ~deadTime;
      lowOut <= lowIn & ~deadTime;
    end
  end

endmodule
