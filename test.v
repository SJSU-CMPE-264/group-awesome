module test;
    reg         Clk, Rst, Start;
    reg [31:0]  A, B;
    wire        Done, OF, UF, NaNF, InfF, DNF, ZF;
    wire [31:0] P;

    FPMUL DUT(Clk, Rst, Start, A, B, Done, P, OF, UF, NaNF, InfF, DNF, ZF);

    reg [31:0] expected_P;

    task tick;
        begin #5 Clk = 1; #5 Clk = 0; end
    endtask

    task reset;
        begin
            #5 Rst = 1; #5 Rst = 0;
            Start = 0;
            { A, B } = 0;
            expected_P = 0;
        end
    endtask

    task fpmultiply;
        input [31:0] in1, in2;
        input [31:0] expected;
        begin
            tick;
            A = in1; B = in2;
            Start = 1;
            tick;
            Start = 0;
            while(!Done) tick;
            expected_P = expected;
            tick;
            expected_P = 0;
        end
    endtask

    initial begin
        reset;
        tick;

        //        A: 2.00000000000000000000000 (0x40000000)
        //        B: 2.00000000000000000000000 (0x40000000)
        // expected:                            (0x40800000)
        // fpmultiply(32'h40000000, 32'h40000000, 32'h40800000); // PASSED

        // fpmultiply(32'h42000000, 32'h40000000, 32'h42800000);

        // 7.7817135 * 4.0722413 - expected: 0x41fd831a
        fpmultiply(32'h40f903cc, 32'h40824fcd, 32'h41fd831a);

        //        A: -0.00000172911779827700229 (0xb5e81409)
        //        B: -0.00000000000000000000000 (0x8ea92a2c)
        // expected:                            (0x05195b75)
        // fpmultiply(32'hb5e81409, 32'h8ea92a2c, 32'h05195b75);

        //        A: 0.00000000449844250738352 (0x319a90b8)
        //        B: nan                       (0xffcd3697)
        // expected: nan                       (0xffffffff)
        // fpmultiply(32'h319a90b8, 32'hffcd3697, 32'hffffffff); // PASSED

        //        A: -0.00000000000000043232612 (0xa5f93813)
        //        B: inf                        (0x7f800000)
        // expected: -inf                        (0xff800000)
        // fpmultiply(32'ha5f93813, 32'h7f800000, 32'hff800000); // PASSED

        //        A: -0.08399438858032226562500 (0xbdac0540)
        //        B: -inf                       (0xff800000)
        // expected: inf                        (0x7f800000)
        // fpmultiply(32'hbdac0540, 32'hff800000, 32'h7f800000); // PASSED

        //        A: 28985.23046875000000000000000 (0x46e27276)
        //        B:     0.00000000000000000000000 (0x00030e4d)
        // expected:     0.00000000000000000000000 (0x0767da72)
        // fpmultiply(32'h46e27276, 32'h00030e4d, 32'h0767da72);

        // fpmultiply(32'h0, 32'h1, 32'h0);

        fpmultiply(32'b00000000011000111101101001111001,
                   32'b01110001011101111111110110001111,
                   32'b00110010010111001011100101111001);
    end
endmodule // testi
