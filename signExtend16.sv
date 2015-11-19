module signExtend16(Output, in);
	input [15:0] in;
	output [29:0] Output;
	
	assign Output = {in[15], in[15], in[15],
						  in[15], in[15], in[15],
						  in[15], in[15], in[15],
						  in[15], in[15], in[15],
						  in[15], in[15], in};
endmodule 