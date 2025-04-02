module incline_sat(
  input [12:0]incline,
  output [9:0]incline_sat
);

  assign incline_sat = (!incline[12] && |incline[11:10]) ? 10'h1FF :
                       (incline[12] && !(&incline[11:10])) ? 10'h200 :
                       incline[9:0];

endmodule