module fullAdder (A, B, Cin, Cout, Out);
	input A, B, Cin;
	output Cout, Out;
	
	wire a, b, c, d;
	
	and and1 (a, A, B);
	and and2 (b, A, Cin);
	and and3 (c, B, Cin);
	or or1 (Cout, a, b, c);
	
	xor (Out, A, B, Cin);
endmodule 

module fullAdder_testbench();
	reg A, B, Cin;
	wire Cout, Out;
	parameter t = 10;
	
	fullAdder adder (.A, .B, .Cin, .Cout, .Out);
	
	initial begin
		integer i;
		for (i=0; i<8; i++) begin
			{A, B, Cin} = i;
			#t;
		end
	end
endmodule 