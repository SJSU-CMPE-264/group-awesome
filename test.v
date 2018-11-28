module test;
    reg         clk, rst, Start;
    reg [31:0]  A, B;
    wire        Done, OF, UF, NanF, InfF, DNF, ZF;
    wire [31:0] P;

    FPMul DUT(clk, rst, Start, A, B, Done, P, OF, UF, NanF, InfF, DNF, ZF);
    integer square;

    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    task reset; 
        begin 
            A=0;
            B=0;
            rst = 1; 
            tick;
            rst = 0;
            tick; 
        end 
    endtask

    initial begin
        A=0;
        B=0;
        rst=0;
        Start=0;
        reset;
        for(square = 0; square < 10; square = square + 1) begin
            A=square;
            B=square;
            Start=1;
            tick;
            Start=0;
            while(Done != 1) begin
                tick;
            end // while(Done != 1)
            reset;
        end // for(square = 0; square < 10; square = square + 1)
    end
endmodule // test