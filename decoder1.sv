module decoder1 (S, enable, out);
	input S, enable;
	output [1:0] out;
	
	assign out[0] = ~S & enable;
	assign out[1] = S & enable;
endmodule 

module decoder1_testbench();
	reg S, enable;
	wire [1:0] out;
	
	decoder1 d (.S, .enable, .out);
	
	initial begin
		integer i;
		enable = 0;
		#10;
		enable = 1;
		for (i=0; i<2; i++) begin
			S = i;
			#10;
		end
	end
endmodule 