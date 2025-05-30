////////////////////////////////////////////////////////////////////////////////
// Module: Bin2Gray
// 
// Description: 
// - Module to convert an input N-Bit Binary Value into a valid N-Bit Gray Code
//		Signal
//
// Parameters:
// - N: Bit Width of Values being converted
// Inputs:
// - BinSignal: Input Binary Signal to be converted
// Outputs:
// - GraySignal: Valid Gray Code Signal
////////////////////////////////////////////////////////////////////////////////
module Bin2Gray #(parameter N = 16) (
	// OUTPUTs
	output logic [N-1 : 0] GraySignal,
	
	//INPUTs
	input [N-1 : 0] BinSignal);
	
	// Implementation of Basic Gray Code Conversion
	assign GraySignal = BinSignal ^ (BinSignal >> 1); // Bi ^ B(i+1) for all i
endmodule