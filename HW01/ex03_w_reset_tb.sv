module ex03_tb();

  logic CLK, D, Q, RESET_N;

  ex03 iDUT(.d(D), .clk(CLK), .reset_n(RESET_N), .q(Q));

  always
    #5 CLK = ~CLK;

  initial begin
    D = 0;
    CLK = 0;
    RESET_N = 1;

    @(posedge CLK);
    D = 1;
    @(posedge CLK);
    D = 0;
    @(posedge CLK);
    D = 1;

    #10;

    RESET_N = 0;

    #10;

    $stop();

  end

endmodule