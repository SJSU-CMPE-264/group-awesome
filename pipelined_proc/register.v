module register #(parameter wide = 4)
(input clk, rst, en, input [wide-1:0] in, output reg [wide-1:0] out);

    always @ (posedge clk, posedge rst)
        begin
        if (rst) out = 0;
        else if (en) out = in;
        else out = out;
        end

endmodule
