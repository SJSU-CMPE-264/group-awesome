module mips2_tb;

    reg    clk, rst;
    reg [31:0] gpi1, gpi2;
    wire [31:0] gpo1, gpo2;

    mipss DUT (clk, rst, gpi1, gpi2, gpo1, gpo2);
    
    task tick; begin #5; clk = 1; #5; clk = 0; end endtask
    task rest; begin #5; rst = 1; #5; rst = 0; end endtask

    initial
    begin
        clk = 0; rst = 0;
        rest;
        while (DUT.mips.pc != 32'hC4) tick;
        
        tick; tick; tick;
    
        $display ("Finished");
        $finish;
    end

endmodule
