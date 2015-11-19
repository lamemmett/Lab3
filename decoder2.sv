module decoder2 (S, enable, out);
	input [1:0] S;
	input enable;
	output [3:0] out;
	
	wire [1:0] v;
	
	decoder1 s (.S(S[1]), .enable(enable), .out(v));
	decoder1 b0 (.S(S[0]), .enable(v[0]), .out(out[1:0]));
	decoder1 b1 (.S(S[0]), .enable(v[1]), .out(out[3:2]));
endmodule 

module decoder2_testbench();
	reg [1:0] S; 
	reg enable;
	wire [3:0] out;
	
	decoder2 d (.S, .enable, .out);
	
	initial begin
		integer i;
		enable = 0;
		#10;
		enable = 1;
		for (i=0; i<4; i++) begin
			S = i;
			#10;
		end
	end
endmodule 