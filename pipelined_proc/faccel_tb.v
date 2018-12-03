module faccel_tb;

    reg Clk, Rst, wel;
    reg [1:0] a;
    reg [3:0] d;
    wire [31:0] out;
    
    reg [6:0] ctrl;
    integer exp;
    
    faccel DUT (Clk, Rst, wel, a, d, out);
    
    task tick; begin #5; Clk = 1; #5; Clk = 0; end endtask
    task rest; begin #5; Rst = 1; #5; Rst = 0; end endtask
    
    function [31:0] fact;
    input [3:0] n;
        begin
        fact = 1;
        while (n > 1)
            begin
            fact = fact * n;
            n = n - 1;
            end
        end
    endfunction
    
    parameter
        IDLE  = 7'b0_00_0000,
        LOADN = 7'b1_00_0101,
        LOADG = 7'b1_01_0001,
        READN = 7'b0_00_0000,
        READG = 7'b0_01_0000,
        READS = 7'b0_10_0000,
        READF = 7'b0_11_0000;
    
    always @ (ctrl) {wel, a, d} = ctrl;
    
    initial
    begin
        Clk = 0; Rst = 0;
        wel = 0; a = 0; d = 0;
        exp = fact(5);
        rest;
        ctrl = IDLE; tick;
        ctrl = LOADN; tick; if (DUT.N.out != 5) $display ("N Error");
        ctrl = LOADG; tick; if (DUT.G.out != 1) $display ("G Error");
        ctrl = IDLE; tick;
        while (DUT.F.done != 1) tick;
        ctrl = READN; tick; if (out != 5)   $display ("NR Error");
        ctrl = READG; tick; if (out != 1)   $display ("GR Error");
        ctrl = READS; tick; if (out != 1)   $display ("SR Error");
        ctrl = READF; tick; if (out != exp) $display ("FR Error");
        $display ("Simulation Finished");
        $finish;
    end

endmodule
