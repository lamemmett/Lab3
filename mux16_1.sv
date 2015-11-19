module mux16_1(in, S, out);
	input [15:0] in;
	input [3:0] S;
	output out;

	wire v0, v1, v2, v3;
	
	mux4_1 m0(.out(v0), .in(in[3:0]), .sel({S[1:0]}));
	mux4_1 m1(.out(v1), .in(in[7:4]), .sel({S[1:0]}));
	mux4_1 m2(.out(v2), .in(in[11:8]), .sel({S[1:0]}));
	mux4_1 m3(.out(v3), .in(in[15:12]), .sel({S[1:0]}));
	mux4_1 m (.out(out), .in({v3, v2, v1, v0}), .sel(S[3:2]));
endmodule

module mux16_1_testbench();
	reg [15:0] in;
	reg [3:0] S;
	wire out;
	
	mux16_1 dut (.in, .S, .out);
	
	integer i;
	initial begin
		for(i=0; i<1048576; i++) begin
			{S, in} = i; #10;
		end
	end
endmodule 