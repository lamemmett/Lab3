module xor32(BussA, BussB, Output);
	input [31:0] BussA, BussB;
	output [31:0] Output;
	
	genvar i;
	generate
		for (i=0; i<32; i++) begin : eachXor
			xor xorNum (Output[i], BussA[i], BussB[i]);
		end
	endgenerate
endmodule 

module xor32_testbench();
	reg [31:0] BussA, BussB;
	wire [31:0] Output;
	parameter t = 10;
	
	xor32 thing (.BussA, .BussB, .Output);
	
	initial begin
		BussA = 32'h00000000;
		BussB = 32'h00000000;
		#t;
		BussA = 32'hFFFFFFFF;
		#t;
		BussB = 32'hFFFFFFFF;
		#t;
		BussB = 32'h0F0F0F0F;
		#t;
	end
endmodule 