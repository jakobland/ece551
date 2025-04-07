module SPI_mnrch(
  input clk,
  input rst_n,
  output logic SS_n,
  output logic SCLK,
  output logic MOSI,
  input MISO,
  input snd,
  input [15:0] cmd,
  output logic done,
  output logic [15:0] resp
);

logic [4:0] SCLK_div;
logic full, shft;
logic [4:0] bit_cntr;
logic [15:0] shift_reg;
logic init, set_done, SCLK_ld;

/* SPI clock divider for SCLK */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    SCLK_div <= 0;
  else if (SCLK_ld)
    SCLK_div <= 5'b10111;
  else if (!set_done)
    SCLK_div <= SCLK_div + 1;
end

/* SCLK is the 5th bit of the 5-bit counter, so it's 1/32 of system clock. Shft
 * tells the shift register to shift out MOSI every rising SCLK + tiny delay.
 * The full signal is used at the end of a SPI command that signals when to
 * deassert SS_n, providing a "backporch" after SCLK remains high. */
assign SCLK = SCLK_div[4];
assign shft = SCLK_div == 5'b10001;
assign full = &SCLK_div;

/* SPI bit counter */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    bit_cntr <= 0;
  else if (init)
    bit_cntr <= 5'b00000;
  else if (shft)
    bit_cntr <= bit_cntr + 1;
end

assign done16 = bit_cntr == 5'b10000;

/* SPI shift register */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    shift_reg <= 0;
  else if (init)
    shift_reg <= cmd;
  else if (shft)
    shift_reg <= {shift_reg[14:0], MISO};
end

assign MOSI = shift_reg[15];
assign resp = shift_reg;

/* Flopped done and SS_n outputs prevents glitching. */
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    done <= 0;
  else if (init)
    done <= 0;
  else if (set_done)
    done <= 1;
end
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    SS_n <= 1;
  else if (init)
    SS_n <= 0;
  else if (set_done)
    SS_n <= 1;
end

/* SPI state machine current state flip flop */
typedef enum reg [2:0] {IDLE, SHFT, DONE} state_t;
state_t state, nxt_state;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;
end

/* SPI state machine logic */
always_comb begin
  init = 0;
  set_done = 0;
  SCLK_ld = 0;

  case (state)
    IDLE: begin
      if (snd) begin
        nxt_state = SHFT;
        init = 1;
        set_done = 0;
        SCLK_ld = 1;
      end
      else begin
        nxt_state = IDLE;
        init = 0;
        set_done = 1;
        SCLK_ld = 0;
      end
    end

    SHFT: begin
      if (done16) begin
        nxt_state = DONE;
        init = 0;
        set_done = 0;
        SCLK_ld = 0;
      end
      else begin
        nxt_state = SHFT;
        init = 0;
        set_done = 0;
        SCLK_ld = 0;
      end
    end

    default: begin
      if (full) begin
        nxt_state = IDLE;
        init = 0;
        set_done = 1;
        SCLK_ld = 0;
      end
      else begin
        nxt_state = DONE;
        init = 0;
        set_done = 0;
        SCLK_ld = 0;
      end
    end
  endcase
end
endmodule