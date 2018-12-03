module mips_tb;

    reg    Clk, Rst;
    reg [31:0] gpi1, gpi2;
    wire [31:0] gpo1, gpo2;

    mipss DUT (Clk, Rst, gpi1, gpi2, gpo1, gpo2);
    
    task tick; begin #5; Clk = 1; #5; Clk = 0; end endtask
    task rest; begin #5; Rst = 1; #5; Rst = 0; end endtask
    
    initial
    begin
        Clk = 0; Rst = 0; gpi1 = 32'd5; gpi2 = 32'd5;
        rest;
        while (DUT.mips.dp.rf.rf[16] != 7) 
        begin
            tick;
        end
     
        tick;
        if (gpo2 != 32'h78) $display ("Failed");
        $display ("Finished");
        $finish;
    end

endmodule