module ex03_tb();

  logic CLK, D, Q;

  ex03 iDUT(.d(D), .clk(CLK), .q(Q));

  always
    #5 CLK = ~CLK;

  initial begin
    D = 0;
    CLK = 0;

    @(posedge CLK);
    D = 1;
    @(posedge CLK);
    D = 0;

    #10;
    $stop();

  end

endmodule