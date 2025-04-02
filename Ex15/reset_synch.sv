module reset_synch(
	input RST_n,
	input clk,
	output logic rst_n
);
	/* Metastability flip flops */
	logic rst_q1, rst_q2;
	
	/* The synchronized reset is the output of the double-flop */
	assign rst_n = rst_q2;
	
	/* Typical double-flop to prevent metastability. However,
	 * clk is negedge triggered so that reset deassertion
	 * is on a negedge */
	always_ff @(negedge clk, negedge RST_n) begin
		if (!RST_n) begin
			rst_q1 = 1'b0;
			rst_q2 = 1'b0;
		end
		else begin
			rst_q1 = 1'b1;
			rst_q2 = rst_q1;
		end
	end

endmodule