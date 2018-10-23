module soc_tb;

    reg clk, rst;
    reg [31:0] gpi1, gpi2;
    wire [31:0] gpo1, gpo2;
    
    mips_top DUT (clk, rst, gpi1, gpi2, gpo1, gpo2);
    
    task tick; begin #5; clk = 1; #5; clk = 0; end endtask
    task rest; begin #5; rst = 1; #5; rst = 0; end endtask
    
    initial
    begin
        clk = 0; rst = 0; gpi1 = 32'h0000_0006; gpi2 = 32'h0000_0007;
        rest;
        tick; if (DUT.mips.dp.rf.rf[16] != 32'h0000_0005) $display ("ADDI Fail");
        tick; if (DUT.dmem.ram[1] != 32'h0000_0005)       $display ("SW Fail");
        tick; if (DUT.mips.dp.rf.rf[17] != 32'h0000_0005) $display ("LW Fail");
        
        tick; if (DUT.facc.N.out != 32'h0000_0005)        $display ("SWN Fail");
        tick; if (DUT.facc.G.out != 1'b1)                 $display ("SWN Fail");
        while (DUT.facc.S.out != 32'b0000_0001) tick;
        tick; if (DUT.mips.dp.rf.rf[18] != 32'h0000_0005) $display ("LWN Fail");
        tick; if (DUT.mips.dp.rf.rf[19] != 32'h0000_0001) $display ("LWG Fail");
        tick; if (DUT.mips.dp.rf.rf[20] != 32'h0000_0001) $display ("LWS Fail");
        tick; if (DUT.mips.dp.rf.rf[21] != 32'h0000_0078) $display ("LWF Fail");
        
        tick; if (DUT.gpio.U2_reg1.Q != 32'h0000_0005)    $display ("GPI1 Fail");
        tick; if (DUT.gpio.U3_reg2.Q != 32'h0000_0005)    $display ("GPI2 Fail");
        tick; if (DUT.mips.dp.rf.rf[22] != 32'h0000_0006) $display ("LWI1 Fail");
        tick; if (DUT.mips.dp.rf.rf[23] != 32'h0000_0007) $display ("LWI2 Fail");
        tick; if (DUT.mips.dp.rf.rf[24] != 32'h0000_0005) $display ("LWO1 Fail");
        tick; if (DUT.mips.dp.rf.rf[25] != 32'h0000_0005) $display ("LWO2 Fail");
        
        if (gpo1 != 32'h0000_0006)                        $display ("GPO1 Fail");
        if (gpo2 != 32'h0000_0007)                        $display ("GPO2 Fail");
        
        $display ("Finished");
        $finish;
    end

endmodule
