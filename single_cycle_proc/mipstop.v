`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// CMPE 140, CMPE Department, san Jose State University
// Authors: Donald Hung and Hoan Nguyen
//
// Create Date:    08:36:48 02/25/2010
// Design Name:
// Module Name:    mips_top
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
// MIPS Top-level Module (including the memories, clock,
// and the display module for prototyping)
module mips_top(
    input    Clk, reset,// pb,
    output    memwrite,// wem, we1, we2, we3,
    //output    [ 7:0]     LEDSEL,
    //output     [ 7:0]    LEDOUT,
    //input    [ 7:0]    switches,
    input   [7:0] gpi1
    //output    sinkBit
    
    );

    wire    [31:0]     pc, instr, dataadr, writedata, readdata;// dispDat;
    //wire    clksec, clk_db, 
    wire    faccel_done, FPM_done;
    //reg     [ 15:0]    reg_hex;
    
    // wire Clk_5KHz;

    // Clock (1 second) to slow down the running of the instructions
    //Clk_gen top_Clk(.Clk50MHz(Clk), .reset(reset), .Clksec(Clksec));

    // Clk_gen top_Clk(
    //     .Clk100MHz(Clk),
    //     .Rst(reset),
    //     .Clk_sec(Clksec),
    //     .Clk_5KHz(Clk_5KHz)
    //     );
        
    // debounce db (Clk_5KHz, pb, Clk_db);
      
    // Instantiate processor and memories    
    mips     mips       (clk, reset, pc, instr, memwrite, 
                        dataadr, writedata, readdata, 
                        //switches[4:0], dispDat, 
                        faccel_done, FPM_done, 1'b0, 1'b0);
    imem     imem       (pc[8:2], instr);
    //SoC
    SoC     soc ( 
                .addr(dataadr), .write_data(writedata), .gpi1(gpi1),
                .WE(memwrite), .reset(reset), .clk(clk), .data_out(readdata),
                .faccel_done(faccel_done), .FPM_done(FPM_done) 
                );
    
//=======================================================================================================================
//=======================================================================================================================
/*
    wire [7:0] digit0;
    wire [7:0] digit1;
    wire [7:0] digit2;
    wire [7:0] digit3;
    wire [7:0] digit4;
    wire [7:0] digit5;
    wire [7:0] digit6;
    wire [7:0] digit7;
    
    bcd_to_7seg bcd0 (pc[15:12], digit0);
    bcd_to_7seg bcd1 (pc[11:8], digit1);
    bcd_to_7seg bcd2 (pc[7:4], digit2);
    bcd_to_7seg bcd3 (pc[3:0], digit3);
    
    bcd_to_7seg bcd4 (reg_hex[15:12], digit4);
    bcd_to_7seg bcd5 (reg_hex[11:8], digit5);
    bcd_to_7seg bcd6 (reg_hex[7:4], digit6);
    bcd_to_7seg bcd7 (reg_hex[3:0], digit7);
   
    LED_MUX disp_unit (
        Clk_5KHz,
        reset,
        digit0,
        digit1,
        digit2,
        digit3,
        digit4,
        digit5,
        digit6,
        digit7,
        LEDOUT,
        LEDSEL        
        );
    

    7:5 = 000 : Display LSW of register selected by DSW 4:0
    7:5 = 001 : Display MSW of register selected by DSW 4:0
    7:5 = 010 : Display LSW of instr
    7:5 = 011 : Display MSW of instr
    7:5 = 100 : DIsplay LSW of dataaddr
    7:5 = 101 : Display MSW of dataaddr
    7:5 = 110 : Display LSW of writedata
    7:5 = 111 : Display MSW of writedata
*/ 
   
/*    
    always @ (posedge Clk)
    begin
        case ({switches[7],switches[6], switches[5]})
            3'b000:    reg_hex = dispDat[15:0];
            3'b001:    reg_hex = dispDat[31:16];
            3'b010:    reg_hex = instr[15:0];
            3'b011:    reg_hex = instr[31:16];
            3'b100:    reg_hex = dataadr[15:0];
            3'b101:    reg_hex = dataadr[31:16];
            3'b110:    reg_hex = writedata[15:0];
            3'b111:    reg_hex = writedata[31:16];
            endcase
    end        

    //sink unused bit(s) to knock down the number of warning messages
    assign sinkBit = (pc > 0) ^ (instr > 0) ^ (dataadr > 0) ^ (writedata > 0) ^
                     (readdata > 0) ^ (dispDat > 0);
*/
endmodule
