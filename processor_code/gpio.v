`timescale 1ns / 1ps

module gpio(input [31:0]WD, [31:0]GPI1, [31:0]GPI2, [1:0]A, [0:0]WE, [0:0]CLK, output [31:0]RD, [31:0]GPO1, [31:0]GPO2 );
    wire WE1_decoder_reg, WE2_decoder_reg;
    wire[1:0] RDSEL_decoder_mux;
    wire[31:0] Q1_reg_mux, Q2_reg_mux;
    
    assign GPO1 = Q1_reg_mux;
    assign GPO2 = Q2_reg_mux;
    
    Address_Decoder U1_decoder(A, WE, WE1_decoder_reg, WE2_decoder_reg, RDSEL_decoder_mux);
    D_Reg U2_reg1(WD, WE1_decoder_reg, CLK, Q1_reg_mux);
    D_Reg U3_reg2(WD, WE2_decoder_reg, CLK, Q2_reg_mux);
    Mux_4 U4_mux(GPI1, GPI2, Q1_reg_mux, Q2_reg_mux, RDSEL_decoder_mux, RD);
     
endmodule


module Address_Decoder(input [1:0]A, [0:0]WE, output reg [0:0]WE1, reg [0:0]WE2, [1:0]RDSEL);
    assign RDSEL = A;
    always @ (WE, A)
    begin
        case ({WE, A})
            3'b110: begin WE1 = 1; WE2 = 0; end
            3'b111: begin WE1 = 0; WE2 = 1; end
            default: begin WE1 = 0; WE2 = 0; end
        endcase
    end
endmodule


module D_Reg(input [31:0]D, [0:0]EN, [0:0]CLK, output reg [31:0]Q);
    always@(posedge CLK) begin
        if(EN) Q = D;
        else Q = Q;
    end
endmodule


module Mux_4(input [31:0]A, [31:0]B, [31:0]C, [31:0]D, [1:0]sel, output reg [31:0]Out);
    always@(sel, A, B, C, D) begin
        case(sel)
            0: Out = A;
            1: Out = B;
            2: Out = C;
            3: Out = D;
            default: Out = 32'b0;   //Error
        endcase
    end
endmodule
