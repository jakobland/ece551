`default_nettype none

/**
 * Performs a PID transformation on the given input signal
 */
module PID (
	clk, rst_n,
	error, not_pedaling, drv_mag
);

	/* Simulation parameter */
	parameter FAST_SIM = 0;

	/* Control ports */
	input logic clk, rst_n;

	/* Input ports */
	input logic [12:0] error;
	input logic not_pedaling;

	/* Output ports */
	output logic [11:0] drv_mag;

	/* Slow pulse */
	logic [19:0] decimator;
	logic slow_pulse;
	// Use flip flop
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n)
			decimator <= 20'h00000;
		else
			decimator <= decimator + 1;
	generate 
		if (FAST_SIM)
			assign slow_pulse = &decimator[14:0];
		else
			assign slow_pulse = &decimator;
	endgenerate

	/* Proportional term */
	logic [12:0] proportional;
	assign proportional = error;

	/* Integration term */

	// Ports
	logic [17:0] i_sign_extend;
	logic [17:0] i_addition;
	logic [17:0] i_zero_clip;
	logic i_overflow;
	logic [17:0] i_saturate;
	logic [17:0] i_slow_down;
	logic [17:0] i_not_pedaling;
	logic [17:0] i_flip_flop;
	logic [11:0] integral;

	// Sign extend error signal
	assign i_sign_extend = { {5{error[12]}}, error };
	// Add current accumulation and new error
	assign i_addition = i_flip_flop + i_sign_extend;
	// Clip negative values
	assign i_zero_clip = i_addition[17] ? 18'h00000 : i_addition;
	// Detect positive overflow
	assign i_overflow = i_addition[17] & i_flip_flop[16];
	// Positive saturation signal
	assign i_saturate = i_overflow ? 18'h1FFFF : i_zero_clip;
	// Only use addition term once every 1/48 seconds
	assign i_slow_down = slow_pulse ? i_saturate : i_flip_flop;
	// Ensure pedaling
	assign i_not_pedaling = not_pedaling ? 18'h00000 : i_slow_down;

	// Flip flop storing integral term
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n)
			i_flip_flop <= 18'h00000;
		else
			i_flip_flop <= i_not_pedaling;

	// Extract integral signal from flip flop
	assign integral = i_flip_flop[16:5];

	/* Derivative term */

	// Ports
	logic [12:0] d_stage_1, d_stage_2, d_previous;
	logic [13:0] d_difference;
	logic [8:0] d_saturate;
	logic [9:0] derivative;

	// Three flip flops
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n)
			d_stage_1 <= 13'h0000;
		else if (slow_pulse)
			d_stage_1 <= error;
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n)
			d_stage_2 <= 13'h0000;
		else if (slow_pulse)
			d_stage_2 <= d_stage_1;
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n)
			d_previous <= 13'h0000;
		else if (slow_pulse)
			d_previous <= d_stage_2;

	// Sign extend and perform subtraction
	assign d_difference = { error[12], error } - { d_previous[12], d_previous };
	// Saturate to 9-bit value
	assign d_saturate = 
		d_difference[13] & ~(&d_difference[12:8]) ? 9'h100 :
		~d_difference[13] & (|d_difference[12:8]) ? 9'h0FF :
		d_difference[8:0];
	// Signed multiplication by 2, i.e. shift left by 1
	assign derivative = { d_saturate, 1'b0 };

	/* Combining three terms */

	// Ports
	logic [13:0] summation;
	logic [11:0] positive_saturate, negative_clip;

	// Add terms together
	assign summation = proportional + { 2'b00, integral } + { {4{derivative[9]}}, derivative };
	// Clip very large numbers
	assign positive_saturate = summation[12] ? 12'hFFF : summation[11:0];
	// Clip negative numbers
	assign negative_clip = summation[13] ? 12'h000 : positive_saturate;

	/* Connect output signal */
	assign drv_mag = negative_clip;

endmodule

