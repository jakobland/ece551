module mult_accum_gated(clk,clr,en,A,B,accum);

input clk,clr,en;
input [15:0] A,B;
output reg [63:0] accum;

reg [31:0] prod_reg;
reg en_stg2;
reg en_stg1;
wire stg1_clk;

///////////////////////////////////////////
// Generate and flop product if enabled //
/////////////////////////////////////////
always @(negedge clk)
  en_stg1 <= en;

assign stg1_clk = en_stg1 & clk;

always_ff @(posedge stg1_clk)
  prod_reg <= A*B;

/////////////////////////////////////////////////////
// Pipeline the enable signal to accumulate stage //
///////////////////////////////////////////////////
always_ff @(posedge clk)
    en_stg2 <= en_stg1;

always_ff @(posedge clk)
  if (clr)
    accum <= 64'h0000000000000000;
  else if (en_stg2)
    accum <= accum + prod_reg;

endmodule
