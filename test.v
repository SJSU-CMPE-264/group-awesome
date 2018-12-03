module test;
    reg         Clk, Rst, Start;
    reg [31:0]  A, B;
    wire        Done, OF, UF, NaNF, InfF, DNF, ZF;
    wire [31:0] P;

    FPMUL DUT(Clk, Rst, Start, A, B, Done, P, OF, UF, NaNF, InfF, DNF, ZF);
    integer square;

    task tick;
        begin
            #5 Clk = 1;
            #5 Clk = 0;
        end
    endtask

    task reset; 
        begin 
            A=0;
            B=0;
            Rst = 1; 
            tick;
            Rst = 0;
            tick; 
        end 
    endtask

    initial begin
        Rst=0;
        Start=0;
        reset;
        A = { 1'b0, 1'b1, 30'b0}; // A = 2.0 = 0x40000000
        B = { 1'b0, 1'b1, 30'b0}; // B = 2.0 = 0x40000000
        Start=1;
        tick;
        Start=0;
        while(Done != 1) begin
            tick;
        end // while(Done != 1)
        tick;
        
        A=0;
        B=0;
        Rst=0;
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
        end // for(square = 0; square < 10; square = square + 1) */
    end
endmodule // testi


