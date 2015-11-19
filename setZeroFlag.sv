module setZeroFlag (out, in);
	input [31:0] in;
	output out;

	wire [7:0] temp;
	
	// zero flag = nor of all input bits
	genvar i;
	generate
		for (i=0; i<32; i+=4) begin
			nor nor1 (temp[i/4], in[i], in[i+1], in[i+2], in[i+3]);
		end
	endgenerate
	
	and and1 (out, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7]);
endmodule 

module setZeroFlag_testbench();
	reg [31:0] in;
	wire out;
	parameter t = 10;
	
	setZeroFlag tester (.out, .in);
	
	integer i;
	initial begin
		in = 32'b0;
		#t;
		in++;
		
		for (i=1; i<32; i++) begin
			#t;
			in *= 2;
		end
		#t;
		in = 32'b0;
		#(10*t);
	end
endmodule 