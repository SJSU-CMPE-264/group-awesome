`timescale 1ns / 1ps
module tb_GPIO();
    reg [31:0] tb_WD, tb_GPI1, tb_GPI2;
    reg [1:0] tb_A;
    reg tb_WE, tb_CLK;
    wire [31:0] tb_RD, tb_GPO1, tb_GPO2;
    reg [31:0] exp_RD, exp_GPO1, exp_GPO2;
    integer i;
    
    GPIO DUT(tb_WD, tb_GPI1, tb_GPI2, tb_A, tb_WE, tb_CLK, tb_RD, tb_GPO1, tb_GPO2);
    
    initial     begin
    tb_CLK = 0;
        for(i = 7; i >= 0; i = i - 1)    begin
            tb_WD = 16 + i;
            tb_GPI1 = 32 + i;
            tb_GPI2 = 64 + i;
            {tb_WE, tb_A} = i;
            case (i)
          /*0 00*/  0 : begin  exp_RD = 32 + 0; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*0 01*/  1 : begin  exp_RD = 64 + 1; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*0 10*/  2 : begin  exp_RD = 16 + 6; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*0 11*/  3 : begin  exp_RD = 16 + 7; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*1 00*/  4 : begin  exp_RD = 32 + 4; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*1 01*/  5 : begin  exp_RD = 64 + 5; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*1 10*/  6 : begin  exp_RD = 16 + 6; exp_GPO1 = 16 + 6; exp_GPO2 = 16 + 7; end
          /*1 11*/  7 : begin  exp_RD = 16 + 7; exp_GPO2 = 16 + 7; end
            endcase
            #10;
            tb_CLK = 1;
            #10;
            tb_CLK = 0;
            if(exp_RD !== tb_RD)
                $display("TB failed! i(%d): exp_RD(%h), tb_RD(%h)\n", i, exp_RD, tb_RD);
            if(exp_GPO1 !== tb_GPO1)    
                $display("TB failed! i(%d): exp_GPO1(%h), tb_GPO1(%h)\n", i, exp_GPO1, tb_GPO1);
            if(exp_GPO2 !== tb_GPO2)    
                $display("TB failed! i(%d): exp_GPO2(%h), tb_GPO2(%h)\n", i, exp_GPO2, tb_GPO2);
        end
        $display("End of testbench\n");
        $finish;
    end
endmodule
