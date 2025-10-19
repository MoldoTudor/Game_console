`timescale 1ns / 1ps



module Selecting_Game(
    input clk,
    input [9:0] Coloana,
    input [9:0] Linie,
    input InDisplay,
    input VS,
    output reg [3:0] red,
    output reg[3:0] green,
    output reg [3:0] blue);
    
    localparam HS_min = 144 ; // primul pixel de pe coloana
    localparam HS_max = 783 ; // ultimul pixel de pe coloana
    localparam VS_min = 32; // Prima linie cu output
    localparam VS_max = 511; // ultima linie cu output
    
    localparam second_pillar = 298 ;
    localparam thirth_pillar =452 ;
    localparam forth_pillar = 606 ;
    localparam fifth_pillar = 760 ;
    localparam Bird_l = 130;
    localparam Bird_c = 215;
    localparam Ship_l = 70;
    localparam Ship_c= 485;
    localparam Doodle_c= 645;
    localparam Doodle_l = 100;
    
    wire pillar_zone ;
    wire flappy_bird_zone;
    wire snake_zone;
    wire flappy;
    wire flappy_iris;
    wire flappy_white;
    wire first_line_snake;
    wire second_line_snake;
    wire thirth_line_snake;
    wire fourth_line_snake;
    wire snake_head;
    wire snake;
    wire apple;
    wire tongue;
    wire doodle_on;
    wire space_on;
    reg [9:0]head_l=VS_min+180;
    reg [9:0]head_c=second_pillar+64;
    reg [9:0] apple_l = VS_min+180;
    reg [9:0] apple_c = thirth_pillar-30;
    wire stem ;
    wire first_part_screen;
    wire second_part_screen;
    wire thirth_part_screen;
    wire flappy_beak;
    wire flappy_body;
    
    reg [9:0] memShip [0:6] ;
    reg [24:0] Doodle_look [0:24] ;

    
    initial begin
    $readmemb("Main_Ship.mem",memShip);
    $readmemb("Doodle.mem",Doodle_look);
    end

    assign first_part_screen = (((Coloana>=HS_min)&&(Coloana<HS_min+24))||((Coloana>=second_pillar)&&(Coloana<second_pillar+24)));
    assign second_part_screen = ((Coloana>=thirth_pillar)&&(Coloana<thirth_pillar+24));
    assign thirth_part_screen =(((Coloana>=forth_pillar)&&(Coloana<forth_pillar+24))||((Coloana>=fifth_pillar)&&(Coloana<=HS_max)));
    assign pillar_zone =((InDisplay)&&(first_part_screen||second_part_screen||thirth_part_screen)) ? 1'b1 : 1'b0;
    assign flappy_bird_zone =((InDisplay)&&(Coloana>=HS_min+24)&&(Coloana<second_pillar))? 1'b1 : 1'b0 ;
    assign snake_zone =((InDisplay)&&(Coloana>=second_pillar+24)&&(Coloana<thirth_pillar))? 1'b1 : 1'b0 ;
    assign space_zone =((InDisplay)&&(Coloana>=thirth_pillar+24)&&(Coloana<forth_pillar))? 1'b1 : 1'b0 ;
    assign doodle_zone =((InDisplay)&&(Coloana>=forth_pillar+24)&&(Coloana<fifth_pillar))? 1'b1 : 1'b0 ;
    assign flappy_beak = ((Coloana<=(Bird_c+70))&&Coloana>=(Bird_c)&&(Linie<=(Bird_l+20))&&(Linie>=(Bird_l)));
    assign flappy = flappy_body||flappy_beak;
    assign flappy_body = (((Bird_c-Coloana)**2)+((Linie-Bird_l)**2)<=1600) ;
    assign flappy_iris = (((Bird_c+20-Coloana)**2)+((Linie-Bird_l+20)**2)<=36) ;
    assign flappy_white = ((Coloana>Bird_c)&&(Linie<Bird_l));
    assign first_line_snake = ((Linie<VS_min+40)&&(snake_zone));
    assign second_line_snake = ((Coloana>thirth_pillar-40)&&(snake_zone)&&(Linie<VS_min+120));
    assign thirth_line_snake = ((snake_zone)&&(Linie<VS_min+120)&&(Linie>VS_min+80));
    assign fourth_line_snake = ((Coloana<second_pillar+64)&&(snake_zone)&&(Linie>VS_min+80)&&(Linie<VS_min+200));
    assign snake_head =(((head_l-Linie)**2)+((head_c-Coloana)**2)<=400);
    assign apple =(((apple_l-Linie)**2)+((apple_c-Coloana)**2)<=400);
    assign snake= first_line_snake || second_line_snake || thirth_line_snake || fourth_line_snake || snake_head ;
    assign ship_on = (Coloana>=Ship_c)&&(Coloana<Ship_c+112)&&(Linie>=Ship_l)&&(Linie<Ship_l+160) ;
    assign doodle_on= (Coloana>=Doodle_c)&&(Coloana<Doodle_c+100)&&(Linie>=Doodle_l)&&(Linie<Doodle_l+100) ;
    assign stem = ((Coloana>apple_c-3)&&(Coloana<apple_c+3)&&(Linie<apple_l-19)&&(Linie>apple_l-50)) ;
  
    always@(posedge clk)
    if(InDisplay) begin
    if(pillar_zone) begin 
        red<=4'b0000;
        green<=4'b0000;
        blue<=4'b0000;
        end
     else
        if(flappy_bird_zone)begin 
            if(flappy)begin  // daca e pasare
            if(flappy_body) begin // corp pasare
                if(flappy_iris) begin // irisul
                        red<=4'b0000;
                        green<=4'b0000;
                        blue<=4'b0000;
                        end
                 else
                    if(flappy_white) begin // albul ochiului
                                red<=4'b1111;
                                green<=4'b1111;
                                blue<=4'b1111;
                                end
                    else begin // rest corp pasare
                                red<=4'b1111;
                                green<=4'b1111;
                                blue<=4'b0000;
                   end
                   end
                 else begin // cioc pasare
                        red<=4'b1111;
                        green<=4'b1010;
                        blue<=4'b0000;
                        end
                        end
                       
                else begin// fundal pt pasare
                    red<=4'b0100;
                    green<=4'b1101;
                    blue<=4'b1110;
                    end
       end
       else   // SNAKE+++++++++
       if(snake_zone) begin
                if(snake) begin
                    red<=4'b0000;
                    green<=4'b1111;
                    blue<=4'b0000;
                    end
             else if(stem) begin 
                    red<=4'b0111;
                    green<=4'b0100;
                    blue<=4'b0000;
                    end                     
             else if(apple) begin 
                    red<=4'b1111;
                    green<=4'b0000;
                    blue<=4'b0000;
                    end                     
             else begin
                   red<=4'b1111;
                   green<=4'b1111;
                   blue<=4'b1111;             
                    end
        end
        else if(space_zone) begin
            if((ship_on)&&(memShip[(Coloana-Ship_c)/16][9-((Linie-Ship_l)/16)]==1)) begin
            red<=4'b1011;
            blue<=4'b1011;
            green<=4'b1011;
            end
            else begin
            red<=4'b0000;
            blue<=4'b1001;
            green<=4'b0000;
            end
        end
        else if(doodle_zone)begin
            if((doodle_on)&&(Doodle_look[(Linie-Doodle_l)/4][(Coloana-Doodle_c)/4]==1)) begin
                if((((Coloana-Doodle_c)/4==10)&&((Linie-Doodle_l)/4==4))||(Linie-Doodle_l>=80)) begin
                    red<=4'b0000;
                    green<=4'b0000;
                    blue<=4'b0000; 
                end 
                else if((Linie-Doodle_l>=52)&&(Linie-Doodle_l<80)) begin
                    red<=4'b0000;
                    green<=4'b1111;
                    blue<=4'b0000; 
                end 
              else begin  
                    red<=4'b1111;
                    green<=4'b1111;
                    blue<=4'b0000; 
              end
              end
              else if((Coloana%15==0)||(Linie%15==0))begin
                red<=4'b1100;
                green<=4'b1011;
                blue<=4'b1001;                                                
            end
            else begin
                   red<=4'b1111;
                   green<=4'b1111;
                   blue<=4'b1111; 
            end
            end
            else begin
            red<=4'b1111;
            blue<=4'b0000;
            green<=4'b0000; 
        end
        end
        else begin
            red<=4'b0000;
            green<=4'b0000;
            blue<=4'b0000;
       end     
                      
endmodule
