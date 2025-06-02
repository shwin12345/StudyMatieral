////////////////////////////////////////////////////////////////////////////////
// Module: SAA3
// 
// Description: 
// - 4-bit BCD Segment Shift Register used for conversion of Binary Values to BCD 
//
// Inputs:
// - clk: Global Clock
// - rst_n: Global negedge rst
// - en: Shift enable for signifying conversion
// - Cin: Input Bit shifted in to 4-bit segment
// - clr_val_reg: Input flag for clearing value register for next operation
// Outputs:
// - BCD_seg: 4-bit BCD Register Value
// - COut: Carry Output Bit shifted to next 4-bit segment 
////////////////////////////////////////////////////////////////////////////////
module SAA3 (
	// OUTPUTs
	output logic [3:0] BCD_seg,
	output logic COut,
	
	// INPUTs
	input clk, 
	input rst_n,
	input en,
	input Cin,
	input clr_val_reg
	);
	
	// NEXT Value dependent on if overflow to next BCD seg will occur after shift left
	logic [3:0] BCD_seg_next;
	assign BCD_seg_next = (BCD_seg >= 4'h5) ? (BCD_seg + 4'h3) : (BCD_seg);
	
	// Cout Bit for next segment's Cin based on MSB (SHIFT LEFT OUT)
	assign COut = BCD_seg_next[3];
	
	// BCD Value Register Continues shifting while conversion is enabled
	always_ff @(posedge clk) begin : BCD_SEG_REGISTER
		if (!rst_n) begin
			BCD_seg <= 4'h0;
		end
		else if (clr_val_reg) begin
			BCD_seg <= 4'h0;
		end
		else if (en) begin
			BCD_seg <= {BCD_seg_next[2:0], Cin};
		end
	end : BCD_SEG_REGISTER
endmodule