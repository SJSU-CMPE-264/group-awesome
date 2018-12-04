`timescale 1ns / 1ps

// Aux Flag Generation for FPMUL
module AuxFlagGen(
    input  wire        Clk,
    input  wire        Rst,
    input  wire [ 9:0] EAP,
    input  wire [ 7:0] EB,
    input  wire [22:0] MAP,
    input  wire [23:0] MBP,
    output wire [11:0] flags
);
    wire EAP_ZF;
    wire EAP_HF;
    wire MAP_ZF;
    wire EB_ZF;
    wire EB_HF;
    wire MBP_ZF;

    wire A_ZF;
    wire A_DNF;
    wire A_INFF;
    wire A_NANF;
    wire B_ZF;
    wire B_DNF;
    wire B_INFF;
    wire B_NANF;

    wire AB_NAN;
    wire AB_INF;
    wire AB_ZERO;
    wire AB_DNF;

    wire guard;
    wire lsb;
    wire sticky;
    wire round;

    wire underflow;
    wire overflow;

    wire P_ZF;
    wire P_DNF;
    wire P_INFF;
    wire P_NANF;

    // round bit
    assign guard  = MBP[23];
    assign lsb    = MAP[0];
    assign sticky = |MBP[22:0];
    assign round  = guard & ( lsb | sticky );

    assign underflow = EAP[9];
    assign overflow  = ( ~EAP[9] & EAP[8] ) | EAP_HF;

    // flag bus
    assign flags = { P_ZF, P_DNF, P_INFF, P_NANF,            // [11:8]
                     &MAP[22:0], round, underflow, overflow, // [ 7:4]
                     AB_NAN, AB_INF, AB_ZERO, AB_DNF };      // [ 3:0]

    DRegister #(1) EAP_ZF_reg (.Clk(Clk), .Rst(Rst), .en(1'b1), .d(~|EAP[ 7:0]), .q(EAP_ZF));
    DRegister #(1) EAP_HF_reg (.Clk(Clk), .Rst(Rst), .en(1'b1), .d( &EAP[ 7:0]), .q(EAP_HF));
    DRegister #(1) MAP_ZF_reg (.Clk(Clk), .Rst(Rst), .en(1'b1), .d(~|MAP[22:0]), .q(MAP_ZF));
    DRegister #(1) MAP_HF_reg (.Clk(Clk), .Rst(Rst), .en(1'b1), .d( &MAP[22:0]), .q(MAP_HF));
    DRegister #(1) EB_ZF_reg  (.Clk(Clk), .Rst(Rst), .en(1'b1), .d( ~|EB[ 7:0]), .q(EB_ZF ));
    DRegister #(1) EB_HF_reg  (.Clk(Clk), .Rst(Rst), .en(1'b1), .d(  &EB[ 7:0]), .q(EB_HF ));
    DRegister #(1) MB_ZF_reg  (.Clk(Clk), .Rst(Rst), .en(1'b1), .d(~|MBP[22:0]), .q(MBP_ZF));
    DRegister #(1) MB_HF_reg  (.Clk(Clk), .Rst(Rst), .en(1'b1), .d( &MBP[22:0]), .q(MBP_HF));

    assign A_ZF   = EAP_ZF &  MAP_ZF;
    assign A_DNF  = EAP_ZF & ~MAP_ZF;
    assign A_INFF = EAP_HF &  MAP_ZF;
    assign A_NANF = EAP_HF & ~MAP_ZF;
    assign B_ZF    = EB_ZF  &  MBP_ZF;
    assign B_DNF   = EB_ZF  & ~MBP_ZF;
    assign B_INFF  = EB_HF  &  MBP_ZF;
    assign B_NANF  = EB_HF  & ~MBP_ZF;

    DRegister #(1) AB_NAN_reg  ( .Clk(Clk), .Rst(Rst), .en(1'b1), 
                                 .d( A_NANF | B_NANF | (B_ZF & A_INFF) | (A_ZF & B_INFF) ), 
                                 .q(AB_NAN) );
    DRegister #(1) AB_INF_reg  ( .Clk(Clk), .Rst(Rst), .en(1'b1),
                                 .d( (A_INFF & ~(B_NANF | B_ZF)) | (B_INFF & ~(A_NANF | A_ZF)) ), 
                                 .q(AB_INF) );
    DRegister #(1) AB_ZERO_reg ( .Clk(Clk), .Rst(Rst), .en(1'b1),
                                 .d( (A_ZF & (~B_NANF | B_INFF)) | (B_ZF & (~A_NANF | AP_INFF)) ), 
                                 .q(AB_ZERO) );
    DRegister #(1) AB_DNF_reg  ( .Clk(Clk), .Rst(Rst), .en(1'b1),
                                 .d( A_DNF | B_DNF ), 
                                 .q(AB_DNF) );
                                 
    assign P_ZF   = EAP_ZF_reg.d &  MAP_ZF_reg.d;
    assign P_DNF  = EAP_ZF_reg.d & ~MAP_ZF_reg.d;
    assign P_INFF = EAP_HF_reg.d &  MAP_ZF_reg.d;
    assign P_NANF = EAP_HF_reg.d & ~MAP_ZF_reg.d;

endmodule
