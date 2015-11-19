module regfile (ReadData1, ReadData2, WriteData, ReadRegister1,
					 ReadRegister2, WriteRegister, RegWrite, clk, rst);
	output [31:0] ReadData1, ReadData2;
	input [31:0] WriteData;
	input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input RegWrite, clk, rst;
	parameter WIDTH = 32;
	
	wire [31:0] enable;
	decoder5 d (.S(WriteRegister), .enable(RegWrite), .out(enable));
	
	wire [31:0] registerData [31:0];
	
	// Special Case: 0 Register
	register reg0 (.writeData(0), .enable(1'b1), .clk, .rst, .out(registerData[0]));
	
	genvar i;
	generate
		for(i=1; i<WIDTH; i++) begin : eachReg
			register regs (.writeData(WriteData), .enable(enable[i]), .clk, .rst,  .out(registerData[i]));
		end
	endgenerate
	
	mux32_32_32 mux1 (.in(registerData), .S(ReadRegister1), .out(ReadData1));
	mux32_32_32 mux2 (.in(registerData), .S(ReadRegister2), .out(ReadData2));
endmodule 

module regfile_testbench();
	wire [31:0] ReadData1, ReadData2;
	reg [31:0] WriteData;
	reg [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	reg RegWrite, clk, rst;
	
	regfile reg1(.ReadData1, .ReadData2, .WriteData, 
			  .ReadRegister1, .ReadRegister2, .WriteRegister,
			  .RegWrite, .clk, .rst);
	
	parameter t = 5;
	
	always #(t) clk = ~clk;
	
	initial begin
		clk = 0;
		RegWrite = 0;
		ReadRegister1 = 5'b00000;
		ReadRegister2 = 5'b00001;
		WriteRegister = 5'b00000;
		WriteData = 32'b11111111111111111111111111111111;
		#(4*t);
		
		// write to the zero register, check its output
		RegWrite = 1;
		#(4*t);
		assert (ReadData1 == 32'h00000000);
		
		ReadRegister1 = 5'b00010;
		
		// Write 32 0's to register 1
		WriteData = 32'b00000000000000000000000000000000;
		#(4*t);
		WriteRegister = 5'b00001;
		#(4*t);
		assert (ReadData2 == 32'h00000000);
		
		// Write 32 1's to register 1
		WriteData = 32'b11111111111111111111111111111111;
		#(4*t);
		assert (ReadData2 == 32'hFFFFFFFF);
		
		// Write 32 1's to register 2
		WriteRegister = 5'b00010;
		#(4*t);
		assert (ReadData1 == 32'hFFFFFFFF)
		
		// Disable write mode, attempt to write 32 0's to register 1
		WriteData = 32'b00000000000000000000000000000000;
		RegWrite = 0;
		WriteRegister = 5'b00001;
		#(4*t);
		assert (ReadData2 == 32'hFFFFFFFF);
		
		// Enable write mode, attempt to write 32 0's to register 1
		RegWrite = 1;
		#(4*t);
		assert (ReadData2 == 32'h00000000);
		
		// Write 32 0's to register 2
		WriteRegister = 5'b00010;
		#(4*t);
		assert (ReadData1 == 32'h00000000);
		
		// Write F0F0F0F0 to register 32 and read the value
		ReadRegister2 = 5'b11111;
		WriteData = 32'hF0F0F0F0;
		WriteRegister = 5'b11111;
		#(4*t);
		assert (ReadData2 == 32'hF0F0F0F0);
	end
endmodule 