module alu (Output, CarryOut, zero, overflow, negative, BussA, BussB, ALUControl);
	input [31:0] BussA, BussB;
	input [1:0] ALUControl;
	output CarryOut, zero, overflow, negative;
	output [31:0] Output;
	
	wire [31:0] adderResult, xorResult, sltResult;
	
	// Compute adder/subtract result, control bit selects addition or subtraction operation
	//		- This also sets the overflow and carryout flags
	adder32 adder (.op1(BussA), .op2(BussB), .control(ALUControl[1]), .Output(adderResult), .overflow, .CarryOut);
	
	// Compute Xor result on BussA and BussB inputs
	xor32 xorThing (.BussA, .BussB, .Output(xorResult));
	
	// Compute SLT result, is equal to the negative flag padded with leading 0's
	wire sltTempResult;
	xor sltGate (sltTempResult, adderResult[31], overflow);
	assign sltResult = {31'b0, sltTempResult};
	
	// Use muxes and select signals to choose desired output as determined by ALUControl input
	genvar i;
	generate
		for (i=0; i<32; i++) begin : eachMux
			mux4_1 muxNum (.out(Output[i]), .in({sltResult[i], adderResult[i], xorResult[i], adderResult[i]}), .sel(ALUControl));
		end
	endgenerate
	
	// Set negative and zero flags based on arithmetic result
	assign negative = Output[31];
	setZeroFlag z(.out(zero), .in(Output));
endmodule
 
module alu_testbench();
	wire [31:0] Output;
	wire CarryOut, zero, overflow, negative;
	reg [31:0] BussA, BussB;
	reg [1:0] ALUControl;
	parameter t = 10;
	
	alu thing (.Output, .CarryOut, .zero, .overflow, .negative, .BussA, .BussB, .ALUControl);
	
	initial begin
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