module shift_rot_tb();

	logic [15:0]src;
	logic asr;
	logic [3:0]amt;
	logic [15:0]res;

	shift_rot iDUT(.src(src), .asr(asr), .amt(amt), .res(res));

	initial begin
		src = 16'h0000;
		asr = 0;
		amt = 4'h0;
		
		#5;
		
		src = 16'b0011101100111011;
		asr = 0;
		amt = 4'h0;
		
		#5;
		
		src = 16'b0011101100111011;
		asr = 0;
		amt = 4'h1;
		
		#5;
		
		src = 16'b0011101100111011;
		asr = 0;
		amt = 4'h4;
		
		#5;
		
		src = 16'b0011101100111011;
		asr = 0;
		amt = 4'hB;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 0;
		amt = 4'h0;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 0;
		amt = 4'h1;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 0;
		amt = 4'h4;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 0;
		amt = 4'hB;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 1;
		amt = 4'h0;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 1;
		amt = 4'h1;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 1;
		amt = 4'h4;
		
		#5;
		
		src = 16'b1011101100111011;
		asr = 1;
		amt = 4'hB;
		
		#5;
		
		$stop();

	end

endmodule;