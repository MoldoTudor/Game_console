`timescale 1ns / 1ps



module Space_Invaders(
    input clk,
    input rst,
    input valid,
    input clk2,
    input [7:0] keyboard,
    input InDisplay,
    input [9:0] Coloana,
    input [9:0] Linie,
    input VS ,
    input [9:0] ran ,
    output reg[3:0] red,
    output reg[3:0] blue,
    output reg[3:0] green,
    output reg game_over,
    output reg [13:0] score);
    
    localparam HS_min = 144 ; // primul pixel de pe coloana
    localparam HS_max = 783 ; // ultimul pixel de pe coloana
    localparam VS_min = 32; // Prima linie cu output
    localparam VS_max = 511; // ultima linie cu output
    localparam up = 1'b0;
    localparam down = 1'b1;
    localparam max_bullets = 10;
    localparam enemy_max = 32;
    
    reg [212:0] memSpace [0:159] ; // MEMORII
    reg [9:0] memShip [0:6] ;
    reg [9:0] memBullet_l [0:9] ;
    reg [9:0] memBullet_c [0:9] ;
    reg [9:0] memEnemy_l [0:31] ;
    reg [9:0] memEnemy_c [0:31] ;
    reg [9:0] memEnemy_Ship [0:7] ;
    reg [15:0] Heart [0:11] ;
    reg [31:0] lifes = 0 ;
    reg [6:0] timer_death=0 ;
    wire red_heart ;
    
    

    wire corner ;
    wire center ;
    wire ship_zone;
    wire falling_vs ;
    wire death_lifes ;
    reg death_shipwreck = 0;
    wire death ;

    
    
    
    
    reg [9:0]Main_ship_c = 150 ; // partea din spate a navei
    reg [9:0]Main_ship_l = 200 ; // partea de sus a navei
    reg direction ;
    reg start=0;
    reg Press=0;
    reg [3:0]number_bullets = 0 ;
    reg new_bullet ;
    reg bullet_zone;
    reg [3:0] bullets = 0 ;
    reg [7:0] timer_enemies=0 ;
    reg spawn_enemies ;
    reg [2:0] ship_num ;
    reg [3:0]ship_speed =2 ;
    reg [10:0]speed_timer=0 ;
    
    reg [9:0] number_enemies;
    reg [2:0] VS_tracker=3'b111 ;
    reg [2:0] count ;
    reg [31:0] enemy_valid=0 ;
    reg enemy_zone ;
    reg kill_enemy=0 ; 
    reg [4:0] timer_bullets=0;
    reg counting_lives ;
    reg [2:0] lives_left=5 ;
    reg [5:0] lives_index=0 ;
    reg [2:0] lives_lost=0 ;
    
    
    integer i ;
    integer j;
    
    

                            
       assign corner = (((Coloana-HS_min)%3==0)&&((Linie-VS_min)%3==0)) || (((Coloana-HS_min)%3==2)&&((Linie-VS_min)%3==2)) ||    (((Coloana-HS_min)%3==2)&&((Linie-VS_min)%3==0)) ||    (((Coloana-HS_min)%3==0)&&((Linie-VS_min)%3==2));
       assign center = (((Coloana-HS_min)%3==1)&&((Linie-VS_min)%3==1)) ;
       assign ship_zone = (Coloana>=Main_ship_c)&&(Coloana<Main_ship_c+100)&&(Linie>=Main_ship_l)&&(Linie<Main_ship_l+70);
       assign falling_vs = (VS_tracker[2:1] == 2'b10)? 1'b1 : 1'b0 ; 
       assign death_lifes = (lives_left>0)? 1'b0 : 1'b1 ;
       assign death = death_lifes || death_shipwreck ;
       assign red_heart = ((Coloana>=(HS_max-(lives_left*48)-20))&&(Coloana<HS_max-20)&&(Linie<VS_min+46)&&(Linie>=VS_min+10)&&(InDisplay)) ;
       
         
      
      initial begin
      game_over<= 0 ;
      $readmemb("Enemy_Ship.mem" ,memEnemy_Ship);
      $readmemb("Main_Ship.mem",memShip);
      $readmemb("Space.mem",memSpace) ;
      $readmemb("Hearts.mem",Heart) ;
      end
      

      
      always@(posedge clk2)
      VS_tracker<={VS_tracker[1:0] , VS}; 
      
      always@(posedge clk2)
      if(rst)
      death_shipwreck<=0;
      else
        if((ship_zone)&&(enemy_zone)&&(memShip[(Linie-Main_ship_l)/10][9-((Coloana-Main_ship_c)/10)]==1)&&(memShip[(Linie-Main_ship_l)/10][9-((Coloana-Main_ship_c)/10)]==1)) 
            death_shipwreck<=1;
        
       always@(posedge clk2) begin
       bullet_zone=0; 
       for(i=0;i<max_bullets;i = i+1 ) begin
            if(i<number_bullets)begin
                if((Coloana>=memBullet_c[i])&&(Coloana<memBullet_c[i]+30)&&(Linie>=memBullet_l[i])&&(Linie<=memBullet_l[i]+10)&&(InDisplay))
                    bullet_zone=1;
       end 
       end
       end    
       
       always@(posedge clk2) begin
       enemy_zone=0; 
       for(i=0;i<enemy_max;i = i+1 ) begin
            if(i<number_enemies)begin
                if((Coloana>=memEnemy_c[i])&&(Coloana<memEnemy_c[i]+50)&&(Linie>=memEnemy_l[i])&&(Linie<=memEnemy_l[i]+40)&&(enemy_valid[i])&&(InDisplay)&&(memEnemy_Ship[(Linie-memEnemy_l[i])/5][(Coloana-memEnemy_c[i])/5]==1))
                    enemy_zone=1;
       end 
       end
       end  
       
       always@(posedge clk2)
       if(rst)
       kill_enemy<=0;
       else
       if((enemy_zone)&&(bullet_zone))
            kill_enemy = 1 ;
        else
            kill_enemy = 0 ;          
                    
      
      always@(posedge clk2) // AFISARE 
      if(InDisplay) begin
        if((ship_zone)&&(memShip[(Linie-Main_ship_l)/10][9-((Coloana-Main_ship_c)/10)]==1)) begin           
            red<=4'b1011;
            blue<=4'b1011;
            green<=4'b1011;
         end    
        else
        if(bullet_zone) begin // gloante
            red<=4'b1111;
            blue<=4'b0000;
            green<=4'b0000;
            end  
        else 
        if((red_heart)&&(Heart[(Linie-VS_min-10)/3][((HS_max-Coloana-20)/3)]==1)) begin
            red<=4'b1111;
            blue<=4'b0000;
            green<=4'b0000;
        end
        else
        if(enemy_zone)begin
            red<=4'b0000;
            blue<=4'b1001;
            green<=4'b0000;
        end
        else                  
        if(memSpace[(Linie-VS_min)/3][(Coloana-HS_min)/3]==1) begin // BACKGROUND
            if(center) begin // centru stea super luminos
                red<=4'b1111;
                blue<=4'b1111;
                green<=4'b1111;
                end
            else if(corner) begin // lasam coltul negru
                red<=4'b0000;
                blue<=4'b0000;
                green<=4'b000;
            end    
            else begin  // gri pentru laterale  
                red<=4'b1001;
                green<=4'b1001;
                blue<=4'b1010;
            end
      end
      else begin
        red<=4'b0000;
        green<=4'b0000;
        blue<=4'b0000;
      end
      end               
      else begin
        red<=4'b0000;
        green<=4'b0000;
        blue<=4'b0000;
      end
      
      always@(posedge clk2)
      if(rst)begin
      start<=0;
      Press<=0;
      new_bullet<=0;
      direction<=down;
      end
      else begin
      if((valid)&&(death==0)) begin
      case(keyboard)
      8'b00011101:begin 
                 direction<=up;
                 Press<=1;
                 start<=1;
                 end
      8'b00011011:begin
                  direction<=down;
                  Press<=1;
                  start<=1;
                  end
      8'b00101001:begin
                  new_bullet <= 1;
                  start<= 1;
                  end         
       endcase
       end
       else if(Linie==5) begin
            Press<=0;
            new_bullet<=0;
            end
      end
      
      always@(negedge VS) // Miscare nava
      if(rst) begin
      Main_ship_l<=200;
      end
      else begin
      if((Press==1)&&(start)&&(death==0))
        if(direction==up) begin
            if(Main_ship_l>VS_min+5)
                Main_ship_l<=Main_ship_l-5;
            else
                Main_ship_l<=VS_min ;
        end    
        else if(direction==down) begin
            if(Main_ship_l<VS_max-75)
                Main_ship_l<=Main_ship_l+5; 
            else
                Main_ship_l<=VS_max-70 ;
        end  
      end
      
      always@(posedge clk2) begin// miscare glont  + memorare glont + eliberarea de memorie de glont in caz de e outofbound
     if(rst) begin
     timer_bullets<=0;
     number_bullets<=0;
     end
     else begin
     if(death==0) begin 
      if(falling_vs) begin
         if(timer_bullets!=0) begin
                timer_bullets<=timer_bullets-1;
         end  
        else begin
            if((new_bullet==1)&&(start)) begin
            timer_bullets<=30; // 2 gloante pe secunda maxim
            memBullet_l[number_bullets] <= Main_ship_l+30;
            memBullet_c[number_bullets] <= 250;
            number_bullets <= number_bullets+1 ; 
            end
            end           
            if((memBullet_c[0])>=HS_max)begin
                for(i=0;i<max_bullets ; i=i+1) begin
                    if(i<number_bullets) begin
                        memBullet_c[i]<=memBullet_c[i+1]+6;
                        memBullet_l[i]<=memBullet_l[i+1];
                        end
                    end 
                if((new_bullet)&&(timer_bullets==0))
                    number_bullets<=number_bullets;
                else        
                    number_bullets<=number_bullets-1;
            end        
            else begin
               for(i=0;i<max_bullets ; i=i+1) begin
                    if(i<number_bullets) begin
                    memBullet_c[i]<=memBullet_c[i]+6;
                    end
               end     
            end             
       end 
       end
       end
       end
       
       always@(posedge clk2)
       if(rst)begin
       spawn_enemies<=0;
       timer_enemies<=0;
       end
       else begin
       if(death==0) begin
       if(falling_vs) begin
        if((start)&&(timer_enemies==238)) begin
            timer_enemies<=0;
            spawn_enemies<=1;
        end
        else if(start) begin
            timer_enemies<=timer_enemies+1;
            spawn_enemies<=0;
        end
        end
        end
        end 
        
        
       always@(posedge clk2)
       if(rst) begin
       enemy_valid<=0;
       count<=0;
       lifes<=0;
       counting_lives<=0;
       ship_num<=0;
       lives_left<=5;
       j<=0;
       lives_lost<=0;
       score<=0;
       end
       else begin
       if(death==0) begin
       if((falling_vs)&&(start)) begin
        for(i=0;i<32;i=i+1) begin
        if(i<number_enemies)begin
            if((memEnemy_c[i]<HS_min)&&(enemy_valid[i]==1)) begin
               enemy_valid[i]<=0;
               lifes[i]<=1;
               counting_lives<=1;
               lives_lost<=0;
               end
            else   
                if(enemy_valid[i])
                memEnemy_c[i]<=memEnemy_c[i]-ship_speed;
            end        
        end     
        if(spawn_enemies) begin
             number_enemies<=number_enemies+ran%4+1;
             count<=ran%4+1;
             ship_num<= ran%4+1 ;
             j<=0;
              
        end
           
       end 
       else if(start)
       if(counting_lives) begin
           if((lives_index==31)) begin
            lives_lost<= 0 ;
            lives_index<=0;
            counting_lives<=0;
            if(lives_left>lives_lost)
            lives_left <= lives_left-lives_lost;
            else
            lives_left<=0;
        end
        else
            if(lifes[lives_index]==1) begin
                lives_index<=lives_index+1;
                lives_lost<=lives_lost+1;
                lifes[lives_index]<=0;
                end
            else
                lives_index<=lives_index+1;
       end
       if(kill_enemy) begin 
            for(i=0 ; i<32 ; i=i+1) begin
                if(i<number_enemies) begin
                    if ((Coloana>=memEnemy_c[i])&&(Coloana<memEnemy_c[i]+50)&&(Linie>=memEnemy_l[i])&&(Linie<=memEnemy_l[i]+40)&&(enemy_valid[i])&&(InDisplay)&&(memEnemy_Ship[(Linie-memEnemy_l[i])/5][(Coloana-memEnemy_c[i])/5]==1)) begin
                        enemy_valid[i]<=0;
                        score<=score+1;
         end               
         end
         end
         end 
        else               
        if(count!=0) begin
            j<=j+1;
            if(enemy_valid[j]==0) begin
                memEnemy_c[j]<=HS_max;
                memEnemy_l[j]<=VS_max-100*count;
                count<=count-1;
                enemy_valid[j]<=1;
                end
        end
        end 
        end
           
       always@(posedge clk2)
       if(rst) begin
            ship_speed<=2;
            speed_timer<=0;
       end
       else begin
            if((start)&&(death==0))begin
                if(falling_vs) begin
                    if(speed_timer==1500) begin
                        speed_timer<=0;
                        ship_speed<=ship_speed+1;
                    end
                else
                     speed_timer<=speed_timer+1;      
                end
            end   
       end      
        
       always@(posedge clk2)
       if(rst) begin
       game_over<=0;
       timer_death<=0;
       end
       else begin
       if((start)&&(death==1))begin
            if(falling_vs) begin 
                if(timer_death==120)
                    game_over<=1;
                else
                    timer_death<=timer_death+1;     
         end
         end          
         end   
            
        
                
      
               
endmodule
