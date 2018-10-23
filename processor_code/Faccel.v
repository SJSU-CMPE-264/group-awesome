module faccel
(input clk, rst, we, input [1:0] a, input [3:0] d, output [31:0] out);

    wire we1, we2, go, gopulse, done, status;
    wire [1:0] rdsel;
    wire [3:0] n;
    wire [31:0] nf, nfsig;
    
    assign gopulse = we & d[0];

    adecoder        AD (we, a, we1, we2, rdsel);
    register  #(4)  N  (clk, rst, we1, d, n);
    register  #(1)  G  (clk, rst, we2, d[0], go);
    Factorial #(4)  F  (clk, rst, gopulse, n, done, nf);
    register  #(32) NF (clk, rst, done, nf, nfsig);
    rsreg           S  (clk, rst, gopulse, done, status);
    mux4      #(32) M  ({27'b0, n}, {30'b0, go}, {30'b0, status}, nfsig, rdsel, out);

endmodule

module adecoder
(input we, input [1:0] a, output reg we1, we2, output [1:0] rdsel);

    assign rdsel = a;

    always @ (we, a)
    begin
        case ({we, a})
            3'b100: begin we1 = 1; we2 = 0; end
            3'b101: begin we1 = 0; we2 = 1; end
            default: begin we1 = 0; we2 = 0; end
        endcase
    end

endmodule

module rsreg
(input clk, rst, r, s, output reg out);

    always @ (posedge clk, posedge rst)
    begin
        if (rst) out <= 0;
        else if (r) out <= 0;
        else if (s) out <= 1;
        else out <= out;
    end

endmodule
