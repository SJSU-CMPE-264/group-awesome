`timescale 1ns / 1ps

module mips_top(
    input    Clk, reset,
    output    memwrite,
    output [31:0] epc
    );

    wire    [31:0]     pc, instr, dataadr, writedata, readdata;
    wire    [3:0]      ex_int;
      
    // Instantiate processor and memories    
    mips     mips       (Clk, reset, pc, instr, memwrite, 
                        dataadr, writedata, readdata, 
                        ex_int,
                        epc);
    imem     imem       (pc[8:2], instr);
    //SoC
    SoC     soc ( 
                .addr_dm(dataadr), .wd_dm(writedata),
                .we(memwrite), .Rst(reset), .Clk(Clk), .rd_dm(readdata),
                .ex_int(ex_int) 
                );
endmodule
