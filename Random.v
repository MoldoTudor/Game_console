`timescale 1ns / 1ps



module Random(
    input clk,
    input rst,
    output reg [7:0]out);
    
    
    wire new_bit;
    
    
    always@(posedge clk)
    if(rst)
    out<=8'b00000001;
    else
    out<={out[6:0] , new_bit};
    
    assign new_bit = out[7]^out[5]^out[4]^out[3] ;

endmodule
