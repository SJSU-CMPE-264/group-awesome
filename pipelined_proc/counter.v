module counter #(parameter wide = 4)
(input Clk, Rst, ld, ce, input [wide-1:0] in, output reg [wide-1:0] out);

    always @ (posedge Clk, posedge Rst)
        begin
        if (Rst) out = 0;
        else if (ce) out = ld ? in : out-1;
        else out = out;
        end

endmodule
