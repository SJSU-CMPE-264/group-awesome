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
    input    [ 5:0]    op,
    output            memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, jalsel,
    output    [ 1:0]    aluop );

    reg     [ 9:0]    controls;

    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, jalsel, aluop} = controls;

    always @(*)
        case(op)
            6'b000000: controls <= 10'b1100000010; //Rtype
            6'b100011: controls <= 10'b1010010000; //LW
            6'b101011: controls <= 10'b0010100000; //SW
            6'b000100: controls <= 10'b0001000001; //BEQ
            6'b001000: controls <= 10'b1010000000; //ADDI
            6'b000010: controls <= 10'b0000001000; //J
            6'b000011: controls <= 10'b1000001100; //JAL
            default:   controls <= 10'bxxxxxxxxx; //???
        endcase
endmodule

// ALU Decoder
module aludec(
    input        [5:0]    funct,
    input        [1:0]    aluop,
    output      select_result, hi_lo, hi_lo_load, alu_jump,
                [2:0]    alucontrol );

    reg [6:0] controls;
    
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
// ALU
module alu(
    input        [31:0]    a, b,
    input        [ 2:0]    alucont,
    output reg    [31:0]    result,
    output            zero );

    wire    [31:0]    b2, sum, slt;

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
    input    [31:0]    a, b,
    output    [31:0]    y );

    assign y = a + b;
endmodule

// Two-bit left shifter
module sl2(
    input    [31:0]    a,
    output    [31:0]    y );

    // shift left by 2
    assign y = {a[29:0], 2'b00};
endmodule

// Sign Extension Unit
module signext(
    input    [15:0]    a,
    output    [31:0]    y );

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

// commented out since flopenr is not used
//module flopenr #(parameter WIDTH = 8) (
//    input                    clk, reset,
//    input                    en,
//    input        [WIDTH-1:0]    d,
//    output reg    [WIDTH-1:0]    q);
//
//    always @(posedge clk, posedge reset)
//        if      (reset) q <= 0;
//        else if (en)    q <= d;
//endmodule

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
    input            clk,
    input            we3,
    input     [ 4:0]    ra1, ra2, wa3,
    input    [31:0]     wd3,
    output     [31:0]     rd1, rd2,
    input    [ 4:0]     ra4,
    output     [31:0]     rd4);

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
    assign rd4 = (ra4 != 0) ? rf[ra4[4:0]] : 0;
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
    input    [5:0]    op, funct,
    input            zero,
    output            memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump,
    output          jalsel, select_result, hi_lo, hi_lo_load, alu_jump,        //new additions
    output    [2:0]    alucontrol );

    wire    [1:0]    aluop;
    wire            branch;

    maindec    md(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, jalsel, aluop);
    aludec    ad(funct, aluop, select_result, hi_lo, hi_lo_load, alu_jump, alucontrol);

    assign pcsrc = branch & zero;
endmodule

// Data Path (excluding the instruction and data memories)
module datapath(
    input            clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
                   jalsel, select_result, hi_lo, hi_lo_load, alu_jump, //new additions
    input    [2:0]    alucontrol,
    output            zero,
    output    [31:0]    pc,
    input    [31:0]    instr,
    output    [31:0]    aluout, writedata,
    input    [31:0]    readdata,
    input    [ 4:0]    dispSel,
    output    [31:0]    dispDat );

    wire [4:0]  writereg;
    wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch, signimm, signimmsh, srca, srcb, result;
    wire [31:0] hireg, loreg, hi_out, lo_out, hilo_out, select_out, resultp1; //new addition
    wire [4:0] rs_rt; //jalregmux - new addition

    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder       pcadd1(pc, 32'b100, pcplus4);
    sl2         immsh(signimm, signimmsh);
    adder       pcadd2(pcplus4, signimmsh, pcbranch);
    mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    mux4 #(32)  pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, srca, 31'b0, {alu_jump,jump}, pcnext);

    // register file logic
    regfile        rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata, dispSel, dispDat);
    mux2 #(5)    wrmux(instr[20:16], instr[15:11], regdst, rs_rt);
    mux2 #(5)   jalregmux(rs_rt, 5'b11111, jalsel, writereg);
    mux2 #(32)    resmux(aluout, readdata, memtoreg, resultp1);
    signext        se(instr[15:0], signimm);

    // ALU logic
    mux2 #(32)    srcbmux(writedata, signimm, alusrc, srcb);
    alu            alu(srca, srcb, alucontrol, aluout, zero);
    
    //multiply
    multiply    multu(srca, srcb, hireg, loreg);
    spreg       hi_reg(clk, hi_lo_load, hireg, hi_out);
    spreg       lo_reg(clk, hi_lo_load, loreg, lo_out);
    mux2 #(32)  hilomux(hi_out, lo_out, hi_lo, hilo_out); //connects into new mux that takes in resmux and hilomux
    
    mux2 #(32)  selmux(resultp1, hilo_out, select_result, select_out);
    mux2 #(32)  jaldatamux(select_out, pcplus4, jalsel, result);
endmodule

// The MIPS (excluding the instruction and data memories)
module mips(
    input            clk, reset,
    output    [31:0]    pc,
    input     [31:0]    instr,
    output            memwrite,
    output    [31:0]    aluout, writedata,
    input     [31:0]    readdata,
    input    [ 4:0]    dispSel,
    output    [31:0]    dispDat );

    // deleted wire "branch" - not used
    wire             memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump;
    wire            jalsel, select_result, hi_lo, hi_lo_load, alu_jump;    //new additions
    wire    [2:0]     alucontrol;

    controller c(instr[31:26], instr[5:0], zero,
                memtoreg, memwrite, pcsrc,
                alusrc, regdst, regwrite, jump,
                jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
                alucontrol);
    datapath dp(clk, reset, memtoreg, pcsrc,
                alusrc, regdst, regwrite, jump,
                jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
                alucontrol, zero, pc, instr, aluout,
                writedata, readdata, dispSel, dispDat);
endmodule

// Instruction Memory
module imem (
    input    [ 5:0]    a,
    output     [31:0]    dOut );
    
    reg        [31:0]    rom[0:63];
    
    //initialize rom from memfile_s.dat
    initial
        $readmemh("memfile_s.dat", rom);
    
    //simple rom
    assign dOut = rom[a];
endmodule

// Data Memory
module dmem (
    input            clk,
    input            we,
    input    [31:0]    addr,
    input    [31:0]    dIn,
    output     [31:0]    dOut );
    
    reg        [31:0]    ram[63:0];
    integer            n;
    
    //initialize ram to all FFs
    initial
        for (n=0; n<64; n=n+1)
            ram[n] = 8'hFF;
        
    assign dOut = ram[addr[31:2]];
                
    always @(posedge clk)
        if (we)
            ram[addr[31:2]] = dIn;
endmodule
