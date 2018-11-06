//~ `New testbench
`timescale  1ns / 1ps

module tb_vectored_int;

// vectored_int Parameters
parameter PERIOD  = 10;


// vectored_int Inputs
reg   int_ack                              = 0 ;
reg   done1                                = 0 ;
reg   done2                                = 0 ;
reg   done3                                = 0 ;
reg   done4                                = 0 ;

// vectored_int Outputs
wire  [31:0]  int_addr                     ;

reg [31:0] no_active_buffer = { {(30){1'b1}}, 2'bZZ };
reg [31:0] active_buffer1   = { {(30){1'b1}}, 2'b00 };
reg [31:0] active_buffer2   = { {(30){1'b1}}, 2'b01 };
reg [31:0] active_buffer3   = { {(30){1'b1}}, 2'b10 };
reg [31:0] active_buffer4   = { {(30){1'b1}}, 2'b11 };

reg tb_clk;

task runclk;
begin 
    tb_clk = 0; 
    #5; 
    tb_clk = 1; 
    #5; 
end 
endtask

task reset;
begin
    int_ack = 0;
    done1 = 0;
    done2 = 0;
    done3 = 0;
    done4 = 0;
end
endtask

vectored_int  u_vectored_int (
    .int_ack                 ( int_ack          ),
    .done1                   ( done1            ),
    .done2                   ( done2            ),
    .done3                   ( done3            ),
    .done4                   ( done4            ),

    .int_addr                ( int_addr  [31:0] )
);

initial
begin
    runclk;
    if (int_addr != no_active_buffer)
    begin
        $display("No active buffer ERROR: ", int_addr);
    end
    runclk; runclk;
    done1 = 1;
    runclk;
    int_ack = 1;
    runclk;
    if (int_addr != active_buffer1)
    begin
        $display("Buffer 1 active ERROR: ", int_addr);
    end

    reset;

    runclk; runclk;
    done2 = 1;
    runclk;
    int_ack = 1;
    runclk;
    done1 = 1;
    runclk;
    if (int_addr != active_buffer2)
    begin
        $display("Buffer 2 active ERROR: ", int_addr);
    end

    reset;
    runclk;runclk;

    done3 = 1;
    runclk;
    done2 = 1;
    runclk;
    int_ack = 1;
    runclk;
    if (int_addr != active_buffer3)
    begin
        $display("Buffer 3 active ERROR: ", int_addr);
    end
    runclk;runclk;
    reset;
    runclk;runclk;

    done4 <= 1;
    done1 <= 1;
    runclk;
    int_ack = 1;
    runclk;runclk;
    if (int_addr != active_buffer4)
    begin
        $display("Buffer 4 active ERROR: ", int_addr);
    end

    reset;
    runclk;runclk;runclk;

    $display("Test Finished.");
    $finish;
end

endmodule