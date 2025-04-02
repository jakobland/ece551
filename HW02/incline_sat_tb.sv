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
    if (incline_sat != 10'h1C4) begin
      $display("Failed for positive value that shouldn't saturate");
      $stop();
    end

    // Positive that saturates
    incline = 13'h05B3;
    #5;
    if (incline_sat != 10'h1C4) begin
      $display("Failed for positive value that should saturate");
      $stop();
    end

    // Negative that shouldn't saturate
    incline = 13'h1E70;
    #5;
    if (incline_sat != 10'h1C4) begin
      $display("Failed for negative value that shouldn't saturate");
      $stop();
    end

    // Negative that saturates
    incline = 13'h15B3;
    #5;
    if (incline_sat != 10'h1C4) begin
      $display("Failed for negative value that should saturate");
      $stop();
    end

    $display("YAHOO!! Test passed!");
    $stop();

  end

endmodule