`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/11/2017 04:23:29 PM
// Design Name:
// Module Name: tb_cu
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tb_cu();

reg [5:0] tb_op, tb_funct;
reg tb_zero;
wire tb_memtoreg, tb_memwrite, tb_pcsrc, tb_alusrc, tb_regdst, tb_regwrite, tb_jump;
wire tb_jalsel, tb_select_result, tb_hi_lo, tb_hi_lo_load, tb_alu_jump;
wire [2:0] tb_alucontrol;

reg tb_clk;

parameter
    addControls = 15'b110000000100000, subControls = 15'b110000001100000, andControls = 15'b110000000000000,
    orControls = 15'b110000000010000, sltControls = 15'b110000001110000, multuControls = 15'b11000000xxx1x10,
    mfhiControls = 15'b11000000xxx1000, mfloControls = 15'b11000000xxx1100, jrControls = 15'b11000000xxxxx01,
    lwControls = 15'b10100100xxxxxxx, swControls = 15'b00101000xxxxxxx, beqControls = 15'b00010000xxxxxxx,
    addiControls = 15'b10100000xxxxxxx, jControls = 15'b00000010xxxxxxx, jalControls = 15'b10000011xxxxxxx;

reg [14:0] tb_controls;

task runclk;
    begin tb_clk = 0; #5; tb_clk = 1; #5; end endtask
    
controller DUT(
        tb_op, tb_funct,
        tb_zero,
        tb_memtoreg, tb_memwrite, tb_pcsrc, tb_alusrc, tb_regdst, tb_regwrite, tb_jump,
        tb_jalsel, tb_select_result, tb_hi_lo, tb_hi_lo_load, tb_alu_jump,        //new additions
        tb_alucontrol );

always@(posedge tb_clk)
begin
    tb_controls = {tb_regwrite, tb_regdst, tb_alusrc, tb_pcsrc, tb_memwrite, tb_memtoreg, tb_jump, tb_jalsel, tb_alucontrol,
                    tb_select_result, tb_hi_lo, tb_hi_lo_load, tb_alu_jump};
end

initial
begin
    tb_op = 6'b000000;  tb_zero = 0;    //add
    tb_funct = 6'b100000; runclk;
    if(tb_controls != addControls) $display("addControls do not match. tb_controls: ", tb_controls);

    tb_funct = 6'b100010; runclk;   //sub
    if(tb_controls != subControls) $display("subControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b100100; runclk;   //and
    if(tb_controls != andControls) $display("andControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b100101; runclk;   //or
    if(tb_controls != orControls) $display("orControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b101010; runclk;   //slt
    if(tb_controls != sltControls) $display("sltControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b011010; runclk;   //multu
    if(tb_controls != multuControls) $display("multuControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b010000; runclk;   //mfhi
    if(tb_controls != mfhiControls) $display("mfhiControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b010010; runclk;   //mflo
    if(tb_controls != mfloControls) $display("mfloControls do not match. tb_controls: ", tb_controls);
    
    tb_funct = 6'b001000; runclk;   //jr
    if(tb_controls != jrControls) $display("jrControls do not match. tb_controls: ", tb_controls);

    tb_funct = 6'b000000; tb_op = 6'b100011; runclk;    //lw
    if(tb_controls != lwControls) $display("lwControls do not match. tb_controls: ", tb_controls);
    
    tb_op = 6'b101011; runclk;  //sw
    if(tb_controls != swControls) $display("swControls do not match. tb_controls: ", tb_controls);
    
    tb_op = 6'b000100; tb_zero = 1; runclk; //beq
    if(tb_controls != beqControls) $display("beqControls do not match. tb_controls: ", tb_controls);
    
    tb_op = 6'b001000; runclk;  //addi
    if(tb_controls != addiControls) $display("addiControls do not match. tb_controls: ", tb_controls);
    
    tb_op = 6'b000010; runclk;  //j
    if(tb_controls != jControls) $display("jControls do not match. tb_controls: ", tb_controls);
    
    tb_op = 6'b000011; runclk;  //jal
    if(tb_controls != jalControls) $display("jalControls do not match. tb_controls: ", tb_controls);

    $display("Simulation completed.");
    $finish;
end


endmodule
