`timescale 1ns / 1ps

// -----------------------------------------------------
//                   FPMul Top Level
// -----------------------------------------------------
module FPMul (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire        done,
    output wire [31:0] P,
    output wire        OF, UF, NanF, InfF, DNF, ZF
);
endmodule

// -----------------------------------------------------
//                   FPMul Data Path
// -----------------------------------------------------
module FPMul_DP (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        p_rst,
    input  wire [ 4:0] buf_en,
    input  wire [ 8:0] r_en,
    input  wire [ 1:0] r2_src,
    input  wire [ 1:0] r3_src,
    input  wire        shift_sel,
    input  wire        f1_srcB,
    input  wire        f1_ctrl,
    output wire        nan, inf, zero,
    output wire        mp23, round, mph_h, underflow, overflow,
    output wire [31:0] P,
    output wire        OF, UF, NanF, InfF, DNF, ZF
);
    wire [23:0] bus1;
    wire [23:0] bus2;
    wire [11:0] flags;
    
    wire        R1_in;
    wire [ 9:0] R2_in;
    wire [23:0] R3_in;
    wire        R1_out;
    wire [ 9:0] R2_out;
    wire [23:0] R3_out;
    wire        R4_out;
    wire [ 7:0] R5_out;
    wire [23:0] R6_out;
    
    wire [ 9:0] eb_src_out;
    wire [ 9:0] f1_srcB_out;
    wire [ 9:0] f1_out;
    wire [63:0] mul_out;
    wire [23:0] adder_out;
    wire [23:0] mux5_out, mux6_out;

    assign mp23      = R3_out[23];

    assign mph_h     = flags[7];
    assign round     = flags[6];
    assign underflow = flags[5];
    assign overflow  = flags[4];
    assign nan       = flags[3];
    assign inf       = flags[2];
    assign zero      = flags[1];
    assign dnf       = flags[0]; // TODO: remove me
    
    Mux #(2,  1) R1_src_mux ( .sel(buf_en[0]), 
                              .in({
                                  A[31],          // 1
                                  R1_out ^ R4_out // 0
                               }), 
                              .out(R1_in) );
    Mux #(4, 10) R2_src_mux ( .sel(r2_src), 
                              .in({ 
                                  {10{1'b1}},      // 11
                                  {10{1'b0}},      // 10
                                  f1_out,          // 01
                                  {2'b0, A[30:23]} // 00
                               }), 
                              .out(R2_in) );
    Mux #(4, 24) R3_src_mux ( .sel(r3_src), 
                              .in({ 
                                  {24{1'b1}},     // 11
                                  {24{1'b0}},     // 10
                                  bus1,           // 01
                                  {1'b0, A[22:0]} // 00
                               }), 
                              .out(R3_in) );

    TriState #(24) buffer1 ( .oe(buf_en[0]),
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
                         .d(B[31]),
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
                               .y(f1_out) );
    
    // Auxillary Flag Generation
    AuxFlagGen AUX ( .clk(clk), .rst(rst),
                     .EAP(R2_out),
                     .EB(R5_out[7:0]),
                     .MAP(R3_out[22:0]),
                     .MBP(R6_out),
                     .flags(flags) );

    // Pipelined Multiplier
    Mul            mul               ( .clk(clk), .rst(rst), 
                                       .a({ 8'b0, R3_out }), 
                                       .b({ 8'b0, R6_out }), 
                                       .y(mul_out) );
    TriState #(24) mul_out_hi_buffer ( .oe(buf_en[4]), 
                                       .in(mul_out[47:24]), 
                                       .out(bus1) );
    TriState #(24) mul_out_lo_buffer ( .oe(buf_en[4]), 
                                       .in(mul_out[23:0]), 
                                       .out(bus2) );

    Adder    #(24) adder               ( .a(R3_out), 
                                         .b(24'b1),
                                         .y(adder_out) );
    TriState #(24) adder_out_buffer   ( .oe(buf_en[3]), 
                                        .in(adder_out), 
                                        .out(bus1) );
    TriState #(24) round_buffer       ( .oe(buf_en[2]), 
                                        .in(24'h800_000), // 0x800000
                                        .out(bus1) );

    // MPH and MPL shift
    Mux      #(2, 24) mux5            ( .sel(shift_sel),
                                        .in({
                                            { R3_out[22:0], R6_out[23] }, // 1
                                            R3_out                        // 0
                                            }),
                                        .out(mux5_out) );
    Mux      #(2, 24) mux6            ( .sel(shift_sel),
                                        .in({
                                            { R6_out[22:0], 1'b0 }, // 1
                                            R6_out                  // 0
                                        }),
                                        .out(mux6_out) );
    TriState #(24)    mux5_out_buffer ( .oe(buf_en[1]), 
                                        .in(mux5_out), 
                                        .out(bus1) );
    TriState #(24)    mux6_out_buffer ( .oe(buf_en[1]), 
                                        .in(mux6_out), 
                                        .out(bus2) );

    DRegister #(32) P_register      ( .clk(clk), .rst(p_rst),
                                      .en(r_en[8]),
                                      .d({ R1_out, R2_out[7:0], R3_out[22:0] }),
                                      .q(P) );
    DRegister #( 1) P_ZF_register   ( .clk(clk), .rst(p_rst),
                                      .en(r_en[8]),
                                      .d(flags[11]),
                                      .q(ZF) );
    DRegister #( 1) P_DNF_register  ( .clk(clk), .rst(p_rst),
                                      .en(r_en[8]),
                                      .d(flags[10]),
                                      .q(DNF) );
    DRegister #( 1) P_InfF_register ( .clk(clk), .rst(p_rst),
                                      .en(r_en[8]),
                                      .d(flags[9]),
                                      .q(InfF) );
    DRegister #( 1) P_NanF_register ( .clk(clk), .rst(p_rst),
                                      .en(r_en[8]),
                                      .d(flags[8]),
                                      .q(NanF) );    
    DRegister #( 1) P_UF_register   ( .clk(clk), .rst(p_rst),
                                      .en(r_en[7]),
                                      .d(flags[5]),
                                      .q(UF) );
    DRegister #( 1) P_OF_register   ( .clk(clk), .rst(p_rst),
                                      .en(r_en[6]),
                                      .d(flags[4]),
                                      .q(OF) );

endmodule // FPMul_DP

// -----------------------------------------------------
//                 FPMul Control Unit
// -----------------------------------------------------
module FPMul_CU (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       nan, inf, zero,
    input  wire       mp23, 
    input  wire       mph_h, round, 
    input  wire       underflow, overflow,
    output wire       done,
    output wire       p_rst,
    output wire [4:0] buf_en,
    output wire [8:0] r_en,
    output wire [1:0] r2_src,
    output wire [1:0] r3_src,
    output wire       shift_sel,
    output wire       f1_srcB,
    output wire       f1_ctrl
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
          S9  = 4'b1001;

parameter CTRL_RESET = 23'b0_1_00000_0_00_000000_00_00_0_0_0,
          CTRL_WAIT  = 23'b0_0_00000_0_00_000000_00_00_0_0_0,
          CTRL_LOAD  = 23'b0_0_00001_0_00_111111_00_00_0_0_0,
          CTRL_START = 23'b0_0_00000_0_00_000011_01_00_0_0_0,
          CTRL_BIAS  = 23'b0_0_00000_0_00_000010_01_00_0_0_1,
          CTRL_NAN   = 23'b0_0_00000_0_00_000110_11_11_0_0_0,
          CTRL_INF   = 23'b0_0_00000_0_00_000110_11_10_0_0_0,
          CTRL_ZERO  = 23'b0_0_00000_0_00_000110_10_10_0_0_0,
          CTRL_MULT  = 23'b0_0_10000_0_00_100100_00_01_0_0_0,
          CTRL_SHIFT = 23'b0_0_00010_0_00_100100_00_01_1_0_0,
          CTRL_NORM  = 23'b0_0_00000_0_00_000010_01_00_0_1_0,
          CTRL_ROUND = 23'b0_0_01000_0_00_000100_00_01_0_0_0,
          CTRL_MPH_H = 23'b0_0_00100_0_00_000110_01_01_0_1_0,
          CTRL_OF    = 23'b0_0_00000_0_01_000110_11_01_0_0_0,
          CTRL_UF    = 23'b0_0_00000_0_10_000110_01_01_0_0_0,
          CTRL_LOADP = 23'b0_0_00000_1_00_000000_00_00_0_0_0,
          CTRL_DONE  = 23'b1_0_00000_0_00_000000_00_00_0_0_0;

    reg [ 3:0] cs;   // current state
    reg [ 3:0] ns;   // next state
    reg [22:0] ctrl; // control signal bus

    assign { done, p_rst, buf_en, r_en, r2_src, r3_src, shift_sel, f1_srcB, f1_ctrl } = ctrl;

    always @(posedge clk, posedge rst) begin
        if (rst) cs <= S0;
        else     cs <= ns;
    end

    always @(start, nan, inf, zero, mp23, mph_h, round, underflow, overflow) begin
        case (cs)
            S0: begin ctrl = CTRL_RESET; ns = S1; end
            S1: begin 
                if (start) begin ctrl = CTRL_LOAD; ns = S2; end
                else       begin ctrl = CTRL_WAIT; ns = S1; end
            end
            S2: begin ctrl = CTRL_START; ns = S3; end
            S3: begin ctrl = CTRL_BIAS;  ns = S4; end
            S4: begin
                case ({ nan, inf, zero })
                    3'b1xx:  begin ctrl = CTRL_NAN;  ns = S8; end // nan
                    3'b01x:  begin ctrl = CTRL_INF;  ns = S8; end // inf
                    3'b001:  begin ctrl = CTRL_ZERO; ns = S8; end // zero
                    default: begin ctrl = CTRL_WAIT; ns = S5; end // denormalized or no abnormalities
                endcase
            end
            S5: begin
                ctrl = mp23 ? CTRL_NORM : CTRL_SHIFT;
                ns = S6;
            end
            S6: begin
                ctrl = CTRL_WAIT; ns = S7;
                if      (round && !mph_h) ctrl = CTRL_ROUND;
                else if (round &&  mph_h) ctrl = CTRL_MPH_H;
            end
            S7: begin
                ctrl = CTRL_WAIT; ns = S8;
                if      (overflow)  ctrl = CTRL_OF;
                else if (underflow) ctrl = CTRL_UF;
            end
            S8: begin ctrl = CTRL_LOADP; ns = S9; end
            S9: begin ctrl = CTRL_DONE;  ns = S0; end
        endcase
    end
endmodule // FPMul_CU
