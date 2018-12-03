`timescale 1ns / 1ps



module tb_dp();

reg        Clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
           jalsel, select_result, hi_lo, hi_lo_load, alu_jump, memwrite;
reg [2:0] alucontrol;
reg    [31:0]    instr, readdata;
reg    [ 4:0]    dispSel;
wire zero, memwriteOut;
wire [31:0] pc, aluout, writedata, dispDat;

parameter
    addControls = 15'b110000000100000, subControls = 15'b110000001100000, andControls = 15'b110000000000000,
    orControls = 15'b110000000010000, sltControls = 15'b110000001110000, multuControls = 15'b11000000xxx1x10,
    mfhiControls = 15'b11000000xxx1000, mfloControls = 15'b11000000xxx1100, jrControls = 15'b11000000xxxxx01,
    lwControls = 15'b101001000100000, swControls = 15'b001010000100000, beqControls = 15'b000100001100000,
    addiControls = 15'b101000000100000, jControls = 15'b000000100100000, jalControls = 15'b100000110100000,
    nopControls = 15'b0;
    
parameter
    addInstr = 32'h031a7020,    subInstr = 32'h031a7022,    andInstr = 32'h031a7024,
    orInstr = 32'h031a7025,     sltInstr = 32'h031a702a,    multuInstr = 32'h031a0019,
    mfhiInstr = 32'h0000e010,   mfloInstr = 32'h0000e012,   jrInstr = 32'h03e00008,
    lwInstr = 32'h8c1c0000,     swInstr = 32'hac1a0000,     beqInstr = 32'h11ac0005,
    addiInstr = 32'h2018001e,   jInstr = 32'h08000025,      jalInstr = 32'h0c000018, addiZero = 32'h239c0000,
    nopInstr = 32'h0;
    
reg [14:0] ctrl;
integer prevpc;
//reg dummy;

datapath DP(
    Clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
    jalsel, select_result, hi_lo, hi_lo_load, alu_jump, memwrite,
    alucontrol,
    zero, memwriteOut,
    pc,
    instr,
    aluout, writedata,
    readdata,
    dispSel,
    dispDat
);


task runClk;
    begin Clk = 0; #5; Clk = 1; #5; end endtask
    
always@(ctrl)
begin
    {regwrite,regdst,alusrc,pcsrc,memwrite,memtoreg,jump,jalsel,alucontrol,select_result,hi_lo,hi_lo_load,alu_jump} = ctrl;
end
    
initial
begin
    Clk = 1;
    reset = 1;
    instr = 32'b0;
    ctrl = 15'b0;
    runClk;
    reset = 0;
    
//    instr = jalInstr;
//    ctrl = jalControls;
//    runClk;
    
//    if (pc != 32'h60) $display("jal error");
    
    instr = addiInstr;  //30 into $24
    runClk;
    ctrl = addiControls;
//    if (writedata != 32'd30) $display("addi error to $24");
    
    instr = 32'h201a001f; //31 into $26
    runClk;
    


////    ctrl = 15'b0;
////    if (writedata != 32'd31) $display("addi error to $26");
 
    instr = jalInstr;
    runClk;
    ctrl = jalControls;
//    if (pc != 32'h60) $display("jal error");

    instr = nopInstr;
    runClk;
    ctrl = nopControls;
    runClk;
        
    if(DP.rf.rf[24] != 30) $display("addi error, %d != 30", DP.rf.rf[24]);
        
    runClk;
    if(pc != 32'h60) $display("jal destination error, %d", pc);
    runClk;
    if(DP.rf.rf[31] != 32'h10) $display("jal stored address error, &d", DP.rf.rf[31]);

    
    runClk;
    
    instr = addInstr;
    runClk;
    ctrl = addControls;
    
    
    instr = subInstr;
    runClk;
    ctrl = subControls;
    
    instr = andInstr;
    runClk;
    ctrl = andControls;
    
    instr = orInstr;
    runClk;
    ctrl = orControls;
    
    instr = sltInstr;
    runClk;
    ctrl = sltControls;
    
    if (DP.rf.rf[14] != 32'd61) $display("add error.");
    
    instr = multuInstr;
    runClk;
    ctrl = multuControls;
    
    if (DP.rf.rf[14] != -1) $display("subtract error.");
    
    instr = mfloInstr;
    runClk;
    ctrl = mfloControls;
    
    if (DP.rf.rf[14] != 32'h1e) $display("and error.");
    
    instr = mfhiInstr;
    runClk;
    ctrl = mfhiControls;
    
    if (DP.rf.rf[14] != 32'h1f) $display("or error.");
    
    instr = jrInstr;
    runClk;
    ctrl = jrControls;
    
    if (DP.rf.rf[14] != 32'd1) $display("slt error.");

    instr = nopInstr;
    runClk;
    ctrl = nopControls;
    runClk;
    
    if(DP.rf.rf[28] != 32'h3a2) $display("multu or mflo error.");
    
    runClk;
    
    if(DP.rf.rf[28] != 32'h0) $display("multu or mfhi error.");
    
    runClk;
    
    if(pc != 32'h10) $display("jr error.");
    
    runClk;
//    runClk;




    
    instr = swInstr;
    runClk;
    ctrl = swControls;
//    if (writedata != 31) $display("sw data error.");
//    if (aluout != 0) $display("sw address error.");
    
    readdata = 32'd50;
    instr = lwInstr;
    runClk;
    ctrl = lwControls;
    
    instr = nopInstr;
    runClk;
    ctrl = nopControls;
            
    if (writedata != 31) $display("sw data error.");
    if (aluout != 0) $display("sw address error.");
    
    instr = beqInstr;
    prevpc = pc;
    runClk;
    ctrl = beqControls;
//    if (zero != 1) $display ("beq error.");

    instr = nopInstr;
    runClk;
    ctrl = nopControls;
    runClk;
        
    if(DP.rf.rf[28] != 32'h32) $display("load word error.");
        
    runClk;  
    
    if(pc-prevpc != 24) $display("branch error, %d", pc-prevpc);  
    
    instr = jInstr;
    runClk;
    ctrl = jControls;
//    if (pc != 32'b10010100) $display ("jump error.");

    runClk;   
        
    if(pc != 32'h94) $display("jump error.");
 
    runClk;
    runClk;
    runClk;
    runClk;

    
    $display("Finshed.");
    $finish;
            
end

endmodule
