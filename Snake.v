`timescale 1ns / 1ps



module Snake(
             input clk,
             input clk2,
             input rst,
             input VS,
             input [7:0]keyboard, // De aici e nou , sterge fire
             input valid,
             input [9:0]ran,
             input InDisplay,
             input [9:0]Coloana,
             input [9:0]Linie,
             output reg [3:0]red,
             output reg [3:0] green,
             output reg [3:0] blue,
             output reg game_over,
             output reg [13:0]score);
             
             localparam up=2'b00;
             localparam right = 2'b01;
             localparam down=2'b10;
             localparam left=2'b11;
             localparam HS_min = 144 ; // primul pixel de pe coloana
             localparam HS_max = 783 ; // ultimul pixel de pe coloana
             localparam VS_min = 32; // Prima linie cu output
             localparam VS_max = 511; // ultima linie cu output
             localparam max_lenght=255;
            
            // grid 32x32 cu 11x11pixel fiecare 


          
          reg start=0;
          reg [1:0] direction ;
          reg [7:0] lenght = 4 ;
          reg [9:0] pozitii_sarpe [0:255] ;
          reg [2:0] count_miscare ;
          
          reg snake_on;
          reg press;
          reg [9:0] apple_zone=10'b1010101010 ;
          reg [1:0] last_move=0;
          reg wall_death=0;
          reg self_death=0;
          reg [9:0] back_center_l ;
          reg [9:0] back_center_c ;
          reg [9:0] front_center_c;
          reg [9:0] front_center_l;
          reg [9:0] last_white_spot;
          reg eaten=0;
          reg [6:0]death_timer=0;
         
          
          
          wire [5:0]x_cell;
          wire [5:0]y_cell;
          wire border ;
          wire food;
          wire valid_key;
          wire death;
          wire [9:0]head ;
          wire back_end ;
          wire back;
          wire front;
          wire front_end;
          wire [9:0] apple_center_c;
          wire [9:0] apple_center_l;
          wire apple_red ;
          wire apple_tail; 
          
          integer i ;
          

                          
          assign border = (Coloana>HS_min+144)&&(Coloana<HS_max-144)&&(Linie>VS_min+64)&&(Linie<VS_max-64)  ;
          assign x_cell = (Coloana-HS_min-144)/11;
          assign y_cell = (Linie-VS_min-64)/11;
          assign food =((x_cell==apple_zone[9:5])&&(y_cell==apple_zone[4:0])&&(border)) ? 1'b1 : 1'b0 ;
          assign back = ((x_cell==pozitii_sarpe[lenght][9:5])&&(y_cell==pozitii_sarpe[lenght][4:0])) ? 1'b1 : 1'b0;
          assign back_end = (((back_center_c-Coloana)**2)+((Linie-back_center_l)**2)<=25) ;
          assign front_end = (((front_center_c-Coloana)**2)+((Linie-front_center_l)**2)<=25) ;
          assign front= ((x_cell==pozitii_sarpe[0][9:5])&&(y_cell==pozitii_sarpe[0][4:0])) ? 1'b1 : 1'b0;
          assign apple_center_c=HS_min+144+(11*apple_zone[9:5])+5 ;
          assign apple_center_l=VS_min+64+(11*apple_zone[4:0])+7 ;
          assign apple_red=(((apple_center_c-Coloana)**2)+((Linie-apple_center_l)**2)<=9) ;
          assign apple_tail = ((Coloana==HS_min+144+(11*apple_zone[9:5])+5)&&(Linie<=VS_min+64+(11*apple_zone[4:0])+5)&&(apple_zone)) ;
          
          always@(*) begin
            snake_on=0;
            for(i=0;i<=max_lenght;i=i+1) begin
                if(i<=lenght)
                if((x_cell==pozitii_sarpe[i][9:5])&&(y_cell==pozitii_sarpe[i][4:0])&&(border))
                    snake_on=1;  
                 end  
                 end  
                     
          always@(posedge clk2) begin
          if(pozitii_sarpe[lenght-1][4:0] == pozitii_sarpe[lenght][4:0] -1) begin
                   back_center_c<=HS_min+149+(pozitii_sarpe[lenght][9:5]*11) ;
                   back_center_l<=VS_min+64+(pozitii_sarpe[lenght][4:0]*11);
                   end
          else if(pozitii_sarpe[lenght-1][4:0] == pozitii_sarpe[lenght][4:0] +1) begin         
                   back_center_c<=HS_min+149+(pozitii_sarpe[lenght][9:5]*11) ;
                   back_center_l<=VS_min+74+(pozitii_sarpe[lenght][4:0]*11);
                   end                   
          else if(pozitii_sarpe[lenght-1][9:5] == pozitii_sarpe[lenght][9:5] -1) begin   
                   back_center_c<=HS_min+144+(pozitii_sarpe[lenght][9:5]*11) ;
                   back_center_l<=VS_min+69+(pozitii_sarpe[lenght][4:0]*11);
                   end                
          else if(pozitii_sarpe[lenght-1][9:5] == pozitii_sarpe[lenght][9:5] +1) begin   
                   back_center_c<=HS_min+154+(pozitii_sarpe[lenght][9:5]*11) ;
                   back_center_l<=VS_min+69+(pozitii_sarpe[lenght][4:0]*11);
                   end
           end
  
          always@(negedge VS) begin
          if(last_move==down) begin
                   front_center_c<=HS_min+149+(pozitii_sarpe[0][9:5]*11) ;
                   front_center_l<=VS_min+64+(pozitii_sarpe[0][4:0]*11);
                   end
          else if(last_move==up) begin         
                   front_center_c<=HS_min+149+(pozitii_sarpe[0][9:5]*11) ;
                   front_center_l<=VS_min+74+(pozitii_sarpe[0][4:0]*11);
                   end                   
          else if(last_move==right) begin   
                   front_center_c<=HS_min+144+(pozitii_sarpe[0][9:5]*11) ;
                   front_center_l<=VS_min+69+(pozitii_sarpe[0][4:0]*11);
                   end                
          else if(last_move==left) begin   
                   front_center_c<=HS_min+154+(pozitii_sarpe[0][9:5]*11) ;
                   front_center_l<=VS_min+69+(pozitii_sarpe[0][4:0]*11);
                   end
           end 
           
                           
          always@(posedge clk2) // Afisare 
            if(border)begin
            if(snake_on)  begin
               if(back) begin
                    if(back_end) begin
                        red<=4'b0000;
                        green<=4'b1111;
                        blue<=4'b0000;
                    end
                    else begin
                        red<=4'b1111;
                        green<=4'b1111;
                        blue<=4'b1111;
                        end
              end
              else 
                    if((front)&&(death==0)) begin
                        if(front_end) begin
                            red<=4'b0000;
                            green<=4'b1111;
                            blue<=4'b0000;
                        end
                        else begin
                        red<=4'b1111;
                        green<=4'b1111;
                        blue<=4'b1111;
                        end
                   end
                                                    
                else begin
                red<=4'b0000;
                green<=4'b1111;
                blue<=4'b0000;
            end 
            end 
            else 
             if(food) begin
                 if(apple_tail) begin // codita mar
                    red<=4'b0111;
                    green<=4'b0100;
                    blue<=4'b0000; 
                    end                
                    else if(apple_red)begin // marul 
                        red<=4'b1111;
                        green<=4'b0000;
                        blue<=4'b0000;
                        end
                    else begin 
                        red<=4'b1111; // partea alba din jur
                        green<=4'b1111;
                        blue<=4'b1111;
                        end
                        end   
            else begin // background
                red<=4'b1111;
                green<=4'b1111;
                blue<=4'b1111;
                last_white_spot[9:5]<=x_cell;
                last_white_spot[4:0]<=y_cell;
            end
            end
         else begin // border+outside of display
                red<=4'b0000; 
                green<=4'b0000;
                blue<=4'b0000;
         end      
                
                               
                          
                          
         
         always@(posedge clk2)
         if(rst) begin
         start<=0;
         direction<=up;
         end
         else begin
         if(valid) begin
         case(keyboard)
         8'b00011101:begin start <= 1 ;
                           if(last_move!=down) 
                                direction<=up;

                            end 
        8'b00011011:begin start <= 1 ;
                           if(last_move!=up) 
                                direction<=down;

                            end
        8'b00100011:begin start <= 1 ;
                           if(last_move!=left) 
                                direction<=right;

                            end
        8'b00011100:begin start <= 1 ;
                           if(last_move!=right) 
                                direction<=left;
                            end
           default: direction <= direction  ;
                         
        endcase 
        end
        end
                                                     
                                                       
                                                     
                           
  

         
         always@(negedge VS)
         if(rst)
         count_miscare<=0;
         else begin
         if(death==0)begin // Asta e delay pentru miscarea sarpelui , eu o sa doresc sa stea 8 frame pentru fiecare miscare , asta inseamna ca poate sa faca toata harta in 32*8 = 240 frame adica 4 secunde
         if((start)&&(death==0))
         count_miscare<=count_miscare+1;
         end
         end
         

           
         always@(negedge VS) // Miscare sarpe
         if(rst) begin
         wall_death<=0;
         last_move<=up;
         $readmemb("Initial_sarpe.mem",pozitii_sarpe);
         end
         else begin 
         if(death==0) begin
         if(count_miscare==3'b111) begin 
                for(i = 1 ; i <= max_lenght ; i = i+ 1 ) begin
                    if(i<=lenght+1)
                        pozitii_sarpe[i] <= pozitii_sarpe[i-1] ;
                    end   
            case(direction)
            up:begin if(pozitii_sarpe[0][4:0] ==0) 
                        wall_death<=1; 
                     else begin
                        pozitii_sarpe[0][4:0]<= pozitii_sarpe[0][4:0] - 1;
                        last_move<=up;
                        end
                     end
            right:begin if(pozitii_sarpe[0][9:5]==31) 
                            wall_death<=1; 
                        else begin
                            last_move<= right;
                            pozitii_sarpe[0][9:5]<= pozitii_sarpe[0][9:5] +1;
                            end
                        end
            down:begin if(pozitii_sarpe[0][4:0] ==31) 
                            wall_death<=1; 
                       else begin
                            last_move<=down;
                            pozitii_sarpe[0][4:0]<= pozitii_sarpe[0][4:0] + 1; 
                            end
                       end
            left:begin if(pozitii_sarpe[0][9:5]==0) 
                     wall_death<=1; 
                     else begin
                     pozitii_sarpe[0][9:5]<= pozitii_sarpe[0][9:5] -1;
                     last_move<=left;
                     end
                     end
            endcase
            end 
            end
            end
            

        
        always@(negedge VS)
        if(rst) begin
        score<=0;
        apple_zone<=10'b1010101010;
        eaten<=0;
        lenght<=4;
        end
        else begin
        if(death==0) begin
        if((pozitii_sarpe[0]==apple_zone)&&(eaten==0)) begin
            lenght<=lenght+1;
            apple_zone<=ran;
            eaten<=1;
            score<=score+1;
            for(i = 0 ; i <= max_lenght ; i = i+ 1 ) begin
                if(i<=lenght+1)
                if(ran==pozitii_sarpe[i])
                    apple_zone<=last_white_spot;
            end
            end
        else
            eaten=0;    
            end
            end
            
       always@(negedge VS)  
       if(rst) begin
       self_death<=0;
       end
       else begin  
         for(i=1;i<=max_lenght;i=i+1) begin
                if(i<=lenght)
                    if(pozitii_sarpe[0]==pozitii_sarpe[i])
                        self_death<=1;
                        end
                        end
                        
        always@(negedge VS) 
        if(rst) begin
            death_timer<=0;
            game_over<=0;
        end
        else if(death) begin
        if(death_timer==120) begin
            game_over<=1;
        end
        else begin
        death_timer<=death_timer+1;
        game_over<=0;
        end
        end
                        
   
       assign death=wall_death||self_death ;    
                
            
            
        
                              
                 
endmodule
