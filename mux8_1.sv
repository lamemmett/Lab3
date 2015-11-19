module mux16_1(out, sel0, sel1, sel2, sel3,
				  i00, i01, i10, i11);
	output out;
	input sel0, sel1, sel2, sel3;
	input i000, i00

	wire v0, v1, v2, v3;
	
	mux4_1 m0(.out(v0), .i0(i00), .i1(i01), .sel(sel0));
	mux2_1 m (.out(out), .i0(v0), .i1(v1), .sel(sel1));
endmodule

module mux8_1_testbench();
	reg i00, i01, i10, i11, sel0, sel1;
	wire out;
	
	mux4_1 dut (.out, .i00, .i01, .i10, .i11, .sel0, .sel1);
	
	integer i;
	initial begin
		for(i=0; i<64; i++) begin
			{sel1, sel0, i00, i01, i10, i11} = i; #10;
		end
	end
endmodule 