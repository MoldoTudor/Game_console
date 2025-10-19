`timescale 1ns / 1ps



module Random_10bits(
    input clk,
    input rst,
    output reg [9:0]out);

    
    wire new_bit;
    
    
    always@(posedge clk)
    if(rst)
    out<=8'b00000001;
    else
    out<={out[8:0] , new_bit};
    
    assign new_bit = out[9]^out[6];

endmodule
