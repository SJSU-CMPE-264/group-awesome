module compare #(parameter wide = 4)
(input  [wide-1:0] in1, in2, output out);

    assign out = in1 > in2;

endmodule
