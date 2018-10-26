module DP #(parameter iwide = 4, owide = 32)
(input clk, rst, cld, cen, s1, ren, ben, input [iwide-1:0] in, output greater, output [owide-1:0] out);

    wire [iwide-1:0] N_sig;
    wire [owide-1:0] F_sig, M_sig, M1_sig;
    
    counter  #iwide CNT (clk, rst, cld, cen, in, N_sig);
    compare  #iwide CMP (N_sig, 1, greater);
    multi    #owide MUL ({0, N_sig}, F_sig, M_sig);
    mux2     #owide MUX (1, M_sig, s1, M1_sig);
    register #owide REG (clk, rst, ren, M1_sig, F_sig);
    buffer   #owide BUF (ben, F_sig, out);

endmodule

module multi #(parameter wide = 4)
(input [wide-1:0] in1, in2, output [wide-1:0] out);

    assign out = in1 * in2;
    
endmodule
