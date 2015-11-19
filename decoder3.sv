module decoder3 (S, enable, out);
	input [2:0] S;
	input enable;
	output [7:0] out;
	
	wire [1:0] v;
	
	decoder1 s (.S(S[2]), .enable(enable), .out(v));
	decoder2 b0 (.S(S[1:0]), .enable(v[0]), .out(out[3:0]));
	decoder2 b1 (.S(S[1:0]), .enable(v[1]), .out(out[7:4]));
endmodule 

module decoder3_testbench();
	reg [2:0] S; 
	reg enable;
	wire [7:0] out;
	
	decoder3 d (.S, .enable, .out);
	
	initial begin
		integer i;
		enable = 0;
		#10;
		enable = 1;
		for (i=0; i<16; i++) begin
			S = i;
			#10;
		end
	end
endmodule 