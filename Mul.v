`timescale 1ns / 1ps

// 32-bit 2-stage pipelined multiplier
module Mul(
    input  wire        clk, 
    input  wire        rst,
    input  wire [31:0] a, 
    input  wire [31:0] b,
    output wire [63:0] y
);
    wire        DONT_USE;
    wire        cout[0:15], cout2[0:7], cout3[0:3], cout4[0:1];
    wire [31:0] q0[0:1], PP[0:31];
    wire [63:0] q1[0:15], q2[0:15], q3[0:7], q4[0:3], q5[0:1];

    // Stage 1
    DRegister   u0 ( .clk(clk), .rst(rst), .en(1'b1), .d(a), .q(q0[0]) );
    DRegister   u1 ( .clk(clk), .rst(rst), .en(1'b1), .d(b), .q(q0[1]) );

    assign PP[ 0] = q0[0] & { (32){ q0[1][ 0] } };
    assign PP[ 1] = q0[0] & { (32){ q0[1][ 1] } };
    assign PP[ 2] = q0[0] & { (32){ q0[1][ 2] } };
    assign PP[ 3] = q0[0] & { (32){ q0[1][ 3] } };
    assign PP[ 4] = q0[0] & { (32){ q0[1][ 4] } };
    assign PP[ 5] = q0[0] & { (32){ q0[1][ 5] } };
    assign PP[ 6] = q0[0] & { (32){ q0[1][ 6] } };
    assign PP[ 7] = q0[0] & { (32){ q0[1][ 7] } };
    assign PP[ 8] = q0[0] & { (32){ q0[1][ 8] } };
    assign PP[ 9] = q0[0] & { (32){ q0[1][ 9] } };
    assign PP[10] = q0[0] & { (32){ q0[1][10] } };
    assign PP[11] = q0[0] & { (32){ q0[1][11] } };
    assign PP[12] = q0[0] & { (32){ q0[1][12] } };
    assign PP[13] = q0[0] & { (32){ q0[1][13] } };
    assign PP[14] = q0[0] & { (32){ q0[1][14] } };
    assign PP[15] = q0[0] & { (32){ q0[1][15] } };
    assign PP[16] = q0[0] & { (32){ q0[1][16] } };
    assign PP[17] = q0[0] & { (32){ q0[1][17] } };
    assign PP[18] = q0[0] & { (32){ q0[1][18] } };
    assign PP[19] = q0[0] & { (32){ q0[1][19] } };
    assign PP[20] = q0[0] & { (32){ q0[1][20] } };
    assign PP[21] = q0[0] & { (32){ q0[1][21] } };
    assign PP[22] = q0[0] & { (32){ q0[1][22] } };
    assign PP[23] = q0[0] & { (32){ q0[1][23] } };
    assign PP[24] = q0[0] & { (32){ q0[1][24] } };
    assign PP[25] = q0[0] & { (32){ q0[1][25] } };
    assign PP[26] = q0[0] & { (32){ q0[1][26] } };
    assign PP[27] = q0[0] & { (32){ q0[1][27] } };
    assign PP[28] = q0[0] & { (32){ q0[1][28] } };
    assign PP[29] = q0[0] & { (32){ q0[1][29] } };
    assign PP[30] = q0[0] & { (32){ q0[1][30] } };
    assign PP[31] = q0[0] & { (32){ q0[1][31] } };

    CLA64 u2  ( .A({ 32'b0, PP[ 0]        }), .B({ 31'b0, PP[ 1],  1'b0 }), .cin(1'b0), .Y(q1[ 0]), .cout(DONT_USE) );
    CLA64 u3  ( .A({ 30'b0, PP[ 2],  2'b0 }), .B({ 29'b0, PP[ 3],  3'b0 }), .cin(1'b0), .Y(q1[ 1]), .cout(DONT_USE) );
    CLA64 u4  ( .A({ 28'b0, PP[ 4],  4'b0 }), .B({ 27'b0, PP[ 5],  5'b0 }), .cin(1'b0), .Y(q1[ 2]), .cout(DONT_USE) );
    CLA64 u5  ( .A({ 26'b0, PP[ 6],  6'b0 }), .B({ 25'b0, PP[ 7],  7'b0 }), .cin(1'b0), .Y(q1[ 3]), .cout(DONT_USE) );
    CLA64 u6  ( .A({ 24'b0, PP[ 8],  8'b0 }), .B({ 23'b0, PP[ 9],  9'b0 }), .cin(1'b0), .Y(q1[ 4]), .cout(DONT_USE) );
    CLA64 u7  ( .A({ 22'b0, PP[10], 10'b0 }), .B({ 21'b0, PP[11], 11'b0 }), .cin(1'b0), .Y(q1[ 5]), .cout(DONT_USE) );
    CLA64 u8  ( .A({ 20'b0, PP[12], 12'b0 }), .B({ 19'b0, PP[13], 13'b0 }), .cin(1'b0), .Y(q1[ 6]), .cout(DONT_USE) );
    CLA64 u9  ( .A({ 18'b0, PP[14], 14'b0 }), .B({ 17'b0, PP[15], 15'b0 }), .cin(1'b0), .Y(q1[ 7]), .cout(DONT_USE) );
    CLA64 u10 ( .A({ 16'b0, PP[16], 16'b0 }), .B({ 15'b0, PP[17], 17'b0 }), .cin(1'b0), .Y(q1[ 8]), .cout(DONT_USE) );
    CLA64 u11 ( .A({ 14'b0, PP[18], 18'b0 }), .B({ 13'b0, PP[19], 19'b0 }), .cin(1'b0), .Y(q1[ 9]), .cout(DONT_USE) );
    CLA64 u12 ( .A({ 12'b0, PP[20], 20'b0 }), .B({ 11'b0, PP[21], 21'b0 }), .cin(1'b0), .Y(q1[10]), .cout(DONT_USE) );
    CLA64 u13 ( .A({ 10'b0, PP[22], 22'b0 }), .B({  9'b0, PP[23], 23'b0 }), .cin(1'b0), .Y(q1[11]), .cout(DONT_USE) );
    CLA64 u14 ( .A({  8'b0, PP[24], 24'b0 }), .B({  7'b0, PP[25], 25'b0 }), .cin(1'b0), .Y(q1[12]), .cout(DONT_USE) );
    CLA64 u15 ( .A({  6'b0, PP[26], 26'b0 }), .B({  5'b0, PP[27], 27'b0 }), .cin(1'b0), .Y(q1[13]), .cout(DONT_USE) );
    CLA64 u16 ( .A({  4'b0, PP[28], 28'b0 }), .B({  3'b0, PP[29], 29'b0 }), .cin(1'b0), .Y(q1[14]), .cout(DONT_USE) );
    CLA64 u17 ( .A({  2'b0, PP[30], 30'b0 }), .B({  1'b0, PP[31], 31'b0 }), .cin(1'b0), .Y(q1[15]), .cout(DONT_USE) );

    // Stage 2
    DRegister #(64)  q2_0  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 0]), .q(q2[ 0]) );
    DRegister #(64)  q2_1  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 1]), .q(q2[ 1]) );
    DRegister #(64)  q2_2  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 2]), .q(q2[ 2]) );
    DRegister #(64)  q2_3  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 3]), .q(q2[ 3]) );
    DRegister #(64)  q2_4  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 4]), .q(q2[ 4]) );
    DRegister #(64)  q2_5  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 5]), .q(q2[ 5]) );
    DRegister #(64)  q2_6  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 6]), .q(q2[ 6]) );
    DRegister #(64)  q2_7  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 7]), .q(q2[ 7]) );
    DRegister #(64)  q2_8  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 8]), .q(q2[ 8]) );
    DRegister #(64)  q2_9  ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[ 9]), .q(q2[ 9]) );
    DRegister #(64)  q2_10 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[10]), .q(q2[10]) );
    DRegister #(64)  q2_11 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[11]), .q(q2[11]) );
    DRegister #(64)  q2_12 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[12]), .q(q2[12]) );
    DRegister #(64)  q2_13 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[13]), .q(q2[13]) );
    DRegister #(64)  q2_14 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[14]), .q(q2[14]) );
    DRegister #(64)  q2_15 ( .clk(clk), .rst(rst), .en(1'b1), .d(q1[15]), .q(q2[15]) );

    CLA64 u18 ( .A(q2[ 0]), .B(q2[ 1]), .cin(1'b0), .Y(q3[0]), .cout(DONT_USE) );
    CLA64 u19 ( .A(q2[ 2]), .B(q2[ 3]), .cin(1'b0), .Y(q3[1]), .cout(DONT_USE) );
    CLA64 u20 ( .A(q2[ 4]), .B(q2[ 5]), .cin(1'b0), .Y(q3[2]), .cout(DONT_USE) );
    CLA64 u21 ( .A(q2[ 6]), .B(q2[ 7]), .cin(1'b0), .Y(q3[3]), .cout(DONT_USE) );
    CLA64 u22 ( .A(q2[ 8]), .B(q2[ 9]), .cin(1'b0), .Y(q3[4]), .cout(DONT_USE) );
    CLA64 u23 ( .A(q2[10]), .B(q2[11]), .cin(1'b0), .Y(q3[5]), .cout(DONT_USE) );
    CLA64 u24 ( .A(q2[12]), .B(q2[13]), .cin(1'b0), .Y(q3[6]), .cout(DONT_USE) );
    CLA64 u25 ( .A(q2[14]), .B(q2[15]), .cin(1'b0), .Y(q3[7]), .cout(DONT_USE) );

    CLA64 u26 ( .A(q3[0]), .B(q3[1]), .cin(1'b0), .Y(q4[0]), .cout(DONT_USE) );
    CLA64 u27 ( .A(q3[2]), .B(q3[3]), .cin(1'b0), .Y(q4[1]), .cout(DONT_USE) );
    CLA64 u28 ( .A(q3[4]), .B(q3[5]), .cin(1'b0), .Y(q4[2]), .cout(DONT_USE) );
    CLA64 u29 ( .A(q3[6]), .B(q3[7]), .cin(1'b0), .Y(q4[3]), .cout(DONT_USE) );

    CLA64 u30 ( .A(q4[0]), .B(q4[1]), .cin(1'b0), .Y(q5[0]), .cout(DONT_USE) );
    CLA64 u31 ( .A(q4[2]), .B(q4[3]), .cin(1'b0), .Y(q5[1]), .cout(DONT_USE) );

    CLA64 u32 ( .A(q5[0]), .B(q5[1]), .cin(1'b0), .Y(y), .cout(DONT_USE) );
endmodule
