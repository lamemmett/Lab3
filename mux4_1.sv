module mux4_1(out, in, sel);
	output out;
	input [3:0] in;
	input [1:0] sel;

	wire v0, v1;
	
	mux2_1 m0(.out(v0), .in(in[1:0]), .sel(sel[0]));
	mux2_1 m1(.out(v1), .in(in[3:2]), .sel(sel[0]));
	mux2_1 m (.out(out), .in({v1, v0}), .sel(sel[1]));
endmodule

module mux4_1_testbench();
	reg [3:0] in;
	reg [1:0] sel;
	wire out;
	
	mux4_1 dut (.out, .in, .sel);
	
	integer i;
	initial begin
		for(i=0; i<64; i++) begin
			{sel, in} = i; #10;
		end
	end
endmodule 