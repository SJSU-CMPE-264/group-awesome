`timescale 1ns / 1ps

// Aux Flag Generation for FPMul
module AuxFlagGen(
    input  wire        clk,
    input  wire        rst,
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

    wire AP_ZF;
    wire AP_DNF;
    wire AP_INFF;
    wire AP_NANF;
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

    // round bit
    assign guard  = MBP[23];
    assign lsb    = MBP[0];
    assign sticky = &MBP[22:0];
    assign round  = guard & ( lsb | sticky );

    assign underflow = EAP[9];
    assign overflow  = ( ~EAP[9] & EAP[8] ) | EAP_HF;

    // flag bus
    assign flags = { AP_ZF, AP_DNF, AP_INFF, AP_NANF,    // [11:8]
                     MAP_HF, round, underflow, overflow, // [ 7:4]
                     AB_NAN, AB_INF, AB_ZERO, AB_DNF };  // [ 3:0]

    DRegister #(1) EAP_ZF_reg (.clk(clk), .rst(rst), .en(1'b1), .d(~|EAP[ 7:0]), .q(EAP_ZF));
    DRegister #(1) EAP_HF_reg (.clk(clk), .rst(rst), .en(1'b1), .d( &EAP[ 7:0]), .q(EAP_HF));
    DRegister #(1) MAP_ZF_reg (.clk(clk), .rst(rst), .en(1'b1), .d(~|MAP[22:0]), .q(MAP_ZF));
    DRegister #(1) MAP_HF_reg (.clk(clk), .rst(rst), .en(1'b1), .d( &MAP[22:0]), .q(MAP_HF));
    DRegister #(1) EB_ZF_reg  (.clk(clk), .rst(rst), .en(1'b1), .d( ~|EB[ 7:0]), .q(EB_ZF ));
    DRegister #(1) EB_HF_reg  (.clk(clk), .rst(rst), .en(1'b1), .d(  &EB[ 7:0]), .q(EB_HF ));
    DRegister #(1) MB_ZF_reg  (.clk(clk), .rst(rst), .en(1'b1), .d(~|MBP[22:0]), .q(MBP_ZF));
    DRegister #(1) MB_HF_reg  (.clk(clk), .rst(rst), .en(1'b1), .d( &MBP[22:0]), .q(MBP_HF));

    assign AP_ZF   = EAP_ZF &  MAP_ZF;
    assign AP_DNF  = EAP_ZF & ~MAP_ZF;
    assign AP_INFF = EAP_HF &  MAP_ZF;
    assign AP_NANF = EAP_HF & ~MAP_ZF;
    assign B_ZF    = EB_ZF  &  MBP_ZF;
    assign B_DNF   = EB_ZF  & ~MBP_ZF;
    assign B_INFF  = EB_HF  &  MBP_ZF;
    assign B_NANF  = EB_HF  & ~MBP_ZF;

    DRegister #(1) AB_NAN_reg  ( .clk(clk), .rst(rst), .en(1'b1), 
                                 .d( AP_NANF | B_NANF | (B_ZF & AP_INFF) | (AP_ZF & B_INFF) ), 
                                 .q(AB_NAN) );
    DRegister #(1) AB_INF_reg  ( .clk(clk), .rst(rst), .en(1'b1),
                                 .d( (AP_INFF & ~(B_NANF | B_ZF)) | (B_INFF & ~(AP_NANF | AP_ZF)) ), 
                                 .q(AB_INF) );
    DRegister #(1) AB_ZERO_reg ( .clk(clk), .rst(rst), .en(1'b1),
                                 .d( (AP_ZF & ~(B_NANF | B_INFF)) | (B_ZF & ~(AP_NANF | AP_INFF)) ), 
                                 .q(AB_ZERO) );
    DRegister #(1) AB_DNF_reg  ( .clk(clk), .rst(rst), .en(1'b1),
                                 .d( AP_DNF | B_DNF ), 
                                 .q(AB_DNF) );
endmodule
