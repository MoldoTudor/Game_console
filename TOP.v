`timescale 1ns / 1ps



module TOP(
    input clk,
    input rst,
    input key_clk,
    input key_data,
    output HS,
    output VS,
    output [7:0]segment_controler,
    output [6:0]segment_value,
    output reg [3:0] red,
    output reg [3:0] blue,
    output reg [3:0] green);
    


    
    localparam waiting =3'b000;
    localparam flappy = 3'b010;
    localparam snake =3'b011;
    localparam space =3'b100;
    localparam doodle =3'b101;
    localparam black_screen = 3'b110;
    localparam choosing_game = 3'b001;
    
    wire clk2 ;// ceasul divizat
    wire [9:0]Coloana; // Coordanata de scriere
    wire [9:0]Linie; // Coordonata de scriere
    wire InDisplay; // Daca apare sau nu pe ecran
    wire [7:0] keyboard ;
    wire [3:0] red_flappy;
    wire [3:0] blue_flappy;
    wire [3:0] green_flappy;
    wire rst_lsfr;
    wire [7:0] random_number ;
    wire [3:0] red_death;
    wire [3:0] green_death;
    wire [3:0] blue_death;
    reg [2:0] state=waiting;
    reg rst_flappy=1 ;
    reg rst_snake=1 ;
    reg rst_space=1 ;
    reg rst_doodle=1 ;
    wire [3:0] red_select;
    wire [3:0] green_select;
    wire [3:0] blue_select;
    wire [9:0] ran_10bits ;
    wire [3:0] red_snake;
    wire [3:0] green_snake;
    wire [3:0] blue_snake;
    wire [3:0] red_space;
    wire [3:0] green_space;
    wire [3:0] blue_space;  
    wire [3:0] red_doodle;
    wire [3:0] green_doodle;
    wire [3:0] blue_doodle;  
    wire game_over;
    wire game_over_flappy;
    wire game_over_snake;
    wire game_over_space;
    wire game_over_doodle;
    wire valid;
    reg [9:0]wait_time=0;
    wire VS_in ;
    reg [13:0] score ;
    wire [13:0] score_flappy ;
    wire [13:0] score_snake ;
    wire [13:0] score_space ;
    wire [13:0] score_doodle ;
     wire [6:0] seven ;
     wire [7:0] anod_select;
    
    assign VS_in = VS;
    assign segment_controler = anod_select;
    assign segment_value=seven;
    Sync syn_TOP(.clk(clk),
                 .clk2(clk2),
                 .HS(HS),
                 .VS(VS),
                 .Coloana(Coloana),
                 .Linie(Linie),
                 .InDisplay(InDisplay));
                 
     Keyboard_Data key_top(.clk(clk2),
                           .rst(rst),
                           .key_data(key_data),
                           .key_clk(key_clk),
                           .keyboard(keyboard),
                           .valid(valid));
     
     Flappi_Bird_TOP flappy_bird(.clk(clk),
                                 .clk2(clk2),
                                 .rst(rst_flappy), // O SA TRB SA MODIFIC
                                 .VS(VS_in),
                                 .Coloana(Coloana),
                                 .Linie(Linie),
                                 .InDisplay(InDisplay),
                                 .valid(valid),
                                 .keyboard(keyboard),
                                 .ran(ran_10bits),
                                 .red(red_flappy),
                                 .blue(blue_flappy),
                                 .green(green_flappy),
                                 .game_over(game_over_flappy),
                                 .score(score_flappy));
                                 

                 
     Death over(.clk(clk2),
                .VS(VS_in),
                .Linie(Linie),
                .Coloana(Coloana),
                .InDisplay(InDisplay),
                .red(red_death),
                .blue(blue_death),
                .green(green_death));
      
     Random_10bits rand_10(.clk(clk),
                           .rst(rst),
                           .out(ran_10bits));          
                
      Selecting_Game selection(.clk(clk2),
                               .VS(VS_in),
                               .Linie(Linie),
                               .Coloana(Coloana),
                               .InDisplay(InDisplay),
                               .red(red_select),
                               .blue(blue_select),
                               .green(green_select)); 
        
        Snake snake_game(.clk(clk),
                         .clk2(clk2),
                         .rst(rst_snake),
                         .Coloana(Coloana),
                         .Linie(Linie),
                         .VS(VS_in),
                         .InDisplay(InDisplay),
                         .keyboard(keyboard),
                         .valid(valid),
                         .ran(ran_10bits),
                         .red(red_snake),
                         .blue(blue_snake),
                         .green(green_snake),
                         .game_over(game_over_snake),
                         .score(score_snake)); 
        
        Space_Invaders space_invad(.clk(clk),
                         .clk2(clk2),
                         .rst(rst_space),
                         .Coloana(Coloana),
                         .Linie(Linie),
                         .VS(VS_in),
                         .InDisplay(InDisplay),
                         .keyboard(keyboard),
                         .valid(valid),
                         .ran(ran_10bits),
                         .red(red_space),
                         .blue(blue_space),
                         .green(green_space),
                         .game_over(game_over_space),
                         .score(score_space)); 
      
          Doodle doodleing(.clk(clk),
                         .clk2(clk2),
                         .rst(rst_doodle),
                         .Coloana(Coloana),
                         .Linie(Linie),
                         .VS(VS_in),
                         .InDisplay(InDisplay),
                         .keyboard(keyboard),
                         .valid(valid),
                         .red(red_doodle),
                         .blue(blue_doodle),
                         .green(green_doodle),
                         .game_over(game_over_doodle),
                         .score(score_doodle));
           
           Afisor afi(.clk(clk),
                       .rst(rst),
                       .val(score),
                       .out(seven),
                       .anod_select(anod_select));                                                                                 
                

      
      always@(posedge clk)
      case(state)
      waiting: begin
                rst_flappy<=1 ;
                rst_snake<=1 ;
                red=4'b0000;
                blue=4'b0000;
                green=4'b0000;
               if(wait_time==1023)
               state<=choosing_game;
               else
               wait_time<=wait_time+1;
               end                  
      choosing_game:begin 
                 red<=red_select;          
                 green<=green_select;
                 blue<=blue_select;
                 if(valid) begin  
                 if(keyboard==8'b00010110) begin // flappy bird
                    state<=flappy;
                    rst_flappy<=0;                 
                 end
                 if(keyboard==8'b00011110) begin // snake game
                    rst_snake<=0;
                    state<=snake;   
                 end
                 if(keyboard==8'b00100110) begin // snake game
                    rst_space<=0;
                    state<=space;
                      
                 end
                 if(keyboard==8'b00100101) begin // snake game
                    rst_doodle<=0;
                    state<=doodle;
                        
                 end                                  
                 end
                 end   
                 
      flappy:begin
                 red<=red_flappy;          
                 green<=green_flappy;
                 blue<=blue_flappy; 
                 score<=score_flappy;                           
                 if(game_over_flappy) begin
                 state<=black_screen;
                 rst_flappy<=1;
                 end
                 end
      snake : begin
                 red<=red_snake;          
                 green<=green_snake;
                 blue<=blue_snake; 
                 score<=score_snake;                            
                 if(game_over_snake) begin
                    state<=black_screen;
                    rst_snake<=1;
                 end
                 end
      space:begin
                 red<=red_space;          
                 green<=green_space;
                 blue<=blue_space;
                 score<=score_space;                              
                 if(game_over_space) begin
                 state<=black_screen;
                 rst_space<=1;
                 end
                 end
      doodle:begin
                 red<=red_doodle;          
                 green<=green_doodle;
                 blue<=blue_doodle;
                 score<=score_doodle;                            
                 if(game_over_doodle) begin
                 state<=black_screen;
                 rst_doodle<=1;
                 end
                 end                                               
     black_screen: begin 
                 red<=red_death;          
                 green<=green_death;
                 blue<=blue_death; 
                 if(keyboard==8'b01011010) begin
                 state<=choosing_game;
                 end
                 end
              
       endcase                    
                                                                   
                 
endmodule
