`timescale 1ns / 1ps

// File contains module for the vectored interrupt "controller" and its support modules

module vectored_int
(
    input wire int_ack, done1, done2, done3, done4,
    output wire [31:0] int_addr
);

    wire ctrl1, ctrl2, ctrl3, ctrl4, _ctrl1_, _ctrl2_, _ctrl3_, _ctrl4_;
    wire [1:0] addr_bits;

    tri_state_buffer buff1 ( .ctrl(ctrl1), .in(2'b00), .out(addr_bits) );
    tri_state_buffer buff2 ( .ctrl(ctrl2), .in(2'b01), .out(addr_bits) );
    tri_state_buffer buff3 ( .ctrl(ctrl3), .in(2'b10), .out(addr_bits) );
    tri_state_buffer buff4 ( .ctrl(ctrl4), .in(2'b11), .out(addr_bits) );

    AND and1 ( .in({int_ack, done1, _ctrl2_, _ctrl3_, _ctrl4_}), .out(ctrl1) );
    AND and2 ( .in({int_ack, done2, _ctrl1_, _ctrl3_, _ctrl4_}), .out(ctrl2) );
    AND and3 ( .in({int_ack, done3, _ctrl2_, _ctrl1_, _ctrl4_}), .out(ctrl3) );
    AND and4 ( .in({int_ack, done4, _ctrl2_, _ctrl3_, _ctrl1_}), .out(ctrl4) );

    one_bit_inverter inv1 ( .in(ctrl1), .out(_ctrl1_) );
    one_bit_inverter inv2 ( .in(ctrl2), .out(_ctrl2_) );
    one_bit_inverter inv3 ( .in(ctrl3), .out(_ctrl3_) );
    one_bit_inverter inv4 ( .in(ctrl4), .out(_ctrl4_) );

    assign int_addr = {30'b1, addr_bits};
endmodule

// parameterized tri-state buffer module
module tri_state_buffer #(parameter WIDTH=2)
(
    input wire  ctrl,
    input wire  [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    always @(ctrl, in)
    begin
        out = ctrl ? in : {(WIDTH){1'bz}};
    end // always
endmodule

// Parameterized AND module
module AND #(parameter INPUTS=5)
(
    input wire [INPUTS-1:0] in,
    output wire out
);

    always @(in)
    begin
        out = (in & {(INPUTS){1'b1}}) ? 1'b1 : 1'b0;
        // if (in & {(INPUTS){1'b1}})
        // begin
        //     out = 1'b1;
        // end // if

        // else
        // begin
        //     out = 1'b0;
        // end // else
    end // always
endmodule

// one bit inverter module
module one_bit_inverter
(
    inout wire in,
    output wire out
);

    always @(in)
    begin
        out = ~in;
    end // always
endmodule