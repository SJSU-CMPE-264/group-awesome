module param_dreg(d, q, we, clk, rst);

parameter width = 32; //Can be set to 1, 10, 23 etc.

input [width-1:0] d;
output reg [width-1:0] q;
input we, clk, rst;

always@(posedge clk) begin
	if(rst) begin
		q = 0;
	end
	else if(we) begin
		q = d;
	end
	else begin
		q = q;
	end
end

endmodule	
