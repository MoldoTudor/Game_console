`timescale 1ns / 1ps



module Doodle(
    input clk,
    input rst,
    input VS,
    input [9:0]Coloana,
    input [9:0]Linie,
    input clk2,
    input InDisplay,
    input [7:0] keyboard,
    input valid,
    output reg [3:0]red,
    output reg [3:0]blue,
    output reg [3:0] green,
    output reg game_over,
    output reg [13:0]score);
    
    localparam HS_min = 144 ; // primul pixel de pe coloana
    localparam HS_max = 783 ; // ultimul pixel de pe coloana
    localparam VS_min = 32; // Prima linie cu output
    localparam VS_max = 511; // ultima linie cu output
    localparam border_min= 304 ;
    localparam border_max = 623 ;
    localparam Doodle_l_start = 250 ;
    localparam Doodle_c_start= 464;
    localparam left = 1'b0;
    localparam right = 1'b1;
    
    reg [8:0] memPaddle_c [0:4] ;
    reg [8:0] memPaddle_l [0:4] ;
    reg [24:0] Doodle_look [0:24] ;
    
          initial begin       
          $readmemb("Doodle.mem",Doodle_look);
          end 
    
    
    

    
    wire falling_vs ;
    wire doodle_zone ;
    wire border ;
    wire doodle_contact ;
    wire death;
    
    reg [2:0] VS_tracker;
    reg direction ;
    reg start=0;
    reg Press=0 ;
    reg paddle_zone ;
    reg [9:0] Doodle_c=Doodle_c_start;
    reg [9:0] Doodle_l=Doodle_l_start;
    reg [4:0] paddle_directions=5'b10101;
    reg state_doodle=0 ;
    reg contact=0 ;
    reg [5:0] timer_jump=0 ;
    reg paddle_contact ;
    reg last_move ;
    reg [6:0] timer_death = 0 ;
    
    integer i ;
     
    

                            
      assign falling_vs = (VS_tracker[2:1] == 2'b10)? 1'b1 : 1'b0 ; 
      assign doodle_zone = (Coloana>=Doodle_c)&&(Coloana<Doodle_c+25)&&(Linie>=Doodle_l)&&(Linie<Doodle_l+25) ;
          assign border = (InDisplay)&&(Coloana>=border_min)&&(Coloana<border_max);
          assign doodle_contact = (Coloana>=Doodle_c)&&(Coloana<Doodle_c+25)&&(Linie==Doodle_l+24) ;
      assign death = (Doodle_l>VS_max)? 1'b1 : 1'b0;
      
      always@(posedge clk2) begin
        paddle_zone<=0;
        for(i=0;i<5;i=i+1)
            if((Coloana>=memPaddle_c[i]+border_min)&&(Coloana<memPaddle_c[i]+40+border_min)&&(Linie>=memPaddle_l[i]-15+VS_min)&&(Linie<memPaddle_l[i]+VS_min))
                paddle_zone<=1;
       end
       
      always@(posedge clk2) begin
        paddle_contact<=0;
        for(i=0;i<5;i=i+1)
            if((Coloana>=memPaddle_c[i]+border_min)&&(Coloana<memPaddle_c[i]+40+border_min)&&(Linie>=memPaddle_l[i]-16+VS_min)&&(Linie<=memPaddle_l[i]-14+VS_min))
                paddle_contact<=1;
       end       
                              
      
      always@(posedge clk2)
      VS_tracker<={VS_tracker[1:0] , VS};  
      
      always@(posedge clk2)
      if(rst) begin
      direction<=left;
      Press<=0;
      start<=0;
      end
      else begin
      if((valid)&&(death==0)) begin
      case(keyboard)
      8'b00011100:begin 
                 direction<=left;
                 Press<=1;
                 start<=1;
                 end
      8'b00100011:begin
                  direction<=right;
                  Press<=1;
                  start<=1;
                  end      
       endcase
       end
       else if(Linie==5) begin
            Press<=0;
            end
      end
      
      always@(posedge clk2)
        if(rst)
        contact<=0;
        else begin
        if((doodle_contact)&&(paddle_contact)&&(death==0))
            contact<=1;
        else if (Linie==5)
            contact<=0;
        end    
                      
      always@(posedge clk2)
      if(border)begin
        if((doodle_zone)&&(Doodle_look[Linie-Doodle_l][Coloana-Doodle_c]==1)&&(last_move==left))begin
            if(((Coloana-Doodle_c==10)&&(Linie-Doodle_l==4))||(Linie-Doodle_l>=20)) begin
            red<=4'b0000;
            green<=4'b0000;
            blue<=4'b0000; 
            end
            else if((Linie-Doodle_l>=13)&&(Linie-Doodle_l<20)) begin
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
         else   
        if((doodle_zone)&&(Doodle_look[Linie-Doodle_l][24-Coloana+Doodle_c]==1)&&(last_move==right))begin
            if(((Coloana-Doodle_c==15)&&(Linie-Doodle_l==4))||(Linie-Doodle_l>=20)) begin
                red<=4'b0000;
                green<=4'b0000;
                blue<=4'b0000; 
            end
            else if((Linie-Doodle_l>=13)&&(Linie-Doodle_l<20)) begin
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
         else if (paddle_zone) begin
            red<=4'b0000;
            green<=4'b0000;
            blue<=4'b1111;
         end   
         else begin
            if((Coloana%15==0)||(Linie%15==0)) begin
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
        end
        else begin          
            red<=4'b0000;
            green<=4'b0000;
            blue<=4'b0000; 
     end           
              
      
      always@(posedge clk2) // Miscare nava
      if(rst)begin
      Doodle_c<=Doodle_c_start;
      last_move<=left;
      end
      else begin
      if((falling_vs)&&(death==0)) begin
      if((Press==1)&&(start))
        if(direction==left) begin
            if(Doodle_c+20>border_min+3) begin
                Doodle_c<=Doodle_c-3;
                last_move<=left ;
            end    
            else
                Doodle_c<=border_max ;
        end    
        else if(direction==right) begin
            if(Doodle_c<border_max-3) begin
                Doodle_c<=Doodle_c+3; 
                last_move<=right ;
            end    
            else
                Doodle_c<=border_min-20 ;
        end 
      end
      end
      
      always@(posedge clk2)
      if(rst)begin
      $readmemb("Paddle.mem",memPaddle_c);  
      paddle_directions<=5'b10101;
      end
      else begin
      if((falling_vs)&&(start)&&(death==0))
        for(i=0;i<5;i=i+1) begin
            if(paddle_directions[i]==1)begin
                if(memPaddle_c[i]>=253)
                    paddle_directions[i]<=0;
                 else
                    memPaddle_c[i]<=memPaddle_c[i]+2;
             end
             else  begin
                 if(memPaddle_c[i]<=2)
                    paddle_directions[i]<=1;
                 else
                    memPaddle_c[i]<=memPaddle_c[i]-2;
             end
       end
       end
       
       always@(posedge clk2)
       if(rst)begin
        Doodle_l<=Doodle_l_start;
        state_doodle<=0;
        timer_jump<=0;
        score<=0;
        $readmemb("Paddle_l.mem",memPaddle_l);
        end
       else begin
       if((falling_vs)&&(start)&&(death==0))
       case(state_doodle)
       1'b0:begin
            if(contact) begin
                state_doodle<=1;
                timer_jump<=40;
            end    
            else
                Doodle_l<=Doodle_l+3 ;
            end    
       1'b1:begin
            if(timer_jump!=0) begin
                if(Doodle_l>=VS_max-250) begin
                    Doodle_l=Doodle_l-4;
                    timer_jump<=timer_jump-1 ;
                end
                else begin
                    timer_jump<=timer_jump-1;
                    for(i=0;i<5;i=i+1)
                        memPaddle_l[i]<=memPaddle_l[i]+4;
                        score<=score+1;
                end    
             end   
             else
                state_doodle<=0;  
            end
        endcase 
        end
        
       always@(posedge clk2)
       if(rst) begin
            timer_death<=0;
            game_over<=0;
       end
       else
       if((start)&&(death==1))begin
            if(falling_vs) begin 
                if(timer_death==120)
                    game_over<=1;
                else
                    timer_death<=timer_death+1;     
         end
         end    
        
        
            
                           
        
                                                
    
    
    
endmodule
