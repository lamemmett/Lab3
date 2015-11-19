module mux2_1(out, in, sel);
	output out;
	input [1:0] in;
	input sel;
	
	wire v0, v1, notSel;
	not (notSel, sel);
	and (v0, in[1], sel);
	and (v1, in[0], notSel);
	or (out, v0, v1);
endmodule

module mux2_1_testbench();
	reg [1:0] in;
	reg sel;
	wire out;
	
	mux2_1 dut (.out, .in, .sel);
	
	initial begin
		sel=0; in[0]=0; in[1]=0; #10;
		sel=0; in[0]=0; in[1]=1; #10;
		sel=0; in[0]=1; in[1]=0; #10;
		sel=0; in[0]=1; in[1]=1; #10;
		sel=1; in[0]=0; in[1]=0; #10;
		sel=1; in[0]=0; in[1]=1; #10;
		sel=1; in[0]=1; in[1]=0; #10;
		sel=1; in[0]=1; in[1]=1; #10;
	end
endmodule 