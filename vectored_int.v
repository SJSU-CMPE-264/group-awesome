`timescale 1ns / 1ps

// File contains module for the vectored interrupt "controller" and its support modules

module vectored_int
(
    input wire int_ack, done1, done2, done3, done4,
    output wire [31:0] int_addr
);

    wire ctrl1, ctrl2, ctrl3, ctrl4;
    wire [1:0] addr_bits;

    tri_state_buffer buff1 ( .ctrl(ctrl1), .in(2'b00), .out(addr_bits) );
    tri_state_buffer buff2 ( .ctrl(ctrl2), .in(2'b01), .out(addr_bits) );
    tri_state_buffer buff3 ( .ctrl(ctrl3), .in(2'b10), .out(addr_bits) );
    tri_state_buffer buff4 ( .ctrl(ctrl4), .in(2'b11), .out(addr_bits) );

    controller_logic controller ( 
                                  .in({done4, done3, done2, done1}), 
                                  .ctrl_edge(int_ack), 
                                  .out({ctrl4, ctrl3, ctrl2, ctrl1}) 
                                );

    assign int_addr = { {(30){1'b1}}, addr_bits };
endmodule

// parameterized tri-state buffer module
module tri_state_buffer #(parameter WIDTH=2)
(
    input wire  ctrl,
    input wire  [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    assign out = ctrl ? in : {(WIDTH){1'bZ}};
endmodule

module controller_logic
(
    input wire [3:0] in,
    input wire ctrl_edge,
    output reg [3:0] out
);
    // initial
    // begin
    //   out = 4'b0000;
    // end

    always @(posedge ctrl_edge)
    begin
        casex (in)
            4'b1xxx : begin out = 4'b1000; end
            4'b01xx : begin out = 4'b0100; end
            4'b001x : begin out = 4'b0010; end
            4'b0001 : begin out = 4'b0001; end
            default : begin out = 4'b0000; end
        endcase
    end

    always @(negedge ctrl_edge)
    begin
      out = 4'b0000;
    end
endmodule