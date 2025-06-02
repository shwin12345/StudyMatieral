////////////////////////////////////////////////////////////////////////////////
// Module: Bin2BCD
// 
// Description: 
// - Top-Module for Conversion of an N-Bit Binary Value to a corresponding M-Bit
//		 BCD Value
//
//// Parameters:
// - N: Bit Width of Binary Value being converted
// - M: Bit Width of BCD Value (Ceil Div by 4 to get num segments)
// Inputs:
// - clk: Global Clock
// - rst_n: Global negedge rst
// - data_in: N-Bit Binary Value to Convert
// - new_data: Control Flag signifying new Data Input Value
// Outputs:
// - data_out: M-bit Converted BCD Value
// - done: Control Flag signifying data conversion complete
// - new_ack: Acknowledgement Flag signifying new data is accepted for conversion
////////////////////////////////////////////////////////////////////////////////
module Bin2BCD #(parameter N = 16, parameter M = 20)(
	// OUTPUTs
	output logic [M-1 : 0] data_out,
	output logic done,
	output logic new_ack,
	
	// INPUTs
	input clk,
	input rst_n,
	input [N-1 : 0] data_in,
	input new_data
	);
	
	parameter m = (M + 3) / 4; // Ceiling for Num 4-Bit Segments
	
	
	// FSM Control for N-Cycle Conversion Control
	typedef enum {IDLE, CONVERSION, DONE} conv_state_t;
	conv_state_t conv_state, next_state;
	logic reg_new_value, conversion_en, clr_cnt, clr_val_reg; // Control Outputs to Registers
	logic [$clog2(N)-1 : 0] shft_cnt;
	
	// Counter Register for shift num in conversion process
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			shft_cnt <= 'h0;
		end
		else if (clr_cnt) begin
			shft_cnt <= 'h0;
		end
		else if (conversion_en) begin
			shft_cnt <= shft_cnt + 1;
		end
	end
	
	// State Registers
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			conv_state <= IDLE;
		end
		else begin
			conv_state <= next_state;
		end
	end
	
	// Next State Logic
	always_comb begin
		// FSM Output Defaulting
		next_state = conv_state;
		conversion_en = 1'b0;
		reg_new_value = 1'b0;
		clr_cnt = 1'b0;
		clr_val_reg = 1'b0;
		done = 1'b0;
		new_ack = 1'b0; // If New comes outside of IDLE or DONE, never ack
		
		case (conv_state)
			CONVERSION : begin
				conversion_en = 1'b1; // Enable all shifting 
				if (shft_cnt == (N-1)) begin
					next_state = DONE;
					clr_cnt = 1'b1;
				end
			end
			
			DONE : begin
				done = 1'b1;
				if (new_data) begin
					next_state = CONVERSION;
					reg_new_value = 1'b1;
					clr_val_reg = 1'b1;
					new_ack = 1'b1; // Ack New Data is Registered
				end
			end
			
			default : begin
				if (new_data) begin
					next_state = CONVERSION;
					reg_new_value = 1'b1;
					new_ack = 1'b1; // Ack New Data is Registered
				end
			end
		endcase
	end
	
	
	// Input Binary Value Shift Register
	logic [N-1 : 0] Bin_val;
	logic Bin_MSB;
	assign Bin_MSB = Bin_val[N - 1];
	
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			Bin_val <= 'h0;
		end
		else if (reg_new_value) begin
			Bin_val <= data_in;
		end
		else if (conversion_en) begin
			Bin_val <= (Bin_val << 1);
		end
	end
	
	
	// BCD Shift-And-Add3 Logic Segments with Carry Chain
	logic [m : 0] Carry;
	assign Carry[0] = Bin_MSB;
	
	genvar i;
	generate 
		for (i = 0; i < m; i++) begin : GEN_BCD_SEGMENTS
			SAA3 ShiftAndAdd3(
				// OUTPUTs
				.BCD_seg(data_out[(4*i)+3 : (4*i)]),
				.COut(Carry[i+1]),
				
				// INPUTs
				.clk(clk), 
				.rst_n(rst_n),
				.en(conversion_en),
				.Cin(Carry[i]),
				.clr_val_reg(clr_val_reg)
				);
		end : GEN_BCD_SEGMENTS
	endgenerate
endmodule