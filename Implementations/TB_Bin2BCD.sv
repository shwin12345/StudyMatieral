////////////////////////////////////////////////////////////////////////////////
// Module: TB_Bin2Gray
// 
// Description: 
// - Testbench for exhaustive verification of Bin2Gray
////////////////////////////////////////////////////////////////////////////////
module TB_Bin2BCD ();
	// DUT Signal Interface
	localparam N = 16; // Number of Bits in Binary Signal
	localparam M = 20; // Number of Bits in BCD Representation
	localparam m = (M + 1) / 4; // Number of BCD Segments in BCD Representation
	typedef int unsigned uint; // Uint Definition
	
	logic [M-1 : 0] data_out;
	logic done, new_ack, clk, rst_n, new_data;
	logic [N-1 : 0] data_in;
	
	// DUT Instantiation
	Bin2BCD #(.N(16), .M(20)) iDUT(
		// OUTPUTs
		.data_out(data_out),
		.done(done),
		.new_ack(new_ack),
		
		// INPUTs
		.clk(clk),
		.rst_n(rst_n),
		.data_in(data_in),
		.new_data(new_data));
	
	
	// Clock Generator
	always #2 clk = ~clk;
	
	
	// Function for comparing BCD Output from Input Binary Stimulus
	function automatic bit compareConversion(logic [N-1 : 0] a, logic [M-1 : 0] b);
		// Golden Value from Binary Input
		int trueValue = a;
		
		int BCDValue = 0;
		for (int i = 0; i < m; i++) begin
			// Cast BCD Value to respective decimal value
			BCDValue = BCDValue + (uint'(b[3:0]) * (10**i));
			b = (b>>4); // Down Shift BCD Segment for next iteration
		end
		
		if (BCDValue !== trueValue) begin
			return (1'b0); // Failure
		end
		else begin
			return (1'b1);
		end
	endfunction
	
	
	// Task for initiating Bin2BCD Conversion & Checking Outputs
	task automatic invokeConversion();
		// Random Input Binary Value
		@(posedge clk); 
		data_in = $urandom();
		
		// Input Sequence
		new_data = 1'b1; #1;
		if (new_ack !== 1'b1) begin
			$display("- ERROR: NewAck Flag NOT Asserted Initially");
		end
		@(posedge clk); // Registered Data
		
		#1; if (new_ack === 1'b1) begin
			$display("- ERROR: NewAck Flag Asserted Late");
		end
		@(negedge clk);
		new_data = 1'b0;
		
		// Wait for N-Cycle Conversion
		repeat(N) @(posedge clk); 
		
		// Check Done Flag
		#1; if (done !== 1'b1) begin
			$display("- ERROR: Done Flag NOT Asserted After %d Cycles", N);
		end
		
		// Check Data
		#1; if (compareConversion(data_in, data_out) !== 1'b1) begin
			$display("- ERROR: Incorrect Comparison for Bin (%b), BCD(%b)", data_in, data_out);
		end
		else begin
			$display("- Correct Comparison for Bin (%b), BCD(%b)", data_in, data_out);
		end
		@(posedge clk); 
	endtask
	
	
	// Stimulus Generation
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		data_in = 'h0;
		new_data = 1'b0;
		repeat(5) @(negedge clk);
		rst_n = 1'b1;
		data_in = 0;
		invokeConversion();
		invokeConversion();
		invokeConversion();
		$stop();
	end
endmodule