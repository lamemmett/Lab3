module register (writeData, enable, clk, rst, out);
	input [31:0] writeData;
	input enable, clk, rst;
	output [31:0] out;
	
	parameter WIDTH = 32;

	wire [31:0] d;
	genvar i;
	
	generate
		for(i=0; i<WIDTH; i++) begin : eachDff
			mux2_1 m (.out(d[i]), .in({writeData[i], out[i]}), .sel(enable));
			D_FF flipFlop (.q(out[i]), .d(d[i]), .reset(rst), .clk(clk));
		end
	endgenerate
endmodule 

module register_testbench();
	reg [31:0] writeData;
	reg clk, enable;
	wire [31:0] out;
	
	register r (.writeData, .enable, .clk, .out);

	always #(10) clk = ~clk;
	
	initial begin
		clk = 0;
		writeData = 32'b11111111111111111111111111111111;
		enable = 1;
		#40;
		writeData = 32'b10101010101010101010101010101010;
		#40;
		enable = 0;
		writeData = 32'b00000000000000000000000000000000;
		#40;
		enable = 1;
		#40;
	end
endmodule 