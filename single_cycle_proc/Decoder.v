module decoder
(
    input we, 
    input [31:0] a, 
    output reg wem, we1, we2, we3, 
    output reg [1:0] rdsel
);
    
    always @ (we, a)
    begin
        casex ({we, a})
            33'h1_0000_00xx: begin wem = 1; we1 = 0; we2 = 0; we3 = 0; end //memory
            33'h1_0000_080x: begin wem = 0; we1 = 1; we2 = 0; we3 = 0; end //factorial
            33'h1_0000_090x: begin wem = 0; we1 = 0; we2 = 1; we3 = 0; end //gpio
            33'h1_0000_0A0x: begin wem = 0; we1 = 0; we2 = 0; we3 = 1; end //FPMul    
            default: begin wem = 0; we1 = 0; we2 = 0; we3 = 0; end
        endcase
        
        casex (a)
            32'h0000_000x: begin rdsel = 1; end //memory
            32'h0000_080x: begin rdsel = 2; end //factorial
            32'h0000_090x: begin rdsel = 3; end //gpio
            33'h0000_0A0x: begin rdsel = 0; end //FPMul    
            default: begin rdsel = 0; end
        endcase
    end

endmodule
