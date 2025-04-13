module PB_rise (PB, rst_n, clk, rise);
	input wire PB, rst_n, clk;
	output wire rise;
	logic meta1, meta2, detector;

	assign rise = (meta2 && ~detector);

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			meta1 <= 1;
			meta2 <= 1;
			detector <= 1;
		end
		else begin
			meta1 <= PB;
			meta2 <= meta1;
			detector <= meta2;
		end
	end
endmodule
