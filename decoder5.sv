module decoder5 (S, enable, out);
	input [4:0] S;
	input enable;
	output [31:0] out;
	
	wire [3:0] v;
	
	decoder2 s (.S(S[4:3]), .enable(enable), .out(v));
	decoder3 b0 (.S(S[2:0]), .enable(v[0]), .out(out[7:0]));
	decoder3 b1 (.S(S[2:0]), .enable(v[1]), .out(out[15:8]));
	decoder3 b2 (.S(S[2:0]), .enable(v[2]), .out(out[23:16]));
	decoder3 b3 (.S(S[2:0]), .enable(v[3]), .out(out[31:24]));
endmodule 

module decoder5_testbench();
	reg [4:0] S; 
	reg enable;
	wire [31:0] out;
	
	decoder5 d (.S, .enable, .out);
	
	initial begin
		integer i;
		enable = 0;
		#10;
		enable = 1;
		for (i=0; i<32; i++) begin
			S = i;
			#10;
		end
	end
endmodule 