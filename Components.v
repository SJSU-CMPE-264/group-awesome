`timescale 1ns / 1ps

module Mux #(parameter INPUTS = 2,
             parameter WIDTH  = 32
) (
    input  wire [$clog2(INPUTS)-1:0] sel,
    input  wire [  INPUTS*WIDTH-1:0] in,
    output wire [         WIDTH-1:0] out
);
    assign out = (in >> (sel * WIDTH));
endmodule // MUX

module TriState #(parameter WIDTH = 32) (
    input  wire             oe,
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);
    assign out = oe ? in : {(WIDTH){1'bz}};
endmodule // TriState

// -----------------------------------------------------
//                     Registers
// -----------------------------------------------------

module DRegister #(parameter WIDTH = 32) (
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    initial q = 0;
    always @(posedge clk, posedge rst) begin
        if      (rst) q <= 0;
        else if (en)  q <= d;
        else          q <= q;
    end
endmodule // DRegister

// -----------------------------------------------------
// 
// -----------------------------------------------------

module Adder #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = a + b;
endmodule // Adder 

module ALU #(parameter WIDTH = 32) (
    input  wire             ctrl,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] y
);
    // initial assign y = {(WIDTH){1'b0}};
    always @(ctrl, a, b) begin
        case (ctrl)
            1'b0: y = a + b; // add
            1'b1: y = a - b; // sub
        endcase
    end
endmodule // ALU 

// -----------------------------------------------------
//               Pipelined Mul Components
// -----------------------------------------------------

module HalfAdder (
    input a, b,
    output p, output g); // p: 1-bit sum, q: carry out
    assign p = a ^ b;
    assign g = a & b;
endmodule

module CLA4 (
    input  wire [3:0] A, B,
    input  wire       cin,
    output wire [3:0] Y,
    output wire       cout );

    wire [3:0] p, g, C;

    // half adders
    HalfAdder adders [3:0] (A, B, p, g);

    // CLA gen
    assign C[0] = cin;
    assign C[1] = g[0] | p[0] & cin;
    assign C[2] = g[1] | p[1] & (g[0] | p[0] & cin);
    assign C[3] = g[2] | p[2] & (g[1] | p[1] & (g[0] | p[0] & cin));
    assign cout = g[3] | p[3] & (g[2] | p[2] & (g[1] | p[1] & (g[0] | p[0] & cin)));

    // sums
    assign Y[0] = C[0] ^ p[0];
    assign Y[1] = C[1] ^ p[1];
    assign Y[2] = C[2] ^ p[2];
    assign Y[3] = C[3] ^ p[3];
endmodule

module CLA32 (
    input  wire [31:0] A, B,
    input  wire        cin,
    output wire [31:0] Y,
    output wire        cout );

    wire [7:0] cla_cin;
    wire [7:0] cla_cout;

    assign cla_cin[0]  = cin;
    assign cout        = cla_cout[7];

    CLA4 cla [7:0] ( .A(A), .B(B), .cin(cla_cin), .Y(Y), .cout(cla_cout) );

    // re-wire cin to cout
    assign cla_cin[1] = cla_cout[0];
    assign cla_cin[2] = cla_cout[1];
    assign cla_cin[3] = cla_cout[2];
    assign cla_cin[4] = cla_cout[3];
    assign cla_cin[5] = cla_cout[4];
    assign cla_cin[6] = cla_cout[5];
    assign cla_cin[7] = cla_cout[6];
endmodule

module CLA64 (
    input  wire [63:0] A, B,
    input  wire        cin,
    output wire [63:0] Y,
    output wire        cout );
    CLA32 u0 ( .A(A[31: 0]), .B(B[31: 0]), .cin(cin),      .Y(Y[31: 0]), .cout(DONT_USE) );
    CLA32 u1 ( .A(A[63:32]), .B(B[63:32]), .cin(DONT_USE), .Y(Y[63:32]), .cout(cout)     );
endmodule

// -----------------------------------------------------
//              FPMUL Address Decoder
// -----------------------------------------------------

module fpmul_addr_decoder(
    input we,
    input [1:0] address,
    output reg we0, we1, we2,
    output reg [1:0] RdSel
    );

always @(*) begin
    RdSel = address;
    case (address)
        2'b00:
            begin
                we0 = we;
                we1 = 1'b0;
                we2 = 1'b0;
            end
        2'b01:
            begin
                we0 = 1'b0;
                we1 = we;
                we2 = 1'b0;
            end
        2'b10:
            begin
                we0 = 1'b0;
                we1 = 1'b0;
                we2 = we;
            end
        2'b11:
            begin
                we0 = 1'b0;
                we1 = 1'b0;
                we2 = 1'b0;
            end
        default:
            begin
                we0 = 1'b0;
                we1 = 1'b0;
                we2 = 1'b0;
            end
    endcase
end

// assign RdSel = address;

endmodule
