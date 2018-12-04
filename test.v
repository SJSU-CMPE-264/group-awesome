module test;
    reg         Clk, Rst, Start;
    reg [31:0]  A, B;
    wire        Done, OF, UF, NaNF, InfF, DNF, ZF;
    wire [31:0] P;

    FPMUL DUT(Clk, Rst, Start, A, B, Done, P, OF, UF, NaNF, InfF, DNF, ZF);
    
    task tick;
        begin #5 Clk = 1; #5 Clk = 0; end
    endtask

    task reset; 
        begin
            #5 Rst = 1; #5 Rst = 0;
            Start = 0;
            { A, B } = 0;
        end 
    endtask

    task fpmultiply;
        input  [31:0] in1, in2;
        begin
            tick;
            A = in1; B = in2;
            Start=1;
            tick;
            Start=0;
            while(!Done) tick;
            tick;
        end
    endtask

    initial begin
        reset;
        tick;
        fpmultiply(32'h40000000, 32'h40000000); // 2.0       * 2.0       - expected: 0x40800000
        fpmultiply(32'h40f903cc, 32'h40824fcd); // 7.7817135 * 4.0722413 - expected: 0x41fd831a
        fpmultiply(32'hb5e81409, 32'h8ea92a2c); // expected: 00000101000110010101101101110101 (0x05195b75)
        fpmultiply(32'h319a90b8, 32'hffcd3697); // expected: 11111111111111111111111111111111 (nan)
    end
endmodule // testi
