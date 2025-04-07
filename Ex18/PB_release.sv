module PB_rise(
	input rst_n,
	input clk,
	input PB,
	output rise
);
	
	logic PB_q1, PB_q2, PB_q3;
	
	/* Released is asserted upon a negedge of stabilized
	 * button signal */
	assign released = PB_q2 & ~PB_q3;
	
	/* Double flop input for metastability of async button press,
	 * and another flop for negedge detection */
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			PB_q1 <= 1'b1;
			PB_q2 <= 1'b1;
			PB_q3 <= 1'b1;
		end
		else begin
			PB_q1 <= PB;
			PB_q2 <= PB_q1;
			PB_q3 <= PB_q2;
		end
	end

endmodule