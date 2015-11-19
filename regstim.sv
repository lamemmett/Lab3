// Test bench for Register file
`timescale 1 ps / 100 fs

module regstim(); 		

	parameter ClockDelay = 5000;

	reg [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	reg [31:0] WriteData;
	reg RegWrite, clk;
	wire [31:0] ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile reg1(.ReadData1, .ReadData2, .WriteData, 
			  .ReadRegister1, .ReadRegister2, .WriteRegister,
			  .RegWrite, .clk);

	initial clk = 0;
	always begin
		#(ClockDelay/2); 
		clk = ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 0.
		// Register 0 should always be at the value of 0.
		RegWrite <= 0;
		ReadRegister1 <= 0;
		ReadRegister2 <= 0;
		WriteRegister <= 0;
		WriteData <= 32'hA0;				@(posedge clk);
		RegWrite <= 1;					@(posedge clk);

		// Write a value into each  register.
		for (i=1; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*32'h01020408;	@(posedge clk);
			RegWrite <= 1;				@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*32'h100+i;		@(posedge clk);
		end
		$stop;
	end
endmodule
