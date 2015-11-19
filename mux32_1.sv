module mux32_1(in, S, out);
	input [31:0] in;
	input [4:0] S;
	output out;

	wire v0, v1;
	
	mux16_1 m0 (.in(in[15:0]), .S(S[3:0]), .out(v0));
	mux16_1 m1 (.in(in[31:16]), .S(S[3:0]), .out(v1));
	mux2_1 m (.out(out), .in({v1, v0}), .sel(S[4]));
endmodule

module mux32_1_testbench();
	reg [31:0] in;
	reg [4:0] S;
	wire out;
	
	mux32_1 dut (.in, .S, .out);
	
	integer i, j;
	initial begin
		in = 32'b0000000000000000zz;
		S = 5'b00000;
		#10;
		in = 32'b0000000000000001;
		#10;
		S = 5'b00001;
		#10;
		
		for (i=1; i<32; i++) begin
			in = in << 1;
			#10;
			assert(out == 1);
			S += 1;
			#10;
			assert(out == 0);
		end
	end
endmodule 