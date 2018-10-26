`timescale 1ns / 1ps



module tb_dp();

reg        clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
           jalsel, select_result, hi_lo, hi_lo_load, alu_jump;
reg [2:0] alucontrol;
reg    [31:0]    instr, readdata;
reg    [ 4:0]    dispSel;
wire zero;
wire [31:0] pc, aluout, writedata, dispDat;

parameter
    addControls = 15'b110000000100000, subControls = 15'b110000001100000, andControls = 15'b110000000000000,
    orControls = 15'b110000000010000, sltControls = 15'b110000001110000, multuControls = 15'b11000000xxx1x10,
    mfhiControls = 15'b11000000xxx1000, mfloControls = 15'b11000000xxx1100, jrControls = 15'b11000000xxxxx01,
    lwControls = 15'b101001000100000, swControls = 15'b001010000100000, beqControls = 15'b000100001100000,
    addiControls = 15'b101000000100000, jControls = 15'b000000100100000, jalControls = 15'b100000110100000;
    
parameter
    addInstr = 32'h031a7020,    subInstr = 32'h031a7022,    andInstr = 32'h031a7024,
    orInstr = 32'h031a7025,     sltInstr = 32'h031a702a,    multuInstr = 32'h031a0019,
    mfhiInstr = 32'h0000e010,   mfloInstr = 32'h0000e012,   jrInstr = 32'h03e00008,
    lwInstr = 32'h8c1c0000,     swInstr = 32'hac1a0000,     beqInstr = 32'h11ac0005,
    addiInstr = 32'h2018001e,   jInstr = 32'h08000025,      jalInstr = 32'h0c000018, addiZero = 32'h239c0000;
    
reg [14:0] ctrl;
reg dummy;

datapath DP(
    clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
    jalsel, select_result, hi_lo, hi_lo_load, alu_jump,
    alucontrol,
    zero,
    pc,
    instr,
    aluout, writedata,
    readdata,
    dispSel,
    dispDat
);


task runclk;
    begin clk = 0; #5; clk = 1; #5; end endtask
    
always@(ctrl)
begin
    {regwrite,regdst,alusrc,pcsrc,dummy,memtoreg,jump,jalsel,alucontrol,select_result,hi_lo,hi_lo_load,alu_jump} = ctrl;
end
    
initial
begin
    clk = 1;
    reset = 1;
    instr = 32'b0;
    ctrl = 15'b0;
    runclk;
    reset = 0;
    
//    instr = jalInstr;
//    ctrl = jalControls;
//    runclk;
//    if (pc != 32'h60) $display("jal error");
    
    instr = addiInstr;  //30 into $24
    ctrl = addiControls;
    runclk;
    if (writedata != 32'd30) $display("addi error to $24");
    
    instr = {addiInstr[31:21], 5'b11010, addiInstr[15:1], 1'b1}; //31 into $13
    runclk;
    if (writedata != 32'd31) $display("addi error to $26");
 
    instr = jalInstr;
    ctrl = jalControls;
    runclk;
    if (pc != 32'h60) $display("jal error");

    
    instr = addInstr;
    ctrl = addControls;
    runclk;
    if (aluout != 32'd61) $display("add error, does not equal 61.");
    
    instr = subInstr;
    ctrl = subControls;
    runclk;
    if (aluout != -1) $display("subtract error.");
    
    instr = andInstr;
    ctrl = andControls;
    runclk;
    if (aluout != 30) $display("and error.");
    
    instr = orInstr;
    ctrl = orControls;
    runclk;
    if (aluout != 31) $display("or error.");
    
    instr = sltInstr;
    ctrl = sltControls;
    runclk;
    if (aluout != 1) $display("slt error.");
    
    instr = multuInstr;
    ctrl = multuControls;
    runclk;
    
    
    
    
    instr = mfloInstr;
    ctrl = mfloControls;
    runclk;
    
    instr = addiZero;
    ctrl = addiControls;
    runclk;
    if (writedata != 32'd930) $display("multu or mflo error.");
    
    instr = mfhiInstr;
    ctrl = mfhiControls;
    runclk;
    if (writedata != 0) $display("multu or mfhi error.");
    
    instr = jrInstr;
    ctrl = jrControls;
    runclk;
    if (pc != 32'hc) $display("jr error. %H", pc);
    
    instr = swInstr;
    ctrl = swControls;
    runclk;
    if (writedata != 31) $display("sw data error.");
    if (aluout != 0) $display("sw address error.");
    
    readdata = 32'd50;
    instr = lwInstr;
    ctrl = lwControls;
    runclk;
//    if (writedata != 31) $display("lw data error.");
    if (aluout != 0) $display("lw address error.");
    
    instr = beqInstr;
    ctrl = beqControls;
    runclk;
    if (zero != 1) $display ("beq error.");
    
    
    instr = jInstr;
    ctrl = jControls;
    runclk;
    if (pc != 32'b10010100) $display ("jump error.");
    
    
    
    $display("Finshed.");
    $finish;
            
end

endmodule
