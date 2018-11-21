`timescale 1ns / 1ps

module FPWrapper(
	input Clk,
	input Rst,
	input [1:0] A,
	input WE,
	input [31:0] InData,
	output done_sig,
	output [31:0] OutData
	);

wire we0, we1, we2, DONE;
wire Start, StartCmb, StartPulse,DoneDelay, RegStart; 
wire OF, UF, NANF, INFF, DNF, ZF, ResOF, ResUF, ResNANF, ResINFF, ResDNF, ResZF, ResDone;
wire [1:0] out_decoder;
wire [31:0] OpA, OpB, P, ResP;

assign done_sig = DONE;

//Address Decoder
fpmul_addr_decoder FPdec(WE, A, we0, we1, we2, out_decoder);

//Output Mux
Mux #( .INPUTS(4), .WIDTH(32))
	FPWrapper_out_mux_inst(
		.sel(out_decoder), 
		.in({{15'b0,Start,2'b0,ResOF,ResUF,ResNANF,ResINFF,ResDNF,ResZF,7'b0, ResDone}, // 11
				{ResP}, // 10
				{OpB}, // 01
				{OpA}  // 00 
		}), 
		.out(OutData)
	);
						

DRegister #( .WIDTH(32))
	OpA_reg_inst(
		.Clk(Clk), .Rst(Rst), .en(we0), .d(InData), .q(OpA)
	);

DRegister #( .WIDTH(32))
	OpB_reg_inst(
		.Clk(Clk), .Rst(Rst), .en(we1), .d(InData), .q(OpB)
	);
//***Start signal to FPMUL
DRegister #( .WIDTH(1))
	Start_reg_inst(
		.Clk(Clk), .Rst(Rst), .en(we2), .d(InData[16]), .q(Start)
	);

assign StartCmb = we2 & InData[16];

DRegister #(.WIDTH(1)) Start_reg2 (Clk, Rst, 1'b1, StartCmb, RegStart);
DRegister #(.WIDTH(1)) DelayReg (Clk, Rst, 1'b1, DONE, DoneDelay);

assign StartPulse = RegStart & (~DoneDelay);

//*****

FPMUL FPMUL_module(Clk, Rst, StartPulse, OpA, OpB, DONE, P, OF, UF, NANF, INFF, DNF, ZF);

DRegister #( .WIDTH(38))
	FPM_out_reg_inst(
		.Clk(Clk), .Rst(Rst), .en(DONE), .d({P,OF,UF,NANF,INFF,DNF,ZF}), .q({ResP, ResOF, ResUF, ResNANF, ResINFF, ResDNF, ResZF})
	);

rsreg FPM_rsreg_inst(
		.Clk(Clk), .set(DONE), .Rst(StartCmb), .q(ResDone)
);

endmodule

module rsreg
(
	input Clk, 
	input set, 
	input Rst, 
	output reg q
);
    always @ (posedge Clk, posedge Rst)
    begin
        if(Rst) q <=0;
        else if(set) q <= 1;
        else q <= q;
    end
endmodule
