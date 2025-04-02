module ring_osc_tb();

  logic OUT, EN;

  ring_osc iDUT(.en(EN), .out(OUT));

  initial begin
    EN = 0;
    #15;
    EN = 1;
    #60;
    EN = 0;
    #15;
    $stop();
  end

endmodule