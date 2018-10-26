`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/17/2017 06:35:29 PM
// Design Name:
// Module Name: tb_cudp
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

module tb_cudp();

reg    clk, reset, pb;
wire    memwrite, wem, we1, we2, we3;
wire    [ 7:0]     LEDSEL;
wire     [ 7:0]    LEDOUT;
reg    [ 7:0]    switches;
reg     [7:0]   gpi1;
wire    sinkBit;

mips_top DUT1(clk, reset, pb, memwrite, wem, we1, we2, we3, LEDSEL, LEDOUT, switches, gpi1, sinkBit);
    
task runclk;
    begin clk = 0; #5; clk = 1; #5; end endtask
    
    integer stop = 0;
    
  // initialize test
initial
  begin
  clk = 0;
    reset = 1;
    runclk;
    # 22;
    reset = 0;
    #5;
//    runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;
//    runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;
//    runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;runclk;
    while (DUT1.mips.dp.pcreg.q != 32'h0000_0058 && stop < 1000)
    begin
        runclk;
        stop = stop + 1;
    end
    
    if(DUT1.mips.dp.rf.rf[16] != 32'h00000018) $display("$s0 != 24.");
    if(stop == 1000) $display("infinite loop encountered.");
    
    $display("Test finished.");
    $finish;
  end

// generate clock to sequence tests
//always
//  begin
//    clk <= 1; # 5; clk <= 0; # 5;
//  end

//// check that 7 gets written to address 84
//always@(negedge clk)
//  begin
//    if(memwrite)
//    begin
//      if(dataadr === 84 & writedata === 7)
//      begin
//        $display("Simulation succeeded");
//        $finish;
//      end
//      else if (dataadr !== 80)
//      begin
//        $display("Simulation failed");
//        $finish;
//      end
//    end
//  end

endmodule
