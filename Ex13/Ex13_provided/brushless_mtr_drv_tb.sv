module brushless_mtr_drv_tb();

  /// stimulus declared as type reg;
  reg clk, rst_n;
  reg [11:0] drv_mag;
  reg [2:0] hallStim;	/// {hallGrn,hallYlw,hallBlu} ///
  reg brake_n;

  /// internal signals connecting brushless to mtr_drv ///
  wire PWM_synch;
  wire [10:0] duty;
  wire [1:0] selGrn,selYlw,selBlu;

  /// mtr_drv output signals being monitored ///
  wire highGrn,lowGrn;
  wire highYlw,lowYlw;
  wire highBlu,lowBlu;

  ////////////////////////////////
  // Instantiate brushless DUT //
  //////////////////////////////
  brushless DUT1(.clk(clk),.rst_n(rst_n),.drv_mag(drv_mag),
                 .PWM_synch(PWM_synch),.hallGrn(hallStim[2]),
				 .hallYlw(hallStim[1]),.hallBlu(hallStim[0]),
				 .brake_n(brake_n),.duty(duty),.selGrn(selGrn),
				 .selYlw(selYlw),.selBlu(selBlu));

  //////////////////////////////
  // Instantiate mtr_drv DUT //
  ////////////////////////////
  mtr_drv DUT2(.clk(clk),.rst_n(rst_n),.duty(duty),.selGrn(selGrn),
               .selYlw(selYlw),.selBlu(selBlu),.highGrn(highGrn),
			   .lowGrn(lowGrn),.highYlw(highYlw),.lowYlw(lowYlw),
			   .highBlu(highBlu),.lowBlu(lowBlu),.PWM_synch(PWM_synch));

  initial begin

  //<< initialize all input signals to brushless >>
  clk = 1'b0;
  drv_mag = 12'h7FF;
  brake_n = 1'b1;
  //<< start with hallStim at 3'b101 (same as in table) >>
  hallStim = 3'b101;
  //<< assert rst_n >>
  rst_n = 1'b0;
  //<< wait till negedge clock and deassert rst_n >>
  @(negedge clk);
  rst_n = 1'b1;
  //<< easiest to change hallStim at occurances of PWM_synch >>
  //<< observe each output of mtr_drv (highGrn,lowGrn, ...) >>
  //<< check output of all six valid hall states >>
  repeat (3) @(posedge PWM_synch);
  hallStim = 3'b100;
  repeat (3) @(posedge PWM_synch);
  hallStim = 3'b110;
  repeat (3) @(posedge PWM_synch);
  hallStim = 3'b010;
  repeat (3) @(posedge PWM_synch);
  hallStim = 3'b011;
  repeat (3) @(posedge PWM_synch);
  hallStim = 3'b001;
  repeat (3) @(posedge PWM_synch);


  //<< check output of an invalid hall state >>
  hallStim = 3'b111;
  repeat (3) @(posedge PWM_synch);
  //<< check output when brake_n is high >>
  brake_n = 1'b0;
  repeat (3) @(posedge PWM_synch);

  //<< these can be manual checks (don't self check) >>

  //<< when done with all that move on to PartII using hub_wheel_model.sv >>

	$stop();

  end

  always
    #5 clk = ~clk;

endmodule