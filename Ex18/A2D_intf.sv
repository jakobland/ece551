module A2D_intf(clk, rst_n, MISO, batt, curr, brake, torque, SS_n, SCLK, MOSI);

	// inputs and outputs
	input wire clk, rst_n; 		// clk and asynch active low reset
	input wire MISO;		// Master In Slave Out (serial data from the A2D)
	output logic [11:0] batt;	// Battery voltage result (channel 0)
	output logic [11:0] curr; 	// Current motor is consuming (channel 1)
	output logic [11:0] brake;	// Brake lever position (channel 3)
	output logic [11:0] torque;	// Crank spindle torque sensor (channel 4)
	output wire SS_n;		// Active low slave select (to A2D)

	output wire SCLK;		// Serial clock to the A2D
	output wire MOSI;		// Master Out Slave In (serial data to the A2D)

	// intermediate logic
	logic [13:0] delay_counter;		// delay counter
	logic snd;						// send signal
	logic done;						// signifies the SPI is done
	logic [15:0] cmd;
	logic [15:0] resp;
	logic next_transaction;
	logic cnv_complete;
	logic [1:0] channel_ctr;

	SPI_mnrch iSPI_M(clk, rst_n, SS_n, SCLK, MOSI, MISO, snd, cmd, done, resp);

	assign next_transaction = &delay_counter;

	// delay counter
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			delay_counter <= 0;
		else
			delay_counter <= delay_counter + 1;
	end

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			batt <= 0;
		else if (cnv_complete && (channel_ctr == 2'b00))
			batt <= resp[11:0];
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			curr <= 0;
		else if (cnv_complete && (channel_ctr == 2'b01))
			curr <= resp[11:0];
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			brake <= 0;
		else if (cnv_complete && (channel_ctr == 2'b10))
			brake <= resp[11:0];
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			torque <= 0;
		else if (cnv_complete && (channel_ctr == 2'b11))
			torque <= resp[11:0];
	end

	typedef enum logic [2:0] {
	BATT = 3'b000,
	CURR = 3'b001,
	TORQUE = 3'b011,
	BRAKE = 3'b100
	} signal;

	signal channel;

	typedef enum reg [1:0] {IDLE, REQ, WAIT, READ} states_t;

	states_t state, nxt_state;

	// assigning channel based on a round-robin counter
	assign channel = (channel_ctr == 2'b00) ? BATT:
					 (channel_ctr == 2'b01) ? CURR:
					 (channel_ctr == 2'b10) ? TORQUE:
					 BRAKE;

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			channel_ctr <= 0;
		else if (cnv_complete)
			channel_ctr <= channel_ctr + 1;
	end

	// states
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end

	// command to the SPI
	assign cmd = {2'b00, channel, 11'h000};

	// state machine
	always_comb begin
		cnv_complete = 0;
		snd = 0;

		case (state)
			IDLE: begin
				// if the counter is full, goes to request state
				if (next_transaction) begin
					nxt_state = REQ;
					snd = 1;
				end
				// stays idle if not ready
				else begin
					nxt_state = IDLE;
				end
			end

			// request from the SPI
			REQ: begin
				if (done) begin
					nxt_state = WAIT;
				end
				// stays in request state until done
				else begin
					nxt_state = REQ;
				end
			end

			// wait for a clock cycle state and snd something random
			WAIT: begin
				snd = 1;
				nxt_state = READ;
			end

			// reading the SPI's return
			READ: begin
				if (done) begin
					cnv_complete = 1;
					nxt_state = IDLE;
				end
				else begin
					nxt_state = READ;
				end
			end

			// default case that sends SM to IDLE state if something weird happens
			default: begin
				nxt_state = IDLE;
			end

		endcase
	end
endmodule