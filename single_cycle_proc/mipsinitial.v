//------------------------------------------------
// Source Code for a Single-cycle MIPS Processor (supports partial instruction)
// Developed by D. Hung, D. Herda and G. Gerken,
// based on the following source code provided by
// David_Harris@hmc.edu (9 November 2005):
//    mipstop.v
//    mipsmem.v
//    mips.v
//    mipsparts.v
//------------------------------------------------

// Main Decoder
module maindec(
    input   [5:0]   op,
    output          memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, jalsel,
    output  [1:0]   aluop, 
    output          status_write ); //added for vectored interrupt

    reg     [10:0]  controls;

    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, jalsel, aluop, status_write} = controls;

    always @(*)
        case(op)
            6'b000000: controls <= 11'b11000000100; //Rtype
            6'b100011: controls <= 11'b10100100000; //LW
            6'b101011: controls <= 11'b00101000000; //SW
            6'b000100: controls <= 11'b00010000010; //BEQ
            6'b001000: controls <= 11'b10100000000; //ADDI
            6'b000010: controls <= 11'b00000010000; //J
            6'b000011: controls <= 11'b10000011000; //JAL
            6'b111110: controls <= 11'b00000010101; //JEPC
            default:   controls <= 11'bxxxxxxxxxx; //???
        endcase
endmodule

// ALU Decoder
module aludec(
    input	[5:0]	funct,
    input	[1:0]	aluop,
    output			select_result, hi_lo, hi_lo_load, alu_jump,
			[2:0]	alucontrol );

    reg		[6:0]	controls;
    
    assign {alucontrol, select_result, hi_lo, hi_lo_load, alu_jump} = controls;

    always @(*)
        case(aluop)
            2'b00: controls <= 7'b0100000;  // add
            2'b01: controls <= 7'b1100000;  // sub
            default: case(funct)          // RTYPE
                6'b100000: controls <= 7'b0100000; // ADD
                6'b100010: controls <= 7'b1100000; // SUB
                6'b100100: controls <= 7'b0000000; // AND
                6'b100101: controls <= 7'b0010000; // OR
                6'b101010: controls <= 7'b1110000; // SLT
                6'b011010: controls <= 7'bxxx1x10; // MULTU
                6'b010000: controls <= 7'bxxx1000; // MFHI
                6'b010010: controls <= 7'bxxx1100; // MFLO
                6'b001000: controls <= 7'bxxxxx01; // JR
                default:   controls <= 7'b0000000; // ???
            endcase
        endcase
endmodule

//Interrupt Encoder
module interruptenc(
    input       status_bit, interrupt, 
    output reg  int_ack, epcwrite );

    initial
    begin
        int_ack = 0;
        epcwrite = 0;
    end

    always @(*)
    begin 
        if (!status_bit)
        begin 
            int_ack = 0;
            epcwrite = 0;
        end
        else if (status_bit && interrupt)
        begin
            int_ack = 1;
            epcwrite = 1;
        end
    end
endmodule

// ALU
module alu(
    input		[31:0]	a, b,
    input		[2:0]	alucont,
    output reg	[31:0]	result,
    output				zero );

    wire		[31:0]	b2, sum, slt;

    assign b2 = alucont[2] ? ~b:b;
    assign sum = a + b2 + alucont[2];
    assign slt = sum[31];

    always@(*)
        case(alucont[1:0])
            2'b00: result <= a & b;
            2'b01: result <= a | b;
            2'b10: result <= sum;
            2'b11: result <= slt;
        endcase

    assign zero = (result == 32'b0);
endmodule

// Adder
module adder(
    input	[31:0]	a, b,
    output	[31:0]	y);

    assign y = a + b;
endmodule

// Two-bit left shifter
module sl2(
    input	[31:0]	a,
    output	[31:0]	y);

    // shift left by 2
    assign y = {a[29:0], 2'b00};
endmodule

// Sign Extension Unit
module signext(
    input	[15:0]	a,
    output	[31:0]	y);

    assign y = {{16{a[15]}}, a};
endmodule

// Parameterized Register
module flopr #(parameter WIDTH = 8) (
    input                    clk, reset,
    input        [WIDTH-1:0]    d,
    output reg    [WIDTH-1:0]    q);

    always @(posedge clk, posedge reset)
        if (reset) q <= 0;
        else       q <= d;
endmodule


module flopenr #(parameter WIDTH = 8) (
   input                    clk, reset,
   input                    en,
   input        [WIDTH-1:0]    d,
   output reg    [WIDTH-1:0]    q);

   always @(posedge clk, posedge reset)
       if      (reset) q <= 0;
       else if (en)    q <= d;
endmodule

//synchronous reset reg
module sync_reg #(parameter WIDTH = 1) (
    input      clk, rst, en,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

    initial
    begin
      q = 1;
    end

    always @(posedge clk)
    begin
      if      (rst) q = 0;
      else if (en)  q = d;
      else          q = q;
    end
endmodule

// Parameterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 8) (
    input    [WIDTH-1:0]    d0, d1,
    input                s,
    output    [WIDTH-1:0]    y );

    assign y = s ? d1 : d0;
endmodule

module mux4 #(parameter WIDTH = 8) (
    input    [WIDTH-1:0]    d0, d1, d2, d3,
    input    [1:0]            s,
    output    [WIDTH-1:0]    y );

    assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1: d0); //s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1: d0)
 endmodule


// register file with one write port and three read ports
// the 3rd read port is for prototyping dianosis
module regfile(    
    input			clk,
    input			we3,
    input	[4:0]	ra1, ra2, wa3,
    input	[31:0]	wd3,
    output	[31:0]	rd1, rd2);
    //input	[4:0]	ra4,
    //output 	[31:0]	rd4);

    reg        [31:0]    rf[31:0];
    integer            n;
    
    //initialize registers to all 0s
    initial
        for (n=0; n<32; n=n+1)
            rf[n] = 32'h00;
            
    //write first order, include logic to handle special case of $0
    always @(posedge clk)
        if (we3)
            if (~ wa3[4])
                rf[{0,wa3[3:0]}] <= wd3;
            else
                rf[{1,wa3[3:0]}] <= wd3;
        
            // this leads to 72 warnings
            //rf[wa3] <= wd3;
            
            // this leads to 8 warnings
            //if (~ wa3[4])
            //    rf[{0,wa3[3:0]}] <= wd3;
            //else
            //    rf[{1,wa3[3:0]}] <= wd3;
        
    assign rd1 = (ra1 != 0) ? rf[ra1[4:0]] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2[4:0]] : 0;
    //assign rd4 = (ra4 != 0) ? rf[ra4[4:0]] : 0;
endmodule

module multiply(input [31:0] in1, in2, output [31:0] hi, lo);
assign {hi,lo} = in1* in2;

endmodule

module spreg(input clk, load, [31:0] in, output reg [31:0] out);

always @(posedge clk)
    begin
        if(load) out = in;
        else out = out;
    end

endmodule

// Control Unit
module controller(
    input	[5:0]	op, funct,
    input			zero,
	input			status_bit, interrupt,    //added for vectored interrupt
    output			memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump,
    output			jalsel, select_result, hi_lo, hi_lo_load, alu_jump,        //new additions
    output	[2:0]	alucontrol,
	output			status_write, int_ack, epcwrite );  //added for vectored interrupt


    wire	[1:0]	aluop;
    wire			branch;

    maindec    md(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, jalsel, aluop, status_write);
    aludec    ad(funct, aluop, select_result, hi_lo, hi_lo_load, alu_jump, alucontrol);
    interruptenc    ie(status_bit, interrupt, int_ack, epcwrite);   //added for vectored interrupt

    assign pcsrc = branch & zero;
endmodule

// Data Path (excluding the instruction and data memories)
module datapath(
    input			clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
    input           int_ack, epcwrite, status_write, //new additions - Nick F
    input	[2:0]	alucontrol,
    output			zero,
    output	[31:0]	pc,
    input	[31:0]	instr,
    output	[31:0]	aluout, writedata,
    input	[31:0]	readdata,
    //input	[ 4:0]	dispSel,
    //output	[31:0]	dispDat,
    input			done1, done2, done3, done4, // new additions - Nick F
    // input	[31:0]	int_addr, // new additions - Nick F
    output			status_bit); // new additions - Nick F

    wire	[4:0]	writereg;
    wire	[31:0]	pcnext, pcnext_out, pcnextbr, pcplus4, pcbranch, signimm, signimmsh, srca, srcb, result;
    wire	[31:0]	hireg, loreg, hi_out, lo_out, hilo_out, select_out, resultp1; //new addition
    wire	[4:0]	rs_rt; //jalregmux - new addition
    wire	[31:0]	epcout; //epc_reg -  new additions - Nick F
    wire    [31:0]  int_addr; //int_addr - new addition - Nick F

    wire	[ 4:0]	dispSel;
    wire	[31:0]	dispDat;

    // next PC logic
    flopr	#(32)	pcreg(clk, reset, pcnext_out, pc); // route pcnext through a 2to1 MUX and send MUX out in place of pcnext. MUX sel is called int_ack - Nick F
    mux2	#(32)	intmux(pcnext, int_addr, int_ack, pcnext_out);
    adder			pcadd1(pc, 32'b100, pcplus4);
    sl2				immsh(signimm, signimmsh);
    adder			pcadd2(pcplus4, signimmsh, pcbranch);
    mux2	#(32)	pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    mux4	#(32)	pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, srca, epcout, {alu_jump,jump}, pcnext); //Add input 4 as epcout from EPC register - Nick F

    // register file logic
    regfile			rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata);// dispSel, dispDat);
    mux2	#(5)	wrmux(instr[20:16], instr[15:11], regdst, rs_rt);
    mux2	#(5)	jalregmux(rs_rt, 5'b11111, jalsel, writereg);
    mux2	#(32)	resmux(aluout, readdata, memtoreg, resultp1);
    signext			se(instr[15:0], signimm);

    // ALU logic
    mux2	#(32)	srcbmux(writedata, signimm, alusrc, srcb);
    alu				alu(srca, srcb, alucontrol, aluout, zero);
    
    // Multiply
    multiply		multu(srca, srcb, hireg, loreg);
    spreg			hi_reg(clk, hi_lo_load, hireg, hi_out);
    spreg			lo_reg(clk, hi_lo_load, loreg, lo_out);
    mux2	#(32)	hilomux(hi_out, lo_out, hi_lo, hilo_out); //connects into new mux that takes in resmux and hilomux
    
    mux2	#(32)	selmux(resultp1, hilo_out, select_result, select_out);
    mux2	#(32)	jaldatamux(select_out, pcplus4, jalsel, result);

    // Vectored interrupt
    vectored_int	v_int(int_ack, done1, done2, done3, done4, int_addr);
    flopenr	#(32)	epc_reg(clk, reset, epcwrite, pcnext, epcout);
    // flopenr	#(1)	stat_reg(clk, int_ack, status_write, 1'b1, status_bit);
    sync_reg        stat_reg(.clk(clk), .rst(int_ack), .en(status_write), .d(1'b1), .q(status_bit));
endmodule

// The MIPS (excluding the instruction and data memories)
module mips(
    input               clk, reset,
    output    [31:0]    pc,
    input     [31:0]    instr,
    output              memwrite,
    output    [31:0]    aluout, writedata,
    input     [31:0]    readdata,
    //input     [ 4:0]    dispSel,
    //output    [31:0]    dispDat,
    // input               interrupt, //for vectored interrupt
    input               done1, done2, done3, done4 //for vectored interrupt
    );

    // deleted wire "branch" - not used
    wire            memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump;
    wire            jalsel, select_result, hi_lo, hi_lo_load, alu_jump;    //new additions
    wire            status_bit, status_write, int_ack, epcwrite; //for vectored interrupt
    wire    [2:0]   alucontrol;
    // wire    [31:0]  int_addr; //for vectored interrupt

    controller c(instr[31:26], instr[5:0], zero, 
                status_bit, (done1 | done2 | done3 | done4), //for vectored interrupt
                memtoreg, memwrite, pcsrc,
                alusrc, regdst, regwrite, jump,
                jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
                alucontrol,
                status_write, int_ack, epcwrite); //for vectored interrupt

    datapath dp(clk, reset, memtoreg, pcsrc,
                alusrc, regdst, regwrite, jump,
                jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
                int_ack, epcwrite, status_write, //for vectored interrupt
                alucontrol, zero, pc, instr, aluout,
                writedata, readdata, 
                //dispSel, dispDat,
                done1, done2, done3, done4, //for vectored interrupt
                // int_addr,
                status_bit //for vectored interrupt
                );
endmodule

// Instruction Memory
module imem (
    input	[ 6:0]	a,
    output	[31:0]	dOut );

    reg		[31:0]	rom[0:127];
    
    //initialize rom from memfile_s.dat
    initial
    begin
        $readmemh("C:\\Users\\Kevin\\Documents\\repos\\group-awesome\\single_cycle_proc\\memfile_s.dat", rom);
        rom[124] = 32'h0800_0040; //jump to ISR for done 1
        rom[125] = 32'h0800_0050; //jump to ISR for done 2
        rom[126] = 32'h0800_0060; //jump to ISR for done 3
        rom[127] = 32'h0800_0070; //jump to ISR for done 4
        //ISR for done 1
        rom[64]  = 32'hAC04_00F0; //sw $a0, 240($0) #save register a0 in dmem[60]
        rom[65]  = 32'h8C04_080C; //lw $a0, 0x80C   #load factorial into register a0
        rom[66]  = 32'hAC04_00F4; //sw $a0, 244($0) #dmem[61] = factorial
        rom[67]  = 32'h8C04_00F0; //lw $a0, 240($0) #restore register a0 from dmem[60]
        rom[68]  = 32'hF800_0008; //jepc  #jump to EPC value
        //ISR for done 2
        rom[80]  = 32'hAC04_00F0; //sw $a0, 240($0)  #save register a0 in dmem[60]
        rom[81]  = 32'hAC05_00EC; //sw $a1, 236($0)  #save register a0 in dmem[59]
        rom[82]  = 32'h8C04_0A0C; //lw $a0, 0xA0C    #load flags into register a0
        rom[83]  = 32'h8C05_0A08; //lw $a1, 0xA08    #load product into register a1
        rom[84]  = 32'hAC04_00F8; //sw $a0, 248($0)  #dmem[62] = flags
        rom[85]  = 32'hAC05_00FC; //sw $a1, 252($0)  #dmem[63] = product
        rom[86]  = 32'h8C04_00F0; //lw $a0, 240($0)  #restore register a0 from dmem[60]
        rom[87]  = 32'h8C05_00EC; //lw $a1, 236($0)  #restore register a1 from dmem[59]
        rom[88]  = 32'hF800_0008; //jepc  #jump to EPC value
        //ISR for done 3 (no actual source for this interrupt yet)
        rom[96]  = 32'hF800_0008; //jepc  #jump to EPC value
        //ISR for done 4 (no actual source for this interrupt yet)
        rom[112] = 32'hF800_0008; //jepc  #jump to EPC value
    end
    //simple rom
    assign dOut = rom[a];
endmodule

// Data Memory
module dmem (
    input			clk,
    input			we,
    input	[31:0]	addr,
    input	[31:0]	dIn,
    output	[31:0]	dOut );
    
    reg		[31:0]	ram[63:0];
    integer			n;
    
    //initialize ram to all FFs
    initial
        for (n=0; n<64; n=n+1)
            ram[n] = 8'hFF;
        
    assign dOut = ram[addr[31:2]];
                
    always @(posedge clk)
        if (we)
            ram[addr[31:2]] = dIn;
endmodule
