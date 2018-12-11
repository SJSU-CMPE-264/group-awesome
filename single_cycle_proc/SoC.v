`timescale 1ns / 1ps

module SoC
(
    input wire [31:0] addr_dm, wd_dm,
    input wire we, Rst, Clk,
    output wire [31:0] rd_dm,
    // output wire faccel_done, FPM_done
    output wire [3:0] ex_int
);
    wire faccel_done, FPM_done;
    assign ex_int = {faccel_done, FPM_done, 1'b0, 1'b0};

    wire wem, we1, we2, we3, fact_done_in, fp_done_in;
    wire [1:0] out_mux_sel;
    wire [7:0] gpi1;
    wire [31:0] memdata, factdata, gpiodata, FPMdata, gpo1, gpo2;

    reg [27:0] fact_addr = 28'h0000_080;
    reg [27:0] FP_addr = 28'h0000_0A0;

    decoder dec         (we, addr_dm, wem, we1, we2, we3, out_mux_sel);
    dmem    dmem        (Clk, wem, addr_dm, wd_dm, memdata);
    faccel  fact        (Clk, Rst, we1, addr_dm[3:2], wd_dm, fact_done_in, factdata);
    gpio    gpio        (wd_dm, gpi1, 32'h0, addr_dm[3:2], we2, Clk, gpiodata, gpo1, gpo2); //gpo1 and 2 not connected
    FPWrapper FPWrapper (.Clk(Clk), .Rst(Rst), .A(addr_dm[3:2]), .WE(we3), .InData(wd_dm), .done_sig(fp_done_in), .OutData(FPMdata));
    register #(1) faccel_reg ( .Clk(fact_done_in), .Rst((addr_dm[31:4] == fact_addr) | Rst), .en(1'b1), .in(1'b1), .out(faccel_done) );
    register #(1) FP_reg ( .Clk(fp_done_in), .Rst((addr_dm[31:4] == FP_addr) | Rst), .en(1'b1), .in(1'b1), .out(FPM_done) );
    mux4 #(32) mux      (FPMdata, memdata, factdata, gpiodata, out_mux_sel, rd_dm);


endmodule