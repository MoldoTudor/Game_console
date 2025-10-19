`timescale 1ns / 1ps



module Afisor(
    input clk,
    input rst,
    input [13:0] val,
    output reg [6:0]out,
    output reg [7:0]anod_select);
    
    reg [25:0] num ;
    reg [15:0] clk_sec;
    reg [1:0]select;
    
    always@(posedge clk)
            if(clk_sec==16'b1111111111111111) begin
                select<=select+1;
                clk_sec<=0;
                end
            else begin
                clk_sec<=clk_sec+1;
            end
            
    
            
            
       
       always@(select)
       if(select==0) begin  
       anod_select=8'b11111110 ;    
        case(val%10)
            4'd0: out = 7'b1000000;    
            4'd1: out = 7'b1111001;    
            4'd2: out = 7'b0100100;      
            4'd3: out = 7'b0110000;     
            4'd4: out = 7'b0011001;        
            4'd5: out = 7'b0010010;       
            4'd6: out = 7'b0000010;      
            4'd7: out = 7'b1111000;        
            4'd8: out = 7'b0000000;      
            4'd9: out =7'b0010000;        
            default: out = 7'b0000110;
            endcase
            end
      else if(select==1)begin
            anod_select=8'b11111101;
            case((val/10)%10)
            4'd0:out <= 7'b1000000;     
            4'd1:out <= 7'b1111001;     
            4'd2:out <= 7'b0100100;     
            4'd3:out <= 7'b0110000;      
            4'd4:out <= 7'b0011001;    
            4'd5:out <= 7'b0010010; 
            4'd6: out = 7'b0000010;      
            4'd7: out = 7'b1111000;        
            4'd8: out = 7'b0000000;      
            4'd9: out =7'b0010000;                       
            default: out <= 7'b0000110;
            endcase
            end
        else  if(select==2) begin  
       anod_select=8'b11111011 ;    
        case((val/100)%10)
            4'd0: out = 7'b1000000;    
            4'd1: out = 7'b1111001;    
            4'd2: out = 7'b0100100;      
            4'd3: out = 7'b0110000;     
            4'd4: out = 7'b0011001;        
            4'd5: out = 7'b0010010;       
            4'd6: out = 7'b0000010;      
            4'd7: out = 7'b1111000;        
            4'd8: out = 7'b0000000;      
            4'd9: out =7'b0010000;        
            default: out = 7'b0000110;
            endcase
            end
      else if(select==3)begin
            anod_select=8'b11110111;
            case((val/1000)%10)
            4'd0:out <= 7'b1000000;     
            4'd1:out <= 7'b1111001;     
            4'd2:out <= 7'b0100100;     
            4'd3:out <= 7'b0110000;      
            4'd4:out <= 7'b0011001;    
            4'd5:out <= 7'b0010010;
            4'd6: out = 7'b0000010;      
            4'd7: out = 7'b1111000;        
            4'd8: out = 7'b0000000;      
            4'd9: out =7'b0010000;                        
            default: out <= 7'b0000110;
            endcase
            end      

 

        
     
       
            
endmodule

