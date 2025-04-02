module incline_sat_tb();

  logic [12:0]incline;
  logic [9:0]incline_sat;

  incline_sat iDUT(.incline(incline), .incline_sat(incline_sat));

  initial begin
    incline = 0;

    #5;
    // Positive that shouldn't saturate
    incline = 13'h01C4;
    #5;
    // Positive that saturates
    incline = 13'h05B3;
    #5;
    // Negative that shouldn't saturate
    incline = 13'h1E70;
    #5;
    // Negative that saturates
    incline = 13'h15B3;
    #5;

    $stop();

  end

endmodule