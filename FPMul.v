`timescale 1ns / 1ps

module FPMul(
    input wire clk,
    input wire rst,
    output wire [31:0] P,
    output wire        ZF, DNF, InF, NanF, UF, OF
    );
endmodule

module FPMul_DP(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [ 8:0] r_en,
    input  wire [ 3:0] buf_en,
    input  wire [ 1:0] r2_src,
    input  wire [ 1:0] r3_src,
    input  wire        f1_srcB,
    input  wire        f1_ctrl,
    output wire        carry, round, underflow, overflow,
    output wire        AB_NAN, AB_INF, AB_ZERO, AB_DNF,
    output wire [31:0] P,
    output wire        ZF, DNF, InF, NanF, UF, OF
);
    wire [23:0] bus1;
    wire [23:0] bus2;
    wire        bus3;
    wire [10:0] flags;

    wire        R1_in;
    wire [ 9:0] R2_in;
    wire [23:0] R3_in;
    wire        R1_out;
    wire [ 9:0] R2_out;
    wire [23:0] R3_out;
    wire        R4_out;
    wire [ 7:0] R5_out;
    wire [23:0] R6_out;

    wire [9:0] eb_src_out;
    wire [9:0] f1_srcB_out;
    wire [9:0] f1_out;

    wire [63:0] mul_out;

    wire [23:0] adder_out;
    wire        adder_carry_out;

    wire [23:0] mux5_out, mux6_out;

    assign carry     = R4_out;
    assign round     = flags[6];
    assign underflow = flags[5];
    assign overflow  = flags[4];
    assign AB_NAN    = flags[3];
    assign AB_INF    = flags[2];
    assign AB_ZERO   = flags[1];
    assign AB_DNF    = flags[0];
    
    Mux #(2,  1) R1_src_mux ( .sel(buf_en[0]), 
                              .in({
                                  A[31:0],          // 1
                                  r1_out ^ r4_out   // 0
                               }), 
                              .out(R1_in) );
    Mux #(4, 10) R2_src_mux ( .sel(r2_src), 
                              .in({ 
                                  {10{1'b1}},       // 11
                                  {10{1'b0}},       // 10
                                  f1_out,           // 01
                                  {2'b0, A[30:23]}  // 00
                               }), 
                              .out(R2_in) );
    Mux #(4, 24) R3_src_mux ( .sel(r3_src), 
                              .in({ 
                                  {24{1'b1}},       // 11
                                  {24{1'b0}},       // 10
                                  bus1,             // 01
                                  {2'b0, A[22:0]}   // 00
                               }), 
                              .out(R3_in) );
    
    TriState #( 1) buffer1 ( .oe(buf_en[0]),
                             .in(B[31]),
                             .out(bus3) );
    TriState #(24) buffer2 ( .oe(buf_en[0]),
                             .in({1'b0, B[22:0]}),
                             .out(bus2) );

    DRegister #( 1) R1 ( .clk(clk), .rst(rst),
                         .en(r_en[0]),
                         .d(R1_in),
                         .q(R1_out) );
    DRegister #(10) R2 ( .clk(clk), .rst(rst),
                         .en(r_en[1]),
                         .d(R2_in),
                         .q(R2_out) );
    DRegister #(24) R3 ( .clk(clk), .rst(rst),
                         .en(r_en[2]),
                         .d(R3_in),
                         .q(R3_out) );
    DRegister #( 1) R4 ( .clk(clk), .rst(rst),
                         .en(r_en[3]),
                         .d(bus3),
                         .q(R4_out) );
    DRegister #( 8) R5 ( .clk(clk), .rst(rst),
                         .en(r_en[4]),
                         .d(B[30:23]),
                         .q(R5_out) );
    DRegister #(24) R6 ( .clk(clk), .rst(rst),
                         .en(r_en[5]),
                         .d(bus2),
                         .q(R6_out) );

    Mux #(2, 10) mux4        ( .sel(f1_ctrl),
                               .in({
                                    10'h7F, // 127        // 1
                                    { 2'b0, R5_out[7:0] } // 0
                               }),
                               .out(eb_src_out) );
    Mux #(2, 10) f1_srcB_mux ( .sel(f1_srcB),
                               .in({
                                    {10{1'b1}},  // 1
                                    eb_src_out   // 0
                               }),
                               .out(f1_srcB_out) );
    ALU #(10)     F1         ( .ctrl(f1_ctrl),
                               .a(R2_out), 
                               .b(f1_srcB_out), 
                               .y(f1_out );
    
    // Pipelined Multiplier
    Mul            mul               ( .clk(clk), .rst(rst), 
                                       .a({ 1'b0, R3_out }), 
                                       .b({ 1'b0, R6_out }), 
                                       .y(mul_out) );
    TriState #(24) mul_out_hi_buffer ( .oe(buf_en[3]), 
                                       .in(mul_out[47:24]), 
                                       .out(bus1) );
    TriState #(24) mul_out_lo_buffer ( .oe(buf_en[3]), 
                                       .in(mul_out[23:0]), 
                                       .out(bus2) );

    Adder    #(24) adder               ( .a(R3_out), 
                                         .b(24'b1),
                                         .y(adder_out),
                                         .carry(carry) );
    TriState #(24) adder_out_buffer   ( .oe(buf_en[2]), 
                                        .in(adder_out), 
                                        .out(bus1) );
    TriState #( 1) adder_carry_buffer ( .oe(buf_en[2]), 
                                        .in(adder_carry_out), 
                                        .out(bus3) );

    Mux      #(2, 24) mux5            ( .sel(f1_ctrl),
                                        .in({
                                            { R3_out[22:0], R6_out[23] }, // 1
                                            R3_out                        // 0
                                            }),
                                        .out(mux5_out) );
    Mux      #(2, 24) mux6            ( .sel(f1_ctrl),
                                        .in({
                                            { R6_out[22:0], R1'b0 }, // 1
                                            R6_out                   // 0
                                            }),
                                        .out(mux6_out) );
    TriState #(24)    mux5_out_buffer ( .oe(buf_en[1]), 
                                        .in(mux5_out), 
                                        .out(bus1) );
    TriState #(24)    mux6_out_buffer ( .oe(buf_en[1]), 
                                        .in(mux6_out), 
                                        .out(bus2) );

    DRegister #(32) P_register      ( .clk(clk), .rst(rst),
                                      .en(r_en[8]),
                                      .d({ R1_out, R2_out[7:0], R3_out[22:0] }),
                                      .q(P);
    DRegister #(32) P_ZF_register   ( .clk(clk), .rst(rst),
                                      .en(r_en[8]),
                                      .d(flags[10]),
                                      .q(ZF);
    DRegister #(32) P_DNF_register  ( .clk(clk), .rst(rst),
                                      .en(r_en[8]),
                                      .d(flags[9]),
                                      .q(DNF);
    DRegister #(32) P_InfF_register ( .clk(clk), .rst(rst),
                                      .en(r_en[8]),
                                      .d(flags[8]),
                                      .q(InfF);
    DRegister #(32) P_NanF_register ( .clk(clk), .rst(rst),
                                      .en(r_en[8]),
                                      .d(flags[7]),
                                      .q(NanF);    
    DRegister #(32) P_UF_register   ( .clk(clk), .rst(rst),
                                      .en(r_en[7]),
                                      .d(flags[5]),
                                      .q(UF);
    DRegister #(32) P_OF_register   ( .clk(clk), .rst(rst),
                                      .en(r_en[6]),
                                      .d(flags[4]),
                                      .q(DF);

endmodule // FPMul_CU

module FPMul_CU(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       MP23,
    input  wire       carry, round, underflow, overflow,
    output wire [3:0] buf_en,
    output wire [8:0] r_en,
    output wire [1:0] r2_src,
    output wire [1:0] r3_src,
    output wire       shift sel,
    output wire       f1_srcB,
    output wire       f1_ctrl,
    output wire       done,
    output wire [3:0] cs
);

parameter S0  = 4'b0000,
          S1  = 4'b0001,
          S2  = 4'b0010,
          S3  = 4'b0011,
          S4  = 4'b0100,
          S5  = 4'b0101,
          S6  = 4'b0110,
          S7  = 4'b0111,
          S8  = 4'b1000,
          S9  = 4'b1001,
          S10 = 4'b1010,
          S11 = 4'b1011,
          S12 = 4'b1100,
          S13 = 4'b1101;

parameter CTRL_RST   = 22'b1_0_0000_0_00_000000_00_00_0_0_0, 
          CTRL_WAIT  = 22'b0_0_0000_0_00_000000_00_00_0_0_0,
          CTRL_LOAD  = 22'b0_0_0001_0_00_111111_00_00_0_0_0,
          CTRL_SPEP  = 22'b0_0_0000_0_00_000011_01_00_0_0_0,
          CTRL_BIAS  = 22'b0_0_0000_0_00_000010_01_00_0_0_1,
          CTRL_NAN   = 22'b0_0_0000_0_00_000110_11_11_0_0_0,
          CTRL_INF   = 22'b0_0_0000_0_00_000110_11_10_0_0_0,
          CTRL_ZERO  = 22'b0_0_0000_0_00_000110_10_10_0_0_0.
          CTRL_DNF   = 22'b0_0_0000_0_00_000110_10_11_0_0_0,
          CTRL_MUL   = 22'b0_0_1000_0_00_100100_00_01_0_0_0,
          CTRL_INCEP = 22'b0_0_0000_0_00_000010_01_00_0_1_0,
          CTRL_SHIFT = 22'b0_0_0010_0_00_100100_00_01_1_0_0,
          CTRL_ROUND = 22'b0_0_0100_0_00_001100_00_01_0_0_0,
          CTRL_UF    = 22'b0_0_0000_0_10_000000_10_10_0_0_0,
          CTRL_OF    = 22'b0_0_0000_0_01_000000_11_10_0_0_0,
          CTRL_LOADP = 22'b0_0_0000_1_00_000000_00_00_0_0_0,
          CTRL_DONE  = 22'b1_0_0000_0_00_000000_00_00_0_0_0;

    reg [3:0] ns; // next state
    reg [21:0] ctrl;

    assign { done, buf_en, r_en, r2_src, r3_src, shift_sel, f1_srcB, f1_ctrl } = ctrl;

    always @(posedge clk, posedge rst) begin
        if (rst) cs <= S1;
        else     cs <= S1;
    end

    always @(start, MP23, carry, round, underflow, overflow, AB_NAN, AB_INF, AB_ZERO, AB_DNF) begin
        case (cs)
            S0:  begin ctrl = CTRL_RST;  ns = S1; end
            S1:  begin ctrl = CTRL_LOAD; ns = S2; end
            S2:  begin ctrl = CTRL_SPEP; ns = S3; end
            S3:  begin ctrl = CTRL_BIAS; ns = S4; end
            S4:  begin 
                ctrl = CTRL_MUL; ns = S5; 
                if      (AB_NAN)  begin ctrl = CTRL_NAN;  ns = S11; end
                else if (AB_INF)  begin ctrl = CTRL_INF;  ns = S11; end
                else if (AB_ZERO) begin ctrl = CTRL_ZERO; ns = S11; end
                else if (AB_DNF)  begin ctrl = CTRL_DNF;  ns = S11; end
            end
            S5:  begin 
                ctrl = CTRL_WAIT; ns = S6; 
                if (MP23) ctrl = CTRL_INCEP;
                else      ctrl = CTRL_SHIFT;
            end
            S6:  begin ctrl = CTRL_WAIT; ns = S7; end
            S7:  begin 
                ctrl = CTRL_WAIT; ns = S8; 
                if (round) ctrl = CTRL_ROUND;
            end
            S8:  begin 
                ctrl = CTRL_WAIT; ns = S9;
                if (carry) ctrl = CTRL_INCEP;
            end
            S9:  begin ctrl = CTRL_WAIT; ns = S10; end
            S10: begin 
                ctrl = CTRL_WAIT; ns = S13;
                if      (underflow) ctrl = CTRL_UF; ns = S11;
                else if (overflow)  ctrl = CTRL_OF; ns = S11;
            end
            S11: begin ctrl = CTRL_WAIT; ns = S12; end
            S12: begin ctrl = CTRL_WAIT; ns = S13; end
            S13: begin ctrl = CTRL_DONE; ns = S1;  end
        endcase
    end

endmodule // FPMul_CU
