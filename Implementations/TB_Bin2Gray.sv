////////////////////////////////////////////////////////////////////////////////
// Module: TB_Bin2Gray
// 
// Description: 
// - Testbench for exhaustive verification of Bin2Gray
////////////////////////////////////////////////////////////////////////////////
module TB_Bin2Gray ();
	// DUT Signal Interface
	localparam N = 8;
	logic [N-1 : 0] GraySignal, BinSignal;
	
	// DUT Instantiation
	Bin2Gray #(N) iDUT(.GraySignal(GraySignal), .BinSignal(BinSignal));
	
	// Function to Compare Adjacent values for 1-Bit Change
	function automatic bit compareAdjecent(logic [N-1 : 0] a, b);
		int num_ones = 0;
		logic [N-1 : 0] delta_mask = a ^ b;
		
		for (int i = 0; i < N; i++) begin
			if (delta_mask[i]) num_ones++;
		end
		
		if (num_ones == 1) return (1'b1);
		else return (1'b0);
	endfunction
	
	
	// Behavioral Verification
	int errorCnt;
	logic [N-1 : 0] previousGraySignal;
	initial begin
		// Initialize Previous Gray Code Result for 0 (Default Gray conversion for 0)
		previousGraySignal = 'h0;
		errorCnt = 0;
	
		// Iterate over all possible values and compare adjacent values
		for (logic [N : 0] i = 1; i < (2**N); i++) begin
			// Apply DUT Stimulus
			BinSignal = i; #1;
			
			// Verify Output
			if (!compareAdjecent(GraySignal, previousGraySignal)) begin
				errorCnt++;
				$display("- ERROR Converting (%d)", i);
			end
			
			// Save Previous Signal for Next Iteration
			#1; previousGraySignal = GraySignal; #1;
		end
		
		if (!errorCnt) begin
			$display("--- All Tests Passed ---");
		end
		else begin
			$display("--- %d Errors Occured ---", errorCnt);
		end
	end
endmodule