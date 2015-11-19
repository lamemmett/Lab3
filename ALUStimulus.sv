// Test bench for ALU file
`timescale 1 ps / 100 fs

module ALUStimulus();

	parameter ClockDelay = 100000;
	parameter t = 100000;
	reg [31:0] BussA, BussB;
	reg [1:0] ALUControl;

	wire [31:0] Output;
	wire zero, overflow, CarryOut, negative;

	integer i;

	// If your register file module is not named "alu" then you will
	// have to change the following line in order to create an instance of
	// your register file.  Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	alu alu1(.Output, .CarryOut, .zero, .overflow, .negative, .BussA, .BussB, .ALUControl);

	initial begin

		/* Addition unit testing */
		ALUControl=00; 
		BussA=32'h00000DEF; BussB=32'h00000ABC; #(ClockDelay); // Should output 000018AB
		BussA=32'h00001234; BussB=32'h00000105; #(ClockDelay); // Should output 00001339
		BussA=32'h7FFFFFFF; BussB=32'h00000001; #(ClockDelay); // Should output 80000000, overflow, negative
		
		/* Subtraction unit testing */
		ALUControl=10; 
		BussA=32'h00000DEF; BussB=32'h00000ABC; #(ClockDelay); // Should output 00000333	
		BussA=32'h00001234; BussB=32'h00000105; #(ClockDelay); // Should output 0000112F
		BussA=32'h80000000; BussB=32'h00000001; #(ClockDelay); // Should output 7FFFFFFF, overflow

		/* You should test your units EXTENSIVELY here.  We just gave a few ideas
         above to get you started.  Make sure you've checked all outputs for all
         "interesting" cases. */
			
		// Adder test: 0+1=1
		BussA = 32'h00000000;
		BussB = 32'h00000001;
		ALUControl = 2'b00; #t;
		assert (Output == 1)
		// check flags
		assert (negative == 0 && overflow == 0 && zero == 0);
		
		// Subtraction test: 0-1=-1
		ALUControl = 2'b10; #t;
		assert (Output == -1);
		// check flags
		assert (negative == 1 && overflow == 0 && zero == 0);
		
		// SLT test: 0<1==1
		ALUControl = 2'b11; #t;
		assert (Output == 1 && negative == 0 && zero == 0);
		
		// SLT test: 2<1==0
		BussA = 32'h00000002; #t;
		assert (Output == 0 && negative == 0 && zero == 1);
		
		// Xor test: 0 ^ 0  = 0;
		BussA = 32'h00000000;
		BussB = 32'h00000000;
		ALUControl = 2'b01; #t;
		assert (Output == 0 && negative == 0 && zero == 1);
		
		// Xor test: 0xF0F0F0F0 ^ 0x0F0F0F0F == 0xFFFFFFFF
		BussA = 32'hF0F0F0F0;
		BussB = 32'h0F0F0F0F; #t;
		assert (Output == 32'hFFFFFFFF && negative == 1 && zero == 0);
		
		// Xor test: 0xFFFFFFFF ^ 0x0F0F0F0F == 0xF0F0F0F0
		BussA = 32'hFFFFFFFF; #t;
		assert (Output == 32'hF0F0F0F0 && negative == 1 && zero == 0);
		
		// Overflow tests:
		// positive overflow
		ALUControl = 2'b00;
		BussA = 32'h7FFFFFFF;
		BussB = 32'h00000001; #t;
		assert (negative == 1 && overflow == 1);
		// negative overflow
		ALUControl = 2'b10;
		BussA = 32'h80000000;
		BussB = 32'h00000001; #t;
		assert (negative == 0 && overflow == 1);
		
		// Carryout + overflow test
		ALUControl = 2'b00;
		BussA = 32'h80000000;
		BussB = 32'h80000000; #t;
		assert (negative == 0 && overflow == 1 && negative == 0 && zero == 1 && CarryOut == 1);
	end
endmodule
