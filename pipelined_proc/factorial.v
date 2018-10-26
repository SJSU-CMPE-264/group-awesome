module Factorial #(parameter iwide = 4, owide = 32)
(input clk, rst, go, input [iwide-1:0] in, output done, output [owide-1:0] out);

    wire cld_sig, cen_sig, s1_sig, ren_sig, ben_sig, greater_sig;

    DP #(iwide, owide) U1 (clk, rst, cld_sig, cen_sig, s1_sig, ren_sig, ben_sig, in, greater_sig, out);
    CU                 U2 (clk, rst, go, greater_sig, cld_sig, cen_sig, s1_sig, ren_sig, ben_sig, done);

endmodule
