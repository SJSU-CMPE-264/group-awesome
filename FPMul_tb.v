module FPMul;
    reg         clk, rst, Start;
    reg [31:0]  A, B;
    wire        Done, OF, UF, NanF, InfF, DNF, ZF;
    wire [31:0] P;

    FPMul DUT(clk, rst, Start, A, B, Done, P, OF, UF, NanF, InfF, DNF, ZF);


    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    task reset; 
        begin 
            #5 rst = 1; 
            #5 rst = 0; 
        end 
    endtask

    initial begin
        reset;
        A=5;
        B=5;
        Start = 1;
        tick;
        tick;
        tick;
        $dumpfile("test.vcd");
        $dumpvars(0,test);  
    end
endmodule // 