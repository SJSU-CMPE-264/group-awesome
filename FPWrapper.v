`timescale 1ns / 1ps

module fpmul_addr_decoder(
	input we,
	input [1:0] address,
	output reg we0, we1, we2,
	output reg [1:0] RdSel
	);

always @(*) begin
	case (address)
		2'b00
			begin
				we0 = 1'b1;
				we1 = 1'b0;
				we2 = 1'b0;
				RdSel = 2'b00;
			end
		2'b01
			begin
				we0 = 1'b0;
				we1 = 1'b1;
				we2 = 1'b0;
				RdSel = 2'b01;
			end
		2'b10
			begin
				we0 = 1'b0;
				we1 = 1'b0;
				we2 = 1'b1;
				RdSel = 2'b10;
			end
		2'b11
			begin
				we0 = 1'b0;
				we1 = 1'b1;
				we2 = 1'b0;
				RdSel = 2'b01;
			end
	endcase
end

endmodule
