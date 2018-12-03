module mips2_tb;

    reg    Clk, Rst;
    reg [31:0] gpi1, gpi2;
    wire [31:0] gpo1, gpo2;

    mipss DUT (Clk, Rst, gpi1, gpi2, gpo1, gpo2);
    
    task tick; begin #5; Clk = 1; #5; Clk = 0; end endtask
    task rest; begin #5; Rst = 1; #5; Rst = 0; end endtask

    initial
    begin
        Clk = 0; Rst = 0;
        rest;
        while (DUT.mips.pc != 32'hC4) tick;
        
        tick; tick; tick;
    
        $display ("Finished");
        $finish;
    end

endmodule
