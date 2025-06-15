module TB_uart_rx_sampler();
	// Input DUT Interface
	logic clk_sample, clk_baud, RST_N, rx_bit, Err_clr;
	
	// Output DUT Interface
	logic [7:0] data_rx;
	logic data_valid, frame_err;


	// DUT Instantiation
	uart_rx_sampler_top iDUT(
		// INPUTs
		.clk_sample, 	// 16x Sample Clock
		.clk_baud, 		// Baud Clock
		.RST_N,			// Glocal Reset_n
		.rx_bit,		// Incoming Asynchronous RX Bit
		.Err_clr,		// Error Clear Flag Input
		
		// OUTPUTs
		.data_rx,	// Synchronized 8-Bit UART Payload
		.data_valid,	// Data Valid Flag for Payload
		.frame_err		// Error status for UART STOP Check
	);
	
	
	
	// Dummy 16x Oversample Clk
	always #2 clk_sample = ~clk_sample;
	
	// Dummy Baud Clk (div 16)
	always #32 clk_baud = ~clk_baud;
	
	// Dummy Stimulus Generation
	initial begin
		clk_sample = 1'b0;
		clk_baud = 1'b0;
		RST_N = 1'b0;
		rx_bit = 1'b1; // IDLE HI
		Err_clr = 1'b0;
		repeat(5) @(negedge clk_baud);
		
		// Start Packet with LOW
		RST_N = 1'b1;
		@(negedge clk_baud); // Let reset propagate
		rx_bit = 1'b0;
		@(negedge clk_baud);
		
		// Data Payload (all 1's)
		rx_bit = 1'b1;
		repeat(8) @(negedge clk_baud);
		
		// Stop Bit
		rx_bit = 1'b1;
		@(negedge clk_baud);
		
		// wait for some time to let the data flow through the flops
		repeat(6) @(negedge clk_baud);
		
		if (!data_valid) begin
			$display("ERRORS: Data Valid NOT Asserted.");
		end
		if (frame_err) begin
			$display("ERRORS: Frame Error Asserted.");
		end
		
		
		
		@(negedge clk_baud);
		
		
		
		// Start Packet with LOW
		RST_N = 1'b1;
		@(negedge clk_baud); // Let reset propagate
		rx_bit = 1'b0;
		@(negedge clk_baud);
		
		// Data Payload (all 1's)
		rx_bit = 1'b1;
		repeat(8) @(negedge clk_baud);
		
		// Stop Bit ERROR
		rx_bit = 1'b0;
		@(negedge clk_baud);
		
		if (data_valid) begin
			$display("ERRORS: Data Valid Asserted.");
		end
		if (!frame_err) begin
			$display("ERRORS: Frame Error NOT Asserted.");
		end
		
		@(negedge clk_baud);
		
		$stop();
	end
endmodule