module shift_rot(
	input [15:0]src,
	input asr,
	input [3:0]amt,
	output [15:0]res
);

	logic [15:0] shft_stg1;
	logic [15:0] shft_stg2;
	logic [15:0] shft_stg3;
	logic shft_bit;

	and (shft_bit, asr, src[15]);

	assign shft_stg1 = amt[0] ? {shft_bit, src[15:1]} : src;
	assign shft_stg2 = amt[1] ? {{2{shft_bit}}, shft_stg1[15:2]} : shft_stg1;
	assign shft_stg3 = amt[2] ? {{4{shft_bit}}, shft_stg2[15:4]} : shft_stg2;
	assign res = amt[3] ? {{8{shft_bit}}, shft_stg2[15:8]} : shft_stg3;

endmodule;
