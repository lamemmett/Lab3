module datapath (clk, rst);
	input clk, rst;
	
	wire [31:0] instruction, Da, Db;
	wire [15:0] imm16;
	wire [4:0] rs, rt, rd;
	wire [5:0] opcode, func;
	
	reg [1:0] ALUcntrl;
	reg branch, jump, jr, zero, MemWr, MemToReg, ALUSrc, RegWr, RegDst;

	assign opcode 	= instruction[31:26];
	assign rs 		= instruction[25:21];
	assign rt 		= instruction[20:16];
	assign rd		= instruction[15:11];
	assign imm16 	= instruction[15:0];
	assign func		= instruction[5:0];
	
	// STAGE 1: INSTRUCTION FETCH
	wire [4:0] RegDstMuxOut;
	wire [31:0] MemToRegMuxOut;
	
	instructionFetchUnit iunit (.Output(instruction), .branch, .jump, .jr, .zero, .Da(Da[31:2]), .clk, .rst);
	
	//	STAGE 2: REGISTER READ
	regfile registers (.ReadData1(Da), .ReadData2(Db), .WriteData(MemToRegMuxOut), .ReadRegister1(rs),
					 .ReadRegister2(rt), .WriteRegister(RegDstMuxOut), .RegWrite(RegWr), .clk, .rst);
	genvar i;
	generate
		for (i=0; i<5; i++) begin : eachMux0
			mux2_1 muxNum0 (.out(RegDstMuxOut[i]), .in({{rd[i], rt[i]}}), .sel(RegDst));
		end
	endgenerate
	
	// STAGE 3: EXECUTE
	wire [31:0] ALUSrcMuxOut;
	wire [29:0] temp;
	wire [31:0] SEresult = {temp[29], temp[29], temp};
	
	signExtend16 SE (.Output(temp), .in(imm16));
	
	genvar j;
	generate
		for (j=0; j<32; j++) begin : eachMux1
			mux2_1 muxNum1 (.out(ALUSrcMuxOut[j]), .in({SEresult[j], Db[j]}), .sel(ALUSrc));
		end
	endgenerate
	
	wire [31:0] ALUresult;
	wire [2:0] dontCare;
	alu alu0 (.Output(ALUresult), .CarryOut(dontCare[0]), .zero, .overflow(dontCare[1]), 
				 .negative(dontCare[2]), .BussA(Da), .BussB(ALUSrcMuxOut), .ALUControl(ALUcntrl));
	
	// STAGE 4: MEMORY
	wire [31:0] memDataOut;
	dataMem dataMemUnit (.data(memDataOut), .address(ALUresult), .writedata(Db), .writeenable(MemWr), .clk);
	
	// STAGE 5: REGISTER WRITE-BACK
	genvar k;
	generate
		for (i=0; i<32; i++) begin : eachMux
			mux2_1 muxNum1 (.out(MemToRegMuxOut[i]), .in({memDataOut[i], ALUresult[i]}), .sel(MemToReg));
		end
	endgenerate
	
	/*
		CONTROL LOGIC
	LW		:	100011
	SW		:	101011
	J		:	000010
	JR		:	000000 ... 001000
	BNE	:	000101
	XORI	:	001110
	ADD	:	000000 ... 100000
	SUB	:	000000 ... 100010
	SLT 	:	000000 ... 101010
	*/
	
	parameter [5:0] LW 	= 6'b100011;
	parameter [5:0] SW 	= 6'b101011;
	parameter [5:0] J	 	= 6'b000010;
	parameter [5:0] JR 	= 6'b001000;
	parameter [5:0] BNE	= 6'b000101;
	parameter [5:0] XORI	= 6'b001110;
	parameter [5:0] ADD	= 6'b100000;
	parameter [5:0] SUB	= 6'b100010;
	parameter [5:0] SLT	= 6'b101010;
	parameter [5:0] RTYPE= 6'b000000;
	
	// control logic
	always @(instruction) begin
		case (opcode)
			LW:	begin
					RegDst = 0;
					RegWr = 1;
					branch = 0;
					jump = 0;
					jr = 0;
					ALUcntrl = 2'b00;
					ALUSrc = 1;
					MemWr = 0;
					MemToReg = 1;
					end
			SW:	begin
					RegDst = 0;
					RegWr = 0;
					branch = 0;
					jump = 0;
					jr = 0;
					ALUcntrl = 2'b00;
					ALUSrc = 1;
					MemWr = 1;
					MemToReg = 0;
					end
			J:		begin
					RegDst = 0;
					RegWr = 0;
					branch = 0;
					jump = 1;
					jr = 0;
					ALUcntrl = 2'b00;
					ALUSrc = 1;
					MemWr = 0;
					MemToReg = 0;
					end
			BNE:	begin
					RegDst = 0;
					RegWr = 0;
					branch = 1;
					jump = 0;
					jr = 0;
					ALUcntrl = 2'b10;
					ALUSrc = 0;
					MemWr = 0;
					MemToReg = 1;
					end
			XORI:	begin
					RegDst = 0;
					RegWr = 1;
					branch = 0;
					jump = 0;
					jr = 0;
					ALUcntrl = 2'b01;
					ALUSrc = 1;
					MemWr = 0;
					MemToReg = 0;
					end
			RTYPE: begin 
				case (func)
					JR:	begin		// NEEDS WORK
						RegDst = 0;
						RegWr = 0;
						branch = 0;
						jump = 0;
						jr = 1;
						ALUcntrl = 2'b00;
						ALUSrc = 1;
						MemWr = 0;
						MemToReg = 0;
						end
					ADD:	begin
						RegDst = 1;
						RegWr = 1;
						branch = 0;
						jump = 0;
						jr = 0;
						ALUcntrl = 2'b00;
						ALUSrc = 0;
						MemWr = 0;
						MemToReg = 0;
						end
					SUB:	begin
						RegDst = 1;
						RegWr = 1;
						branch = 0;
						jump = 0;
						jr = 0;
						ALUcntrl = 2'b10;
						ALUSrc = 0;
						MemWr = 0;
						MemToReg = 0;
						end
					SLT:	begin
						RegDst = 1;
						RegWr = 1;
						branch = 0;
						jump = 0;
						jr = 0;
						ALUcntrl = 2'b11;
						ALUSrc = 0;
						MemWr = 0;
						MemToReg = 0;
						end
				endcase
			end
		endcase
	end
endmodule 

module datapath_testbench();
	reg clk, rst;
	parameter t = 2000;
	
	datapath test (.clk, .rst);
	
	always #(t) clk = ~clk;
	
	initial begin
		clk = 0;
		rst = 1;
		#(3*t);
		rst = 0;
		#(10*t);
	end
endmodule 