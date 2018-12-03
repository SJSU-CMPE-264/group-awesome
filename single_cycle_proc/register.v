module register #(parameter wide = 4)
(input Clk, Rst, en, input [wide-1:0] in, output reg [wide-1:0] out);

    always @ (posedge Clk, posedge Rst)
        begin
        if (Rst) out = 0;
        else if (en) out = in;
        else out = out;
        end

endmodule
