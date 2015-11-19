module adder32(op1, op2, control, Output, overflow, CarryOut);
	input [31:0] op1, op2;
	input control;
	output [31:0] Output;
	output overflow, CarryOut;
	
	wire [31:0] carryOuts;
	wire [31:0] notOp2;
	wire [31:0] selectedOp2;
	
	// compute the inversion of op2
	genvar j;
	generate
		for (j=0; j<32; j++) begin : eachNot
			not notNum (notOp2[j], op2[j]);
		end
	endgenerate 
	
	// Edge Case: LSB of adder has carry in of 0
	// Must also use a mux to decide whether in subtract or add mode
	mux2_1 mux1 (.out(selectedOp2[0]), .in({notOp2[0], op2[0]}), .sel(control));
	fullAdder adder (.A(op1[0]), .B(selectedOp2[0]), .Cin(control), .Cout(carryOuts[0]), .Out(Output[0]));
	
	genvar i;
	generate
		for(i=1; i<32; i++) begin : eachAdder
			mux2_1 muxNum (.out(selectedOp2[i]), .in({notOp2[i], op2[i]}), .sel(control));
			fullAdder adderNum (.A(op1[i]), .B(selectedOp2[i]), .Cin(carryOuts[i-1]), .Cout(carryOuts[i]), .Out(Output[i]));
		end
	endgenerate
	
	// compute overflow and carryout flags
	xor xor1 (overflow, carryOuts[31], carryOuts[30]);
	assign CarryOut = carryOuts[31];
endmodule 

module adder32_testbench();
	reg [31:0] op1, op2;
	reg control;
	wire [31:0] Output;
	wire overflow, CarryOut;
	parameter t = 10;
	
	adder32 adder (.op1, .op2, .control, .Output, .overflow, .CarryOut);
	
	initial begin
		// 0 + 1 = 1
		op1 = 32'h00000000;
		op2 = 32'h00000001;
		control = 0;
		#t;
		assert (Output == 1);
		
		// 1 + 1 = 2
		op1 = 32'h00000001;
		#t;
		
		// 1 - 1 = 0
		control = 1;
		#t;
		
		//8 - 1 = 7
		op1 = 32'h00000008;
		#t;
		
		// 8 - 4 = 4
		op2 = 32'h00000004;
		#t;
		
		// 8 + 4 = 12
		control = 0;
		#t;
		
		// 0 - 4 = -4
		op1 = 32'h00000000;
		control = 1;
		#t;
	end
endmodule 