/* 3b */
module latch(d,clk,q);
  input d, clk;
  output reg q;

  /* The original provided code was not a correct model of a latch. This is
   * because the expression within the always block only evaluated upon a
   * change of clk. A latch holds the value of D when clk is high AND
   * whenever d changes too. Therefore, we must add d to the sensitivity
   * list as well */
  always @(clk, d)
    if (clk)
      q <= d;
endmodule

/* 3c */
module dff_with_set_and_enable(
  input d,
  input clk,
  input set,
  input en,
  output reg q
);

  always @(posedge clk) begin
    if (set)
      q <= 1'b1;
    else if (en)
      q <= d;
  end

endmodule

/* 3d */
module dff_with_reset_and_enable(
  input d,
  input clk,
  input rst_n,
  input en,
  output reg q
);

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      q <= 1'b0;
    else if (en)
      q <= d;
  end

endmodule

/* 3e */
module dff_with_everything(
  input d,
  input clk,
  input clr,
  input set,
  input rst_n,
  input en,
  output reg q
);

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      q <= 1'b0;
    else if (set)
      q <= 1'b1;
    else if (clr)
      q <= 1'b0;
    else if (en)
      q <= d;
  end

endmodule