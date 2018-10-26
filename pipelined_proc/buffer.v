module buffer #(parameter wide = 4)
(input en, input [wide-1:0] in, output [wide-1:0] out);

    assign out = en ? in : 'bz;

endmodule
