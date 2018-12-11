`timescale 1ns / 1ps
//`default_nettype none

module full_system_vectored_tb;

    reg         clk, reset;
    wire        memwrite;
    wire [31:0] epc;
    
    integer counter = 0;
    integer max = 500;
    
    task tick;
    begin
        clk = 0; 
        #5; 
        clk = 1; 
        #5; 
    end
    endtask

    mips_top DUT(clk, reset,
                 memwrite, epc
                );
                 
   

    initial
    begin
        reset = 0;
        #5;
        reset = 1;
        tick;
        reset = 0;
        #5;

        while ((DUT.imem.a != 7'b0111111) && (counter != max)) 
        begin
          counter = counter + 1;
          tick;
//          $display("Cycle number: ", counter);
        end
        
        if (counter == max) 
        begin
          $display("Counter Maxed out! Currently at instruction ", DUT.imem.a);
        end

        $display("Test finished.");
        $finish;
    end

endmodule