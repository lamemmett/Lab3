module instructionFetchUnit(Output, branch, jump, jr, zero, Da, clk, rst);
	input branch, jump, jr, zero, clk, rst;
	input [29:0] Da;
	output [31:0] Output;
	genvar i;
	
	// Program counter, b0ottom two bits are ignored
	wire [29:0] PC, signExtendResult, branchMuxResult, 
					concatResult, adderResult, jumpMuxResult, jrMuxResult;
	wire branchZeroAnd;
	wire [25:0] targetInstr = Output[25:0];
	wire [15:0] imm16 = Output[15:0];
	
	// branch/immediate result (stuff that feeds into the adder)
	signExtend16 SE (.Output(signExtendResult), .in(imm16));
	and (branchZeroAnd, branch, ~zero);
	assign concatResult = {PC[29:26], targetInstr};
	generate
		for (i=0; i<30; i++) begin : eachBit
			// Select each of the 30 bits based on AND result
			mux2_1 eachMux1 (.out(branchMuxResult[i]), .in({signExtendResult[i], 1'b0}), .sel(branchZeroAnd));
			
			mux2_1 eachMux2 (.out(jumpMuxResult[i]), .in({concatResult[i], adderResult[i]}), .sel(jump));
			
			mux2_1 eachMux3 (.out(jrMuxResult[i]), .in({Da[i], jumpMuxResult[i]}), .sel(jr));
			
			// program counter state-holding units
			D_FF bitNum (.q(PC[i]), .d(jrMuxResult[i]), .reset(rst), .clk);
		end
	endgenerate
	
	adder30carryIn adder (.Output(adderResult), .op1(PC), .op2(branchMuxResult), .CI(1'b1));

	// relay PC to instruction memory to retrieve actual instruction
	InstructionMem iunit (Output, {PC, 2'b00});
endmodule 

module instructionFetchUnit_testbench();
	reg branch, jump, jr, zero, clk, rst;
	reg [29:0] Da;
	wire [31:0] Output;
	
	parameter t = 2000;
	
	always #(t/2) clk = ~clk;
	
	instructionFetchUnit test (.Output, .branch, .jump, .zero, .clk, .rst);
	
	initial begin
		clk = 0;
		rst = 1;
		branch = 0;
		jump = 0;
		zero = 0;
		#(3*t);
		branch = 1;
		rst = 0;
		#t;
		branch = 0;
	end
endmodule 