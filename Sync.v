`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 12:41:59 AM
// Design Name: 
// Module Name: Sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


    module Sync(
    input clk,
    output reg clk2 ,
    output reg HS,
    output reg VS,
    output reg [9:0] Coloana,
    output reg [9:0] Linie,
    output reg InDisplay);
  
    reg  mem ;
    
    initial begin
    Coloana=0;
    Linie=0;
    VS=1;
    HS=1;
    clk2=0;
    InDisplay=0;
    mem=0;
    end
    
    
  

    always@(posedge clk)
        if(mem==1) begin
            clk2<=~clk2;
            mem<=mem+1;
        end
    else
        mem<=mem+1;

        
       
        
       always@(posedge clk2)    
       if((Linie==520)&&(Coloana ==799)) begin
           VS<=0;
           HS<=0;
           Coloana<=0;
           Linie<=0;
                end  
      else if(Coloana==799)begin
            HS<=0;
            Coloana<=0;
            Linie<=Linie+1;
       end
       else begin
          if(Coloana==95)begin
                HS<=1;
                Coloana<=Coloana+1;
             end  
             else if(Linie==2) begin
                VS<=1;   
                Coloana<=Coloana+1;
                end
             else
                Coloana<=Coloana+1;                 
           end
       
    always@(*)
    if((Coloana>143)&&(Coloana<784)&&(Linie>30)&&(Linie<511))
    InDisplay=1;
    else
    InDisplay=0;
  
    
endmodule
