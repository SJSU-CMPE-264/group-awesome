module param_dreg(d, q, we, clk, rst);

parameter width = 32; //Can be set to 1, 10, 23 etc.

input [width-1:0] d;
output [width-1:0] q;
input we, clk, rst;

always@(posedge CLK) begin
	if(rst) q = 0;
	else if(we) q = d;
	else q = q;
end

endmodule		
