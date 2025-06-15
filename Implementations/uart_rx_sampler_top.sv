module uart_rx_sampler_top (
	// INPUTs
	input logic clk_sample, 	// 16x Sample Clock
	input logic clk_baud, 		// Baud Clock
	input logic RST_N,			// Glocal Reset_n
	input logic rx_bit,			// Incoming Asynchronous RX Bit
	input logic Err_clr,		// Error Clear Flag Input
	
	// OUTPUTs
	output logic [7:0] data_rx,	// Synchronized 8-Bit UART Payload
	output logic data_valid,	// Data Valid Flag for Payload
	output logic frame_err		// Error status for UART STOP Check
	);
	
	
	
	///////////////////////////////////////////////////////////////////////////       
	/////////////////////////// Internal Signals //////////////////////////////       
	///////////////////////////////////////////////////////////////////////////
	
	// FSM State Enumaration
	typedef enum {IDLE, ERROR, PAYLOAD, STOP, DONE} uart_state_t;
	uart_state_t state, next_state;
	
	logic sample_en; // Sample Counter enable when NOT in Error State
	logic rx_bit_d1, rx_bit_d2;
	logic rx_data; // Data RX after Glitch Filtering and Synchronization
	logic [3:0] sample_counter; // Counter-16 for 16x Mid-Bit Sampling
	logic sampled_data; // Sampled RX Bit by 16x Oversampler
	logic shift_reg_en; // Bit enabling registering of Payload RX 
	logic [2:0] payload_cnt; // Counter-8 for counting payload bit when receiving
	logic sampled;
	
	
	// TODO: Programmable Baud Rate Generator from a common src clock, dynamic clock div
	
	
	
	///////////////////////////////////////////////////////////////////////////       
	//////////////////////// RX Input Synchronization /////////////////////////       
	///////////////////////////////////////////////////////////////////////////       
	
	// 2-Flop Synchronizer for Asynchronous RX Input
	always_ff @(posedge clk_sample) begin
		if (!RST_N) begin
			rx_bit_d1 <= 1'b0;
			rx_bit_d2 <= 1'b0;
		end
		else begin
			rx_bit_d1 <= rx_bit;
			rx_bit_d2 <= rx_bit_d1;
		end
	end
	
	
	
	///////////////////////////////////////////////////////////////////////////       
	///////////////////////////// 16x Oversampler /////////////////////////////       
	///////////////////////////////////////////////////////////////////////////

	assign sampled = (sample_counter == 4'h7);
	
	always_ff @(posedge clk_sample) begin
		if (!RST_N) begin
			sample_counter <= 'b0;
			sampled_data <= 1'b1; // IDLE HI
		end
		else if (sample_en) begin
			sample_counter <= sample_counter + 1;
			
			// @ Sample RX Data @ Middle Bit
			if (sample_counter == 4'h7) begin
				sampled_data <= rx_bit_d2;
			end
		end
	end

	
	
	///////////////////////////////////////////////////////////////////////////       
	//////////////////////////// Data Shift Register //////////////////////////       
	///////////////////////////////////////////////////////////////////////////
	
	always_ff @(posedge clk_baud) begin
		if (!RST_N) begin
			data_rx <= 'b0;
		end
		else if (shift_reg_en) begin
			data_rx <= {sampled_data, data_rx[7:1]};
		end
	end
	
	
	
	///////////////////////////////////////////////////////////////////////////       
	///////////////////////////// FSM Control /////////////////////////////////       
	///////////////////////////////////////////////////////////////////////////

	// Payload bit counter
	always_ff @(posedge clk_baud) begin
		if (!RST_N) begin
			payload_cnt <= 'b0;
		end
		else if (shift_reg_en) begin
			payload_cnt <= payload_cnt + 1; // Roll Over to 0 after 7
		end
	end
	
	// State Register
	always_ff @(posedge clk_baud) begin
		if (!RST_N) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end
	
	// Next State and Output Logic
	always_comb begin
		// Defaulting to avoid latch inference
		next_state = state;
		shift_reg_en = 1'b0;
		sample_en = 1'b0;
		frame_err = 1'b0;
		data_valid = 1'b0;
		
		// State Cases
		case (state)
			IDLE : begin
				sample_en = 1'b1;
				
				// Start Signal Received
				if (sampled_data == 1'b0) begin
					next_state = PAYLOAD;
				end
			end
			
			PAYLOAD : begin
				sample_en = 1'b1;
				shift_reg_en = 1'b1;
				
				// 8-Bits Received
				if (payload_cnt == 3'h7) begin
					next_state = STOP;
				end
			end
			
			STOP : begin
				sample_en = 1'b1;
				
				if (sampled_data == 1'b1) begin
					next_state = DONE;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			DONE : begin
				sample_en = 1'b1;
				data_valid = 1'b1;
				
				// Start Bit received
				if (sampled_data == 1'b0) begin
					next_state = PAYLOAD;
				end
			end
			
			ERROR : begin
				frame_err = 1'b1;
				
				if (Err_clr) begin
					next_state = IDLE;
				end
			end
		endcase
	end
endmodule