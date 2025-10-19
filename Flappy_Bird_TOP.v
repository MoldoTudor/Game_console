`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 01:26:46 AM
// Design Name: 
// Module Name: TOP
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


module Flappi_Bird_TOP(
    input clk,
    input clk2,
    input rst,
    input VS,
    input [9:0] Coloana,
    input [9:0] Linie,
    input InDisplay,
    input [7:0] keyboard,
    input valid,
    input [7:0] ran,
    output reg [3:0] green, // RBG
    output reg [3:0] red,
    output reg [3:0] blue,
    output reg game_over,
    output reg [13:0]score);
    
    
    localparam HS_min = 144 ; // primul pixel de pe coloana
    localparam HS_max = 783 ; // ultimul pixel de pe coloana
    localparam VS_min = 32; // Prima linie cu output
    localparam VS_max = 511; // ultima linie cu output
    localparam cloud1_l = 132; // Creez un nor cu 3 cercuri care se suprapun 
    localparam cloud1_2 = 122;
    localparam cloud1_3 = 132;
    localparam cloudc_l = 464;
    localparam cloudc_2 = 494;
    localparam cloudc_3 = 524;
    
    

    reg [9:0] stalp_front = HS_max; // ultima coloana a stalpului
    reg [9:0] stalp_back = HS_max+80; // prima coloana a stalpului
    reg [6:0] counter_death ;
    reg [9:0] Free_Space=100 ;
    reg Hole ;
    reg Press=0; // Verifica daca tastatura a fost apasata
    reg [4:0] Fly_timer ; // Cate frameuri mai zboara pasarea dupa space
    reg [9:0] Bird_l=300; // punct start linie pasare
    reg [9:0] Bird_c=310; // punct start coloana pasare

    reg death;
    reg start=0;

        
  always@(posedge clk2) begin //
    if(InDisplay)begin //
            if((Coloana<=stalp_back)&&(Coloana>=stalp_front)&&(Hole==0)) begin //E stalp ?
                red<=4'b0000;
                green<=4'b0000;
                blue<=4'b0000;
            end //
            else 
                if((((Bird_c-Coloana)**2)+((Linie-Bird_l)**2)<=400)||((Coloana<=(Bird_c+30))&&Coloana>=(Bird_c)&&(Linie<=(Bird_l+7))&&(Linie>=(Bird_l-3)))) begin // output pt pasare , care e impartit in cioc si corp
                    if(((Bird_c-Coloana)**2)+((Linie-Bird_l)**2)<=400) begin // Corpul pasarii
                        if(((Bird_c+10-Coloana)**2)+((Linie-Bird_l+10)**2)<=9) begin
                            if(death==0) begin //Irisul pasarii
                                red<=4'b0000;
                                green<=4'b0000;
                                blue<=4'b0000;
                            end
                            else begin
                                red<=4'b1111;
                                green<=4'b0000;
                                blue<=4'b0000;
                                end
                        end //
                        else 
                           if((Coloana>Bird_c)&&(Linie<Bird_l)) begin //Ochiul ( partea alba ) a pasarii
                                red<=4'b1111;
                                green<=4'b1111;
                                blue<=4'b1111;
                            end //
                            else begin // Restul corpului a pasarii
                                red<=4'b1111;
                                green<=4'b1111;
                                blue<=4'b0000;
                            end //
                            end
                    else begin //Ciocul pasarii
                        red<=4'b1111;
                        green<=4'b1010;
                        blue<=4'b0000;
                        end    // 
                end
                else 
                    if((((cloudc_l-Coloana)**2)+((Linie-cloud1_l)**2)<=900)||(((cloudc_2-Coloana)**2)+((Linie-cloud1_2)**2)<=900)||(((cloudc_3-Coloana)**2)+((Linie-cloud1_3)**2)<=900)) begin //Norii 
                        red<=4'b1110;
                        green<=4'b1110;
                        blue<=4'b1101;
                        end //
                    else  
                        if((Coloana>HS_max-100)&&(Linie<VS_min+100)&&(((HS_max-Coloana)**2)+((Linie-VS_min)**2)<=10000)) begin  // Forma soarelui este circulara dar trebuie sa fie in ecran !
                            red<=4'b1111;
                            green<=4'b1111;
                            blue<=4'b0000;
                            end  //
                        else                      
                            if(Linie>240)begin //Iarba
                                red<=4'b0001;
                                green<=4'b0101;
                                blue<=4'b0010;
                            end  //
                        else begin //Cer
                            red<=4'b0100;
                            green<=4'b1101;
                            blue<=4'b1110;
                        end      //   
      end //
      else begin // Output negru pt ce nu e vizibil
            red<=4'b0000;
            green<=4'b0000;
            blue<=4'b0000;
            end //
            end //
            
            
       always@(posedge clk2)begin // verificare daca s a apasat
       if(rst)begin
       start<=0;
       Press<=0;
       end
       else 
       if(Linie==5) begin
           Press<=0;
           end    
       else if(valid) begin 
            if((keyboard==8'b00101001))begin
            start<=1;
            Press<=1;
            end
            end
   
      
       
       end        
            
    always@(posedge clk2)
    if(rst)
    death<=0;
    else
    if((Bird_l<=(VS_min+20))||(Bird_l>=(VS_max-20))||(((InDisplay)&&(Coloana<=stalp_back)&&(Coloana>=stalp_front)&&(Hole==0))&&((((Bird_c-Coloana)**2)+((Linie-Bird_l)**2)<=400)||((Coloana<=(Bird_c+30))&&Coloana>=(Bird_c)&&(Linie<=(Bird_l+7))&&(Linie>=(Bird_l-3))))))
    death<=1;
            
      
      
    always@(negedge VS) // verificare daca pasarea urca sau coboara
    if(rst) begin
    Fly_timer<=0;
    Bird_l<=300;
    end
    else begin
    if((death==0)&&(start)) begin   
    if(Press==1) begin
        Bird_l=Bird_l-5;
        Fly_timer<=15;        
        end
    else
       if(Fly_timer>0) begin
            Bird_l<=Bird_l-5;
            Fly_timer<=Fly_timer-1;
        end 
        else 
            Bird_l<=Bird_l+4;       
     end  
     end 
     
    always@(negedge VS) begin // miscarea stalpilor
    if(rst) begin
    stalp_front<=HS_max;
    stalp_back<=HS_max+80;
    Free_Space<=100;
    score<=0;
    end
    else
    if((death==0)&&(start)) begin
    if(stalp_back<HS_min+8) begin
        stalp_front<=HS_max;
        stalp_back<=HS_max+80;
        Free_Space<=ran;
        score<=score+1;
    end
    else begin
        stalp_front<=stalp_front-6;
        stalp_back<=stalp_back-6;
    end
    end
    end
    
    always@(negedge VS) begin
    if(rst) begin
    game_over<=0;
    counter_death<=0;
    end
    else    
    if(counter_death==120)
    game_over<=1;
    else begin
        if(death) 
        counter_death<=counter_death+1;
        else
        game_over<=0;
        end
        end
    
    
   always@(*)
    if((Linie>=(Free_Space+VS_min))&&(Linie<(Free_Space+189+VS_min)))
    Hole=1;
    else
    Hole=0; 

    
     
    
    
  

  
      
             
             
endmodule
