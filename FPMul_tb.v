module ;
  wire [7:0] value;
  counter c1 (value, clk, reset);

initial
 begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);
 end
endmodule // 