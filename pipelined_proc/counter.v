module counter #(parameter wide = 4)
(input clk, rst, ld, ce, input [wide-1:0] in, output reg [wide-1:0] out);

    always @ (posedge clk, posedge rst)
        begin
        if (rst) out = 0;
        else if (ce) out = ld ? in : out-1;
        else out = out;
        end

endmodule
