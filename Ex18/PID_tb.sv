
/**
 * Test bench for the PID module
 */
module PID_tb ();

	/* Ports */
	logic [11:0] drv_mag;
	logic [12:0] error;
	logic not_pedaling;
	logic test_over, clk, rst_n;

	/* Stimulus module */
	plant_PID stim (
		.drv_mag(drv_mag), .error(error),
		.not_pedaling(not_pedaling),
		.test_over(test_over),
		.clk(clk), .rst_n(rst_n)
	);

	/* Device under test */
	PID #(.FAST_SIM(1)) dut (
		.drv_mag(drv_mag), .error(error),
		.not_pedaling(not_pedaling),
		.clk(clk), .rst_n(rst_n)
	);

	/* Clock toggling */
	initial clk = 0;
	always @(clk) #1 clk <= ~clk;

	/* Control */
	initial begin
		repeat (10) @(negedge clk); 
		rst_n = 1'b0;
		repeat (10) @(negedge clk); 
		rst_n = 1'b1;

		@(posedge test_over);
		$stop;
	end

endmodule

