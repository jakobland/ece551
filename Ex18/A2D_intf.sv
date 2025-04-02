module A2D_intf();

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
	wire snd;						// send signal
	wire done;						// signifies the SPI is done
	wire [15:0] cmd;
	wire [15:0] resp;

	SPI_mnrch iSPI_M(clk, rst_n, SS_n, SCLK, MOSI, MISO, snd, cmd, done, resp);

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			delay_counter <= 0;
		else
			delay_counter = delay_counter + 1;
	end

	typedef enum logic [2:0] {
	BATT = 3'b000,
	CURR = 3'b001,
	TORQUE = 2'b011,
	BRAKE = 3'b100
	} signal;

	signal channel;

	typedef enum [1:0] reg {IDLE, REQ, READ, DONE} states;
	states state, nxt_state;

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			state <= 0;
		else
			state <= nxt_state;
	end

	assign cmd = {2'b00, channel, 11'h000};

	always_comb begin
		init = 0;
		set_done = 0;
		SCLK_ld = 0;

		case (state)
			IDLE: begin
				if (snd) begin
					nxt_state = REQ;
				end
				else begin
					nxt_state = IDLE;
				end
			end
			REQ: begin
			end
			READ: begin
			end
			DONE: begin
				channel = channel + 1;
			end
		endcase
	end
endmodule