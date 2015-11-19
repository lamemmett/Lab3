module adder30carryIn(Output, op1, op2, CI);
	input [29:0] op1, op2;
	input CI;
	output [29:0] Output;
	
	wire [29:0] carryOuts;
	
	fullAdder adder (.A(op1[0]), .B(op2[0]), .Cin(CI), .Cout(carryOuts[0]), .Out(Output[0]));
	
	genvar i;
	generate
		for(i=1; i<30; i++) begin : eachAdder
			fullAdder adderNum (.A(op1[i]), .B(op2[i]), .Cin(carryOuts[i-1]), .Cout(carryOuts[i]), .Out(Output[i]));
		end
	endgenerate
endmodule 

module adder30carryIn_testbench();
	reg [29:0] op1, op2;
	reg CI;
	wire [29:0] Output;
	parameter t = 10;
	
	adder30carryIn adder (.Output, .op1, .op2, .CI);
	
	initial begin
		// 0 + 1 = 1
		CI = 1;
		op1 = 30'h00000000;
		op2 = 30'h00000001;
		#t;
		assert (Output == 2);
		
		// 1 + 1 = 2
		op1 = 30'h00000001;
		#t;
	end
endmodule 