module CU
(input Clk, Rst, go, greater, output reg cld, cen, s1, ren, ben, done);

    reg [2:0] NS, CS;
    reg [5:0] ctrl;
    
    parameter
    Idle         = 3'b000,
    Load         = 3'b001,
    Wait         = 3'b010,
    Dec          = 3'b011,
    Done         = 3'b100,
    Idle_Control = 6'b00_0_0_00,
    Load_Control = 6'b11_0_1_00,
    Wait_Control = 6'b00_0_0_00,
    Dec_Control  = 6'b01_1_1_00,
    Done_Control = 6'b00_0_0_11;
    
    always @ (CS, go, greater)
        begin
        case (CS)
            Idle: NS = go ? Load : Idle;
            Load: NS = Wait;
            Wait: NS = greater ? Dec : Done;
            Dec:  NS = Wait;
            Done: NS = Idle;         
        endcase
        end
        
    always @ (posedge Clk, posedge Rst)
        CS = Rst ? Idle : NS;
        
    always @ (ctrl)
        {cld, cen, s1, ren, ben, done} = ctrl;
        
    always @ (CS)
        begin
        case (CS)
            Idle: ctrl = Idle_Control;
            Load: ctrl = Load_Control;
            Wait: ctrl = Wait_Control;
            Dec:  ctrl = Dec_Control;
            Done: ctrl = Done_Control;
        endcase
        end

endmodule
