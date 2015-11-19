module mux32_32_32(in, S, out);
	input [31:0] in [31:0];
	input [4:0] S;
	output [31:0] out;
	
	wire [31:0] temp [31:0];
	
	genvar i, j;
	
	for (i=0; i<32; i++) begin
		for (j=0; j<32; j++) begin
			assign temp[i][j] = in[j][i];	// temp holds the input with swapped indices
		end
	end
	
	generate
		for(i=0; i<32; i++) begin : eachMux
			mux32_1 muxNum (.in(temp[i]), .S(S), .out(out[i])); 
		end
	endgenerate
endmodule

module mux32_32_32_testbench();
	reg [31:0] in [31:0];
	reg [4:0] S;
	wire [31:0] out;
	
	mux32_32_32 dut (.in, .S, .out);
	
	integer i, j;
	initial begin
		for (i = 0; i < 32; i++) begin
			in[i] = 32'b00000000000000000000000000000000;
		end
		i = 0;
		in[0] = 32'b01101101101101101101101101101101;
		in[1] = 32'b11111111111111111111111111111111;
		in[2] = 32'b00000000000000000000000000000000;
		in[3] = 32'b11111111111111111111111111111111;
		S = 5'b00000;
		#10;
		S = 5'b00001;
		#10;
		S = 5'b00010;
		#10;
		S = 5'b00011;
		#10;
	end
endmodule 