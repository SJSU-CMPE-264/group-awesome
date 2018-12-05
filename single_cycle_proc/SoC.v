`timescale 1ns / 1ps

module SoC
(
    input wire [31:0] addr, write_data,
    input wire [7:0] gpi1,
    input wire WE, reset, clk,
    output wire [31:0] data_out,
    output wire faccel_done, FPM_done
);

    wire wem, we1, we2, we3, fact_done_in, fp_done_in;
    wire [1:0] out_mux_sel;
    wire [31:0] memdata, factdata, gpiodata, FPMdata, gpo1, gpo2;

    reg [27:0] fact_addr = 28'h0000_080;
    reg [27:0] FP_addr = 28'h0000_0A0;

    decoder dec         (WE, addr, wem, we1, we2, we3, out_mux_sel);
    dmem    dmem        (clk, wem, addr, write_data, memdata);
    faccel  fact        (clk, reset, we1, addr[3:2], write_data, fact_done_in, factdata);
    gpio    gpio        (write_data, gpi1, 32'h0, addr[3:2], we2, clk, gpiodata, gpo1, gpo2); //gpo1 and 2 not connected
    FPWrapper FPWrapper (.Clk(clk), .Rst(reset), .A(addr[3:2]), .WE(we3), .InData(write_data), .done_sig(fp_done_in), .OutData(FPMdata));
    register #(1) faccel_reg ( .Clk(fact_done_in), .Rst((addr[31:4] == fact_addr) | reset), .en(1'b1), .in(1'b1), .out(faccel_done) );
    register #(1) FP_reg ( .Clk(fp_done_in), .Rst((addr[31:4] == FP_addr) | reset), .en(1'b1), .in(1'b1), .out(FPM_done) );
    mux4 #(32) mux      (FPMdata, memdata, factdata, gpiodata, out_mux_sel, data_out);


endmodule